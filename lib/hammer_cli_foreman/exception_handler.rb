require 'hammer_cli/exception_handler'
require 'hammer_cli_foreman/exceptions'

module HammerCLIForeman
  class ExceptionHandler < HammerCLI::ExceptionHandler

    def mappings
      super + [
        [HammerCLIForeman::OperationNotSupportedError, :handle_unsupported_operation],
        [RestClient::Forbidden, :handle_forbidden],
        [RestClient::UnprocessableEntity, :handle_unprocessable_entity],
        [ArgumentError, :handle_argument_error],
      ]
    end

    protected

    def handle_unprocessable_entity(e)
      response = JSON.parse(e.response)
      response = response[response.keys[0]]

      print_error response["full_messages"]
      HammerCLI::EX_DATAERR
    end


    def handle_argument_error(e)
      print_error e.message
      log_full_error e
      HammerCLI::EX_USAGE
    end


    def handle_forbidden(e)
      print_error "Forbidden - server refused to process the request"
      log_full_error e
      HammerCLI::EX_NOPERM
    end


    def handle_unsupported_operation(e)
      print_error e.message
      log_full_error e
      HammerCLI::EX_UNAVAILABLE
    end


    def handle_not_found(e)
      response = JSON.parse(e.response)
      message = response["message"] || e.message

      print_error message
      log_full_error e
      HammerCLI::EX_NOT_FOUND
    end

  end
end




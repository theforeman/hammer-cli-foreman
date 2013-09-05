require 'hammer_cli/exception_handler'

module HammerCLIForeman
  class ExceptionHandler < HammerCLI::ExceptionHandler

    def mappings
      super + [
        [RestClient::Forbidden, :handle_forbidden],
        [RestClient::UnprocessableEntity, :handle_unprocessable_entity],
        [ArgumentError, :handle_argument_error]
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

  end
end




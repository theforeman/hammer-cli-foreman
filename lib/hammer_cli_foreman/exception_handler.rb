require 'hammer_cli/exception_handler'
require 'hammer_cli_foreman/exceptions'

module HammerCLIForeman
  class ExceptionHandler < HammerCLI::ExceptionHandler

    def mappings
      super + [
        [HammerCLIForeman::OperationNotSupportedError, :handle_unsupported_operation],
        [RestClient::InternalServerError, :handle_internal_error],
        [RestClient::Forbidden, :handle_forbidden],
        [RestClient::UnprocessableEntity, :handle_unprocessable_entity],
        [ArgumentError, :handle_argument_error],
      ]
    end

    protected

    def handle_unprocessable_entity(e)
      response = JSON.parse(e.response)
      response = HammerCLIForeman.record_to_common_format(response) unless response.has_key?('message')
      print_error response['message'] || response['full_messages']
      HammerCLI::EX_DATAERR
    end


    def handle_internal_error(e)
      handle_foreman_error(e)
      HammerCLI::EX_SOFTWARE
    end


    def handle_argument_error(e)
      print_error e.message
      log_full_error e
      HammerCLI::EX_USAGE
    end


    def handle_forbidden(e)
      print_error _("Forbidden - server refused to process the request")
      log_full_error e
      HammerCLI::EX_NOPERM
    end


    def handle_unsupported_operation(e)
      print_error e.message
      log_full_error e
      HammerCLI::EX_UNAVAILABLE
    end


    def handle_not_found(e)
      handle_foreman_error(e)
      HammerCLI::EX_NOT_FOUND
    end


    def handle_foreman_error(e)
      begin
        response = JSON.parse(e.response)
        response = HammerCLIForeman.record_to_common_format(response) unless response.has_key?('message')
        message = response['message'] || e.message
      rescue JSON::ParserError => parse_e
        message = e.message
      end

      print_error message
      log_full_error e
    end

    def handle_apipie_docloading_error(e)
      rake_command = 'foreman-rake apipie:cache'
      print_error _("Could not load the API description from the server") + "\n  - " +
                  _("is the server down?") + "\n  - " +
                  _("was '%s' run on the server when using apipie cache? (typical production settings)") % rake_command
      log_full_error e
      HammerCLI::EX_CONFIG
    end

  end
end

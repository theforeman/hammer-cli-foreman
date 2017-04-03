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
        [RestClient::MovedPermanently, :handle_moved_permanently],
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


    def handle_moved_permanently(e)
      error = [_("Redirection of API call detected.")]
      https_message = _("It seems hammer is configured to use HTTP and the server prefers HTTPS.")
      error << https_message if strip_protocol(e.response.headers[:location]) == strip_protocol(e.response.request.url)
      error << _("Update your server url configuration")
      error << _("you can set 'follow_redirects' to one of :default or :always to enable redirects following")
      print_error error.join("\n")
      log_full_error e
      HammerCLI::EX_CONFIG
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

    def ssl_cert_instructions
      host_url = HammerCLI::Settings.get(:_params, :host) || HammerCLI::Settings.get(:foreman, :host)
      uri = URI.parse(host_url)
      if uri.host.nil?
        host = '<FOREMAN_HOST>'
        cert_name = "#{host}.crt"
      else
        host = uri.to_s
        cert_name = "#{uri.host}.crt"
      end

      cmd = "hammer --fetch-ca-cert #{host}"

      _("Make sure you configured the correct URL and have the server's CA certificate installed on your system.") + "\n\n" +
      _("You can use hammer to fetch the CA certificate from the server. Be aware that hammer cannot verify whether the certificate is correct and you should verify its authenticity after downloading it.") +
      "\n\n" +
      _("Download the certificate as follows:") +
      "\n\n  $ #{cmd}\n\n"
    end

    def rake_command
      "foreman-rake apipie:cache"
    end

    private

    def strip_protocol(url)
      url.gsub(%r'^http(s)?://','').gsub(%r'//', '/')
    end
  end
end

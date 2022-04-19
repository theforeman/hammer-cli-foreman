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
        [RestClient::BadRequest, :handle_bad_request],
        [ApipieBindings::AuthenticatorError, :handle_authenticator_error],
        [HammerCLIForeman::Api::UnauthorizedError, :handle_foreman_unauthorized],
        [HammerCLIForeman::Api::SessionExpired, :handle_sesion_expired],
        [ArgumentError, :handle_argument_error],
      ]
    end

    protected

    def handle_sesion_expired(e)
      log_full_error e
      HammerCLI::EX_RETRY
    end

    def handle_foreman_unauthorized(e)
      print_error e.message
      log_full_error e
      HammerCLI::EX_UNAUTHORIZED
    end

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
      error << _("Update your server url configuration.")
      error << _("You can set 'follow_redirects' to one of :default or :always to enable redirects following.")
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
      if e.response
        response = JSON.parse(e.response)
        error = response['error']
        if error && error['message'] && error['details']
          message = error['message'] + "\n" + error['details']
        end
      end
      message ||= _("Forbidden - server refused to process the request.")

      print_error message
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

    def handle_bad_request(e)
      print_error "#{e.message}#{response_message(e.response)}"
      log_full_error e
      HammerCLI::EX_DATAERR
    end

    def handle_authenticator_error(e)
      print_error authenticator_error_message(e)
      log_full_error e.original_error
      HammerCLI::EX_USAGE
    end

    def ssl_cert_instructions
      host_url = HammerCLI::Settings.get(:_params, :host) || HammerCLI::Settings.get(:foreman, :host)
      uri = URI.parse(host_url)
      ssl_option = HammerCLI::SSLOptions.new.get_options(uri)
      if uri.host.nil?
        host = '<FOREMAN_HOST>'
        cert_name = "#{host}.crt"
      else
        host = uri.to_s
        cert_name = "#{uri.host}.crt"
      end

      cmd = "hammer --fetch-ca-cert #{host}"

      if !ssl_option[:ssl_ca_path].nil? || !ssl_option[:ssl_ca_file].nil?
        instructions = _("The following configuration option were used for the SSL connection:" ) + "\n"
        instructions << "  ssl_ca_path = #{ssl_option[:ssl_ca_path]}\n" unless ssl_option[:ssl_ca_path].nil?
        instructions << "  ssl_ca_file = #{ssl_option[:ssl_ca_file]}\n" unless ssl_option[:ssl_ca_file].nil?
        instructions << "\n" + _("Make sure the location contains an unexpired and valid CA certificate for %s.") % host_url
      else
        instructions = _("You can use hammer to fetch the CA certificate from the server. Be aware that hammer cannot verify whether the certificate is correct and you should verify its authenticity after downloading it.")
        instructions << "\n\n" + _("Download the certificate as follows:")
        instructions << "\n\n  $ #{cmd}\n\n"
      end

      _("Make sure you configured the correct URL and have the server's CA certificate installed on your system.") +
          "\n\n" + instructions
    end

    def rake_command
      "foreman-rake apipie:cache"
    end

    private

    def authenticator_error_message(e)
      case e.type
      when :negotiate
        _('Could not authenticate using negotiation protocol') + "\n  - " +
          _('have you run %s (for Kerberos)?') % 'kinit' + "\n  - " +
          _('is the server down?') + "\n"
      end
    end

    def response_message(response)
      message = JSON.parse(response)["error"]["message"]
      "\n  #{message}"
    rescue JSON::ParserError
      ''
    end

    def strip_protocol(url)
      url.gsub(%r'^http(s)?://','').gsub(%r'//', '/')
    end
  end
end

require 'net/http'
require 'uri'
module HammerCLIForeman
  class OpenidConnect
    def initialize(url, oidc_client_id)
      @url = url
      @oidc_client_id = oidc_client_id
    end

    def get_token(username, password)
      uri = URI.parse(@url)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/x-www-form-urlencoded'
      request.set_form_data(
        'username' => username,
        'password' => password,
        'grant_type' => 'password',
        'client_id' => @oidc_client_id
      )
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |https|
        https.request(request)
      end
      json_response = JSON.parse(response.body)
      if json_response.is_a?(Hash)
        json_response['access_token']
      else
        raise _("Invalid access token response.")
        nil
      end
    rescue JSON::ParserError => e
      raise _('Invalid access token')
      nil
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      raise _("Failed to recieve acess token, please check your connectivity with OpenID provider: %s") % e
      nil
    end

    def get_token_via_2fa(code, oidc_redirect_uri)
      uri = URI.parse(@url)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/x-www-form-urlencoded'
      request.set_form_data(
        'client_id' => @oidc_client_id,
        'code' => code,
        'grant_type' => 'authorization_code',
        'redirect_uri' => oidc_redirect_uri
      )
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |https|
        https.request(request)
      end
      json_response = JSON.parse(response.body)
      if json_response.is_a?(Hash)
        json_response['access_token']
      else
        raise _("Invalid access token response.")
        nil
      end
    rescue JSON::ParserError => e
      raise _('Invalid access token')
      nil
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      raise _("Failed to recieve acess token, please check your connectivity with OpenID provider: %s") % e
      nil
    end
  end
end

require 'hammer_cli'
module HammerCLIForeman
  class Defaults < HammerCLI::BaseDefaultsProvider
    def initialize(api_connection = HammerCLIForeman.foreman_api_connection)
      @api_connection = api_connection
      @provider_name = 'foreman'
      @supported_defaults = [:organization_id, :location_id]
      @description = _('Use the default organization and/or location from the server')
    end

    def get_defaults(param)
      param = "default_organization" if param == :organization_id
      param = "default_location" if param == :location_id
      user = get_user
      val = nil
      if user
        val = user["results"].first[param] if user["results"]
        val = val["id"] if val.is_a?(Hash) && param.include?("default")
      end
      val
    end

    private
    def get_user
      login = @api_connection.authenticator.user
      users = @api_connection.resource(:users).action(:index).call(:search => "login=#{login}")
      users
    end
  end

  HammerCLI.defaults.register_provider(Defaults.new)
end

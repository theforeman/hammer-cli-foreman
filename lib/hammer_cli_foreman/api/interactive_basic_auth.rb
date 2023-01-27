require 'hammer_cli_foreman/api/basic_auth'

module HammerCLIForeman
  module Api
    class InteractiveBasicAuth < ApipieBindings::Authenticators::BasicAuth
      include HammerCLIForeman::Api::BasicAuth
    end
  end
end

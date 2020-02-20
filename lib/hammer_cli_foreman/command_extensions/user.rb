module HammerCLIForeman
  module CommandExtensions
    class User < HammerCLI::CommandExtensions
      option '--default-organization', 'DEFAULT_ORGANIZATION_NAME', _('Default organization name'),
             aliased_resource: 'default_organization', referenced_resource: 'default_organization'
      option '--default-location', 'DEFAULT_LOCATION_NAME', _('Default location name'),
             aliased_resource: 'default_location', referenced_resource: 'default_location'

      option '--ask-password', 'ASK_PW', ' ', format: HammerCLI::Options::Normalizers::Bool.new

      option_sources do |sources, command|
        sources << HammerCLIForeman::OptionSources::UserParams.new(command)
        sources
      end
    end
  end
end

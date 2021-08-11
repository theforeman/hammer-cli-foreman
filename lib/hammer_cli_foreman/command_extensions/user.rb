module HammerCLIForeman
  module CommandExtensions
    class User < HammerCLI::CommandExtensions
      option '--ask-password', 'ASK_PW', ' ', format: HammerCLI::Options::Normalizers::Bool.new

      option_sources do |sources, command|
        sources << HammerCLIForeman::OptionSources::UserParams.new(command)
        sources
      end

      option_family associate: 'default_organization' do
        child '--default-organization', 'DEFAULT_ORGANIZATION_NAME', _('Default organization name'),
              aliased_resource: 'default_organization', referenced_resource: 'organization'
      end
      option_family associate: 'default_location' do
        child '--default-location', 'DEFAULT_LOCATION_NAME', _('Default location name'),
              aliased_resource: 'default_location', referenced_resource: 'location'
      end
    end
  end
end

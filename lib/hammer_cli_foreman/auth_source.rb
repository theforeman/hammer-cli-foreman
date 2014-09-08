require 'hammer_cli_foreman/auth_source_ldap'

module HammerCLIForeman

  class AuthSource < HammerCLIForeman::Command

    subcommand 'ldap', HammerCLIForeman::AuthSourceLdap.desc, HammerCLIForeman::AuthSourceLdap
  end

end

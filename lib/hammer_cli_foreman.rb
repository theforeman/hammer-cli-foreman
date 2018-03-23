require 'hammer_cli'
require 'hammer_cli/exit_codes'
require 'apipie_bindings'

module HammerCLIForeman

  def self.exception_handler_class
    HammerCLIForeman::ExceptionHandler
  end

  require 'hammer_cli_foreman/i18n'

  require 'hammer_cli_foreman/version'
  require 'hammer_cli_foreman/output'
  require 'hammer_cli_foreman/output/fields'
  require 'hammer_cli_foreman/exception_handler'
  require 'hammer_cli_foreman/option_builders'
  require 'hammer_cli_foreman/param_filters'
  require 'hammer_cli_foreman/id_resolver'
  require 'hammer_cli_foreman/dependency_resolver'
  require 'hammer_cli_foreman/option_sources'
  require 'hammer_cli_foreman/logger'

  begin
    require 'hammer_cli_foreman/commands'
    require 'hammer_cli_foreman/associating_commands'
    require 'hammer_cli_foreman/references'
    require 'hammer_cli_foreman/parameter'
    require 'hammer_cli_foreman/common_parameter'
    require 'hammer_cli_foreman/defaults'

    HammerCLI::MainCommand.lazy_subcommand('auth', _("Foreman connection login/logout"),
      'HammerCLIForeman::Auth', 'hammer_cli_foreman/auth'
    )

    HammerCLI::MainCommand.lazy_subcommand('architecture', _("Manipulate architectures"),
      'HammerCLIForeman::Architecture', 'hammer_cli_foreman/architecture'
    )

    HammerCLI::MainCommand.lazy_subcommand('auth-source', _("Manipulate auth sources"),
      'HammerCLIForeman::AuthSource', 'hammer_cli_foreman/auth_source'
    )

    HammerCLI::MainCommand.lazy_subcommand('compute-resource', _("Manipulate compute resources"),
      'HammerCLIForeman::ComputeResource', 'hammer_cli_foreman/compute_resource'
    )

    HammerCLI::MainCommand.lazy_subcommand('domain', _("Manipulate domains"),
      'HammerCLIForeman::Domain', 'hammer_cli_foreman/domain'
    )

    HammerCLI::MainCommand.lazy_subcommand('environment', _("Manipulate environments"),
      'HammerCLIForeman::Environment', 'hammer_cli_foreman/environment'
    )

    HammerCLI::MainCommand.lazy_subcommand('fact', _("Search facts"),
      'HammerCLIForeman::Fact', 'hammer_cli_foreman/fact'
    )

    HammerCLI::MainCommand.lazy_subcommand('filter', _("Manage permission filters"),
      'HammerCLIForeman::Filter', 'hammer_cli_foreman/filter'
    )

    HammerCLI::MainCommand.lazy_subcommand('host', _("Manipulate hosts"),
      'HammerCLIForeman::Host', 'hammer_cli_foreman/host'
    )

    HammerCLI::MainCommand.lazy_subcommand('hostgroup', _("Manipulate hostgroups"),
      'HammerCLIForeman::Hostgroup', 'hammer_cli_foreman/hostgroup'
    )

    HammerCLI::MainCommand.lazy_subcommand('location', _("Manipulate locations"),
      'HammerCLIForeman::Location', 'hammer_cli_foreman/location'
    )

    HammerCLI::MainCommand.lazy_subcommand('medium', _("Manipulate installation media"),
      'HammerCLIForeman::Medium', 'hammer_cli_foreman/media'
    )

    HammerCLI::MainCommand.lazy_subcommand('model', _("Manipulate hardware models"),
      'HammerCLIForeman::Model', 'hammer_cli_foreman/model'
    )

    HammerCLI::MainCommand.lazy_subcommand('os', _("Manipulate operating system"),
      'HammerCLIForeman::OperatingSystem', 'hammer_cli_foreman/operating_system'
    )

    HammerCLI::MainCommand.lazy_subcommand('organization', _("Manipulate organizations"),
      'HammerCLIForeman::Organization', 'hammer_cli_foreman/organization'
    )

    HammerCLI::MainCommand.lazy_subcommand('partition-table', _("Manipulate partition tables"),
      'HammerCLIForeman::PartitionTable', 'hammer_cli_foreman/partition_table'
    )

    HammerCLI::MainCommand.lazy_subcommand('puppet-class', _("Search puppet modules"),
      'HammerCLIForeman::PuppetClass', 'hammer_cli_foreman/puppet_class'
    )

    HammerCLI::MainCommand.lazy_subcommand('report', _("Browse and read reports"),
      'HammerCLIForeman::Report', 'hammer_cli_foreman/report'
    )

    HammerCLI::MainCommand.lazy_subcommand('role', _("Manage user roles"),
      'HammerCLIForeman::Role', 'hammer_cli_foreman/role'
    )

    HammerCLI::MainCommand.lazy_subcommand('sc-param', _("Manipulate smart class parameters"),
      'HammerCLIForeman::SmartClassParameter', 'hammer_cli_foreman/smart_class_parameter'
    )

    HammerCLI::MainCommand.lazy_subcommand('smart-variable', _("Manipulate smart variables"),
      'HammerCLIForeman::SmartVariable', 'hammer_cli_foreman/smart_variable'
    )

    HammerCLI::MainCommand.lazy_subcommand('proxy', _("Manipulate smart proxies"),
      'HammerCLIForeman::SmartProxy', 'hammer_cli_foreman/smart_proxy'
    )

    HammerCLI::MainCommand.lazy_subcommand('realm', _("Manipulate realms"),
      'HammerCLIForeman::Realm', 'hammer_cli_foreman/realm'
    )

    HammerCLI::MainCommand.lazy_subcommand('settings', _("Change server settings"),
      'HammerCLIForeman::Settings', 'hammer_cli_foreman/settings'
    )

    HammerCLI::MainCommand.lazy_subcommand('subnet', _("Manipulate subnets"),
      'HammerCLIForeman::Subnet', 'hammer_cli_foreman/subnet'
    )

    HammerCLI::MainCommand.lazy_subcommand('template', _("Manipulate config templates"),
      'HammerCLIForeman::Template', 'hammer_cli_foreman/template'
    )

    HammerCLI::MainCommand.lazy_subcommand('user', _("Manipulate users"),
      'HammerCLIForeman::User', 'hammer_cli_foreman/user'
    )

    HammerCLI::MainCommand.lazy_subcommand('user-group', _("Manage user groups"),
      'HammerCLIForeman::Usergroup', 'hammer_cli_foreman/usergroup'
    )

    HammerCLI::MainCommand.lazy_subcommand('config-group', _("Manipulate config groups"),
      'HammerCLIForeman::ConfigGroup', 'hammer_cli_foreman/config_group'
    )

  rescue => e
    handler = HammerCLIForeman::ExceptionHandler.new(:context => {}, :adapter => :base)
    handler.handle_exception(e)
    raise HammerCLI::ModuleLoadingError.new(e)
  end

end


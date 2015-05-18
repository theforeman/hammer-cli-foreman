Using HammerCLIForeman
======================

hammer-cli-foreman comes with a handy framework similar to [hammer-cli's ApiPie::Command](https://github.com/theforeman/hammer-cli/blob/master/doc/creating_apipie_commands.md#creating-commands-for-restful-api-with-apipie) which allows the creation of CRUD commands based off the foreman servers api documentation.

Using HammerCLIForeman's Command class instead of ```HammerCLI::Command``` or ```HammerCLI::Apipie::Command``` will allow you to use less code, piggy back on the HammerCLIForeman configuration (username/password/cache/etc..) and rely more on the foreman servers api description for inputs.



Example Command Template
------------------------

**Notes**
* Replace $VARIABLES with your code
* You will still need to map commands


**File**: lib/hammer_cli_foreman_$NAME.rb
```ruby
require 'hammer_cli_foreman'

module HammerCLIForeman$NAME
  def self.exception_handler_class
    HammerCLIForeman::ExceptionHandler
  end

  # Using lazy-loaded subcommands
  # https://github.com/theforeman/hammer-cli/blob/master/doc/creating_commands.md#lazy-loaded-subcommands
  HammerCLI::MainCommand.lazy_subcommand(
    '$NAME',
    '$DESCRIPTION',
    'HammerCLIForeman$NAME::Command',
    'hammer_cli_foreman_$NAME/command')
end

```


**File**: lib/hammer_cli_foreman_$NAME/command.rb
```ruby
require 'hammer_cli'
require 'hammer_cli_foreman'

module HammerCLIForeman$NAME

  class Command < HammerCLIForeman::Command

      resource :$API_RESOURCE
      command_name '$COMMAND_NAME'

      # Lists $NAME's
      class ListCommand < HammerCLIForeman::ListCommand
        output do
          field :id, _('Id')
          $MORE_FIELDS_YOU_WANT_TO_SHOW
        end

        build_options # Builds CLI options based on the apidoc
      end

      # Get's information on a specific $NAME
      class InfoCommand < HammerCLIForeman::InfoCommand
        failure_message 'Could not find the requested $NAME' # What to show on failure

        output do
          field :id, _('Id')
          $MORE_FIELDS_YOU_WANT_TO_SHOW
        end

        build_options # Builds CLI options based on the apidoc
      end

      # Creates a new $NAME
      class CreateCommand < HammerCLIForeman::CreateCommand
        success_message '$NAME created' # What to show on success
        failure_message 'Could not create a $NAME' # What to show on failure

        build_options # Builds CLI options based on the apidoc
      end

      # Delete's a new $NAME
      class DeleteCommand < HammerCLIForeman::DeleteCommand
        success_message '$NAME deleted' # What to show on success
        failure_message 'Could not delete the $NAME' # What to show on failure

        build_options # Builds CLI options based on the apidoc
      end

      autoload_subcommands
  end
end
```

Hammer-CLI-Foreman Development Docs
===================================

There's a lot of useful information in
[development documentation of Hammer Core](https://github.com/theforeman/hammer-cli/blob/master/doc/developer_docs.md#hammer-development-docs).
Studying it first can help you to understand the basic principles.

Foreman plugin extends the Hammer Core in following areas:
 - [Using HammerCLIForeman::Command](using_hammer_cli_foreman_command.md#using-hammercliforeman)
 - [Building options](option_builder.md#option-builders)
 - [Automatic name resolution](name_id_resolution.md#name-to-id-resolution)
 - [Testing commands](testing.md#testing-hammer-commands)
 - [Writing a plugin](plugin.md#writing-a-plugin)

It's recommended that you set `:refresh_cache: true` in the plugin settings if
engaging in API development to enable aggressive apidoc cache checking.

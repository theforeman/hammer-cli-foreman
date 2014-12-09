Name to ID resolution
=====================

How it works
------------

The Foreman's API uses unique numeric IDs to reference resources. While they are very easy to deal with in scripts, human users appreciate more readable identifiers. Most of the Foreman's resources are also searchable by name. `HammerCLIForeman`'s commands use ID resolution to make a developer's life easier by handling the translation of names to numeric IDs.

The ID resolution process consists of two parts:
- building correct parameters (option builders are described [here](https://github.com/theforeman/hammer-cli-foreman/blob/master/doc/option_builder.md#option-builders))
- the translation process itself ([IdResolver](https://github.com/theforeman/hammer-cli-foreman/blob/master/lib/hammer_cli_foreman/id_resolver.rb) takes care of that)

ID resolution step by step
--------------------------

`IdResolver` implements the method `<resource_name>_id(cli_options)` for each of the resources. Under the hood, the method:
- returns `cli_options['option_id']` if it's not nil
- looks at `index` method's parameters, finds all required `*_id` params there and makes sure they're present (if not it tries to resolve them recursively)
- extends the original options with a `search` field that searches for the name
- calls the `index` method and returns the result

It can end up with an exception when:
- the options necessary for search (typically name) are not present
- one of the dependent resources couldn't be found
- the resource was not found
- more resources were found

APIdoc requirements
-------------------

The builtin name to id resolution in `hammer-cli-foreman` works if the following conditions are met:
- the API parameters that need to be resolved must respect `<resource_name>_id` format
- the resource's API controller needs to have the action `index`
- the `index` action has to support searching by name
- the `index` action's docs mention all required `*_id` parameters
- all the above conditions have been fulfilled for any resource referenced from the previous `index` action

Command requirements
--------------------

Option builders should take care of all the requirements for you, but just for the sake of completeness:
- the command's action needs to have parameter `id`
- the command needs to have defined options `--id`, `--name` and possibly options for other identifiers of the primary resource (resource specified in the command)
- the command needs to define options `--<resource_name>-id`, `--<resource_name>` (but with the reader method `option<resource_name>_name`!) and possibly others for remaining identifiers of all the dependent resources

Behaviour tuning
----------------

Most of the resources are searchable by name. However there are exceptions that either don't have a name or offer more searchable fields. In such cases you have to update [the definition of searchable fields](https://github.com/theforeman/hammer-cli-foreman/blob/master/lib/hammer_cli_foreman/id_resolver.rb#L31).


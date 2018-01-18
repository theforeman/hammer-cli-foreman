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
- returns HammerCLI::NilValue if the correspondent search option is set to HammerCLI::NilValue (i.e. NIL specified on CLI)
- looks at `index` method's parameters, finds all required `*_id` params there and makes sure they're present (if not it tries to resolve them recursively)
- extends the original options with a `search` field that searches for the name
- calls the `index` method and returns the result

It can end up with an exception when:
- the options necessary for search (typically name) are not present
- one of the dependent resources couldn't be found
- the resource was not found
- more resources were found

Differences in resolution of list of id's
-----------------------------------------

the lookup method is called `<resource_name>_ids` and in addition:
- returns `cli_options['option_ids']` if it's not nil
- returns empty list (`[]`) when the search option is set to empty string or empty list 

It also ends up with exception when any of the ids was not resolved.

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

The resolution can be tuned at various levels.

Most of the resources are searchable by name. However there are exceptions that either don't have a name 
or offer more searchable fields. In such cases you have to update the definition 
of searchable fields (SEARCHABLES) in [id_resolver](https://github.com/theforeman/hammer-cli-foreman/blob/master/lib/hammer_cli_foreman/id_resolver.rb).

If you need to modify the lookup query (the `search` field) you can override the default one by adding a method 
returning the correct lookup options to the resolver class.
The method should be called according to the following schema: 
- `create_<resource_name>_search_options(options)` for single id lookup (takes precedence over the next one for single id lookups) 
- `create_<resource_plural_name>_search_options(options)` combine for single and/or multiple ids lookup 
- `create_<resource_plural_name>_search_options(options, mode)` combined with extra parameter suggesting the lookup mode and being set to `:single`, `:multi` or `nil`

For examples check the `id_resolver`.

It is possible to completely override the resolution procedure by adding a method(s) called `<resource_name>_id` and/or `<resource_name>_ids` to the `id_resolver`.
It will get the options hash as an input and expects `id` (list of `ids` respectively) or a `ResolverError` on its return.

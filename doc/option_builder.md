Option Builders
===============

Commands in the Foreman plugin have by default option builders for:
- parameters of the related ApiPie action
- parameters necessary for identication of the resources appearing in the action

The latter creates options for identifying resources based on the action's parameters
and definition of the resource's searchable fields (_any field that is unique either globally
or in a scope and is accessible in scoped search at the same time_).
The searchables definition is kept in [a single mapping object](../lib/hammer_cli_foreman/id_resolver.rb).

__The builder creates:__

1. An identifier option for each of the resource's searchable fields if the action takes parameter `:id`.
   E.g. `--id`, `--name`, `--label`.
1. Prefixed identifier options for each parameter ending with `_id` that appears in the action.
   E.g. `--organization` (first searchable field
   is considered default and the field name is omitted), `--organization-id`, `--organization-label`.
1. Prefixed identifier options as above for each __required__ parameter ending with `_id` that appears in index actions
   of the resources found in the previous step. These options are required for searching resources that appear in the action.
1. Expansion continues repeating the step 3 recursively.


However, this default behavior is not always applicable. Therefore the builder
enables customizing the set of expanded resources.

See examples in the code below.

```ruby
build_options do |o|
  o.expand(:all)  # will do all expansions (default)
  o.expand(:none) # will not expand anything

  o.expand(:all).including(:locations) # will create additional identifier
                                       # options for locations
  o.expand.including(:locations)       # equivalent to the above

  o.expand(:all).except(:organizations) # create identifier options for all resources
                                        # except from organizations

  o.expand.only(:architectures, :domains) # expand searchables for specific
                                          # set of resources

  # it is also possible to combine the methods
  o.expand(:all).including(:locations).except(:organizations)
end
```

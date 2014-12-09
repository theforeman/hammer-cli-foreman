Release notes
=============

### 0.1.3 (2014-08-20)
* Update foreman.yml
* Update the zanata.xml file to push to de-DE and es-ES ([#7112](http://projects.theforeman.org/issues/7112))
* Adding system locale domain ([#7083](http://projects.theforeman.org/issues/7083))
* Name options for puppet proxies in hostgroup ([#7085](http://projects.theforeman.org/issues/7085))
* I18n - extracting new, pulling from tx


### 0.1.2
* Docs for name->id resolution
* Update with installation details and IRC channel
* Lazy loaded subcommands ([#6761](http://projects.theforeman.org/issues/6761))
* I18n - fix some broken subcommand description extractions
* I18n - fix strings to be properly extracted without interpolation
* I18n - add en_GB locale
* I18n - extracting new, pulling from tx
* Initial update of translations, fixed Makefile
* Fixed pagination ([#6766](http://projects.theforeman.org/issues/6766))
* Restrict ci_reporter gem to less than 2.0.0 to fix CI ([#6779](http://projects.theforeman.org/issues/6779))
* Add proxy refresh-features command ([#3387](http://projects.theforeman.org/issues/3387))
* Fixed simplecov dependences
* Params from searchables are not wrapped ([#6343](http://projects.theforeman.org/issues/6343))
* rest-client > 1.7 does not support ruby 1.8 ([#6534](http://projects.theforeman.org/issues/6534))
* Tests updated to use apidoc export for v1.6 ([#2922](http://projects.theforeman.org/issues/2922))
* Commands for managing roles, filters, permissions and usergroups ([#2922](http://projects.theforeman.org/issues/2922), [#4004](http://projects.theforeman.org/issues/4004))
* Obey refresh_cache default of false ([#6478](http://projects.theforeman.org/issues/6478))
* Creating a more generic hook for search_options ([#6203](http://projects.theforeman.org/issues/6203))
* Permit only --hostgroup when creating host ([#6335](http://projects.theforeman.org/issues/6335))
* Better option descriptions ([#6093](http://projects.theforeman.org/issues/6093))
* Mapping resource names in options ([#6092](http://projects.theforeman.org/issues/6092))
* Add --server cli option ([#6219](http://projects.theforeman.org/issues/6219))
* Fix for wrong parameters in proxy import ([#6090](http://projects.theforeman.org/issues/6090))
* Resolving ids in foreman base command ([#6090](http://projects.theforeman.org/issues/6090))
* Documentation for fine grained control over name expansion ([#5747](http://projects.theforeman.org/issues/5747))
* Fine grained control over name expansion ([#5747](http://projects.theforeman.org/issues/5747))
* Scoped options were not cleaning original options ([#5873](http://projects.theforeman.org/issues/5873))
* List actions don't resolve ids for optional parameters ([#5873](http://projects.theforeman.org/issues/5873))
* Help for associating commands is too generic ([#3512](http://projects.theforeman.org/issues/3512))
* Add pkg:generate_source task to generate gem ([#5793](http://projects.theforeman.org/issues/5793))

### 0.1.1
* Support for os default templates ([#3970](http://projects.theforeman.org/issues/3970))
* Searching all resources by name ([#4311](http://projects.theforeman.org/issues/4311))
* Listing associated resources ([#3102](http://projects.theforeman.org/issues/3102))
* Fix setting infinite timeouts ([#5209](http://projects.theforeman.org/issues/5209))
* Support for API localization ([#4478](http://projects.theforeman.org/issues/4478))
* Removed `log_api_calls` setting

### 0.1.0
* Fix for Hammer failing silently when no cache is generated ([#4849](http://projects.theforeman.org/issues/4849))
* Request localized api responses ([#4476](http://projects.theforeman.org/issues/4476))
* Setting request timeout ([#3598](http://projects.theforeman.org/issues/3598))
* Added provision_method to host creation
* Unified format of hammer commands ([#4697](http://projects.theforeman.org/issues/4697))
* Fix for server formatter failing on not symbol keys ([#4674](http://projects.theforeman.org/issues/4674))
* Support for dynamic bindings ([#3897](http://projects.theforeman.org/issues/3897))
* Adds host option to pass root password ([#4587](http://projects.theforeman.org/issues/4587))
* Adds conditional output field to show network interfaces ([#4589](http://projects.theforeman.org/issues/4589))
* i18n support ([#4473](http://projects.theforeman.org/issues/4473))
* Default value for proxy import_puppetclasses --dryrun ([#4130](http://projects.theforeman.org/issues/4130))
* Fixes DNS proxy id field in subnet list ([#4558](http://projects.theforeman.org/issues/4558))
* Fixes assigning puppet classes to hostgroups ([#4585](http://projects.theforeman.org/issues/4585))
* Adds more fields for hostgroup list ([#4588](http://projects.theforeman.org/issues/4588))
* Fixes createion and update of templates ([#4352](http://projects.theforeman.org/issues/4352))
* Fixes failing proxy import_classes ([#4517](http://projects.theforeman.org/issues/4517))
* Fixes displaying errors related to operating system commands ([#4467](http://projects.theforeman.org/issues/4467), [#4466](http://projects.theforeman.org/issues/4466), [#3360](http://projects.theforeman.org/issues/3360))
* Credentials moved to Foreman
* Unmanaged host can be now created empty ([#4358](http://projects.theforeman.org/issues/4358))
* Fixes 500 error messages being ignored ([#4355](http://projects.theforeman.org/issues/4355))

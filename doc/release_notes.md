Release notes
=============
### 0.9.0 (2016-12-15)
* Auth overrides only unauthorized exception ([PR #271](https://github.com/theforeman/hammer-cli-foreman/pull/271)) ([#17650](http://projects.theforeman.org/issues/17650))
* Session auth in hammer ([PR #269](https://github.com/theforeman/hammer-cli-foreman/pull/269)) ([#8016](http://projects.theforeman.org/issues/8016))
* Display override value order as long text ([#17355](http://projects.theforeman.org/issues/17355))
* Showing roles inherited from usergroups ([#16016](http://projects.theforeman.org/issues/16016))
* The 'start' key always needs a 1 or 0 ([#17393](http://projects.theforeman.org/issues/17393))
* Compute resource specific details in host help ([PR #263](https://github.com/theforeman/hammer-cli-foreman/pull/263)) ([#12472](http://projects.theforeman.org/issues/12472))
* Fix compute-resource info ([#17077](http://projects.theforeman.org/issues/17077))
* List override in filter output ([#17109](http://projects.theforeman.org/issues/17109))
* Added description field to User in hammer ([#16772](http://projects.theforeman.org/issues/16772))
* Added description field to Roles in hammer ([#16771](http://projects.theforeman.org/issues/16771))
* add taxonomies to role info ([#16799](http://projects.theforeman.org/issues/16799))
* Adds 'builtin' attribute to Role list ([#16406](http://projects.theforeman.org/issues/16406))

### 0.8.0 (2016-09-01)
* add realm commands to hammer ([PR #240](https://github.com/theforeman/hammer-cli-foreman/pull/240)) ([#4918](http://projects.theforeman.org/issues/4918))
* Renamed name to variable for smart_variables ([#16119](http://projects.theforeman.org/issues/16119))
* displaying use_puppet_default in sc-param info ([#16059](http://projects.theforeman.org/issues/16059))
* show admin flag in user-group listing ([#12473](http://projects.theforeman.org/issues/12473))
* pin fast_gettext to < 1.1.0 for ruby < 2.1 ([PR #257](https://github.com/theforeman/hammer-cli-foreman/pull/257)) ([#16141](http://projects.theforeman.org/issues/16141))
* Remove parameters api call from host info command ([#15585](http://projects.theforeman.org/issues/15585))
* Add hostgroup create/update tests ([#15312](http://projects.theforeman.org/issues/15312))
* Add description to organization and location list ([PR #247](https://github.com/theforeman/hammer-cli-foreman/pull/247)) ([#15502](http://projects.theforeman.org/issues/15502))
* Add add/remove location command to organization ([PR #248](https://github.com/theforeman/hammer-cli-foreman/pull/248)) ([#15501](http://projects.theforeman.org/issues/15501))
* Update documented test data path ([PR #246](https://github.com/theforeman/hammer-cli-foreman/pull/246)) ([#15433](http://projects.theforeman.org/issues/15433))

### 0.7.0 (2016-06-14)
* Let print adapters decide whether to paginate ([#15257](http://projects.theforeman.org/issues/15257))
* Forbid setting smart param override value and puppet default ([#13832](http://projects.theforeman.org/issues/13832))
* Add rebuild config option for host ([PR#231](https://github.com/theforeman/hammer-cli-foreman/pull/231)) ([#12103](http://projects.theforeman.org/issues/12103))
* Removing wrong colons from host create docs
* i18n - remove underscore from override value error message
* Typo in MissingSeachOptions ([#14007](http://projects.theforeman.org/issues/14007))
* Add Catalan language ([#14947](http://projects.theforeman.org/issues/14947))
* Hammer shows incorrect admin status when assign admin role using user group ([#14606](http://projects.theforeman.org/issues/14606))
* Fixed response parsing for puppetclasses parameter ([#14930](http://projects.theforeman.org/issues/14930))
* Display locked flag for templates and ptables ([#14943](http://projects.theforeman.org/issues/14943))
* Document vmware `start` parameter
* Fixes VMware name in docs for host create
* Respect per_page set in config file ([#14530](http://projects.theforeman.org/issues/14530))
* Provide success/failure message for associating commands ([#7492](http://projects.theforeman.org/issues/7492))
* Add support for Gemfile.local.rb ([#14466](http://projects.theforeman.org/issues/14466))
* Fixing path in docs for generated test json ([PR#226](https://github.com/theforeman/hammer-cli-foreman/pull/226))
* Added clone command to config templates ([#13946](http://projects.theforeman.org/issues/13946))
* Handle API request redirects with useful message ([#11147](http://projects.theforeman.org/issues/11147))
* Newer version of apipie validates types for arrays ([#13966](http://projects.theforeman.org/issues/13966))
* Show auth source name for all auth sources ([#7468](http://projects.theforeman.org/issues/7468))
* Environment and Puppet proxy is not required ([#13926](http://projects.theforeman.org/issues/13926))
* Added special method for dealing with puppetclasses ([#11880](http://projects.theforeman.org/issues/11880))
* Make primary and provision flag optional ([#13927](http://projects.theforeman.org/issues/13927))

### 0.6.0 (2016-02-25)
* Names of sc-params are immutable ([#13830](http://projects.theforeman.org/issues/13830))
* Support for command testing moved to core ([#4118](http://projects.theforeman.org/issues/4118))
* Adding parent to taxonomies info command ([#13758](http://projects.theforeman.org/issues/13758))
* Showing hidden_value? for smart variables and class parameters ([#13750](http://projects.theforeman.org/issues/13750))
* Executing "hammer role filters" command throws SQL errors ([#13064](http://projects.theforeman.org/issues/13064))
* Remove psych require from Gemfile ([#12797](http://projects.theforeman.org/issues/12797))
* Hammer listing the sc-params shows puppetclass ([#12998](http://projects.theforeman.org/issues/12998))

### 0.5.1 (2015-12-14)
* Fixing dependency issues

### 0.5.0 (2015-12-14)
* Addng info command to role ([#7412](http://projects.theforeman.org/issues/7412))
* Add defaults support for location/organization ([#11402](http://projects.theforeman.org/issues/11402))
* Tests updated to work with Foreman 1.10 API ([#12260](http://projects.theforeman.org/issues/12260))
* Commands for setting parameters at taxonomies ([#12699](http://projects.theforeman.org/issues/12699))
* Change once to one in error message ([#12695](http://projects.theforeman.org/issues/12695))
* Host create VMware docs update ([#12087](http://projects.theforeman.org/issues/12087))
* Add option to overwrite conflicts on host changes ([#9208](http://projects.theforeman.org/issues/9208))
* String parameters get double-quoted ([#12202](http://projects.theforeman.org/issues/12202))
* Added IPAM desc on info command ([#11074](http://projects.theforeman.org/issues/11074))

### 0.4.0 (2015-09-21)
* Adding match_default to smart variables and smart class parameters ([#10731](http://projects.theforeman.org/issues/10731))
* Missing field for VMWare host creation docs ([#11088](http://projects.theforeman.org/issues/11088))
* Delete direct dependencies (refs [#11452](http://projects.theforeman.org/issues/11452))
* Messages in associating commands weren't translated ([#7236](http://projects.theforeman.org/issues/7236))
* Add root_pass option ([#11236](http://projects.theforeman.org/issues/11236))
* Drop Ruby 1.8 support (refs [#11280](http://projects.theforeman.org/issues/11280))


### 0.3.0 (2015-07-29)
* Add normalizer converting id parameter values to numbers ([#11137](http://projects.theforeman.org/issues/11137))
* Docs - updated information about host creation
* Added some rough docs showing HammerCLIForeman::Command
* Adding a command for building PXE default ([#3968](http://projects.theforeman.org/issues/3968))
* Turn off pagination by default ([#10534](http://projects.theforeman.org/issues/10534))
* Can't set array parameters on hosts ([#10547](http://projects.theforeman.org/issues/10547))


### 0.2.0 (2015-04-23)
* Adding default org and loc to user info ([#10251](http://projects.theforeman.org/issues/10251))
* Host update resets some attributes ([#10215](http://projects.theforeman.org/issues/10215))
* Improve handling of id search errors ([#9971](http://projects.theforeman.org/issues/9971))
* Commands for managing host's interfaces ([#3849](http://projects.theforeman.org/issues/3849))
* Support for smart variables and override values ([#2928](http://projects.theforeman.org/issues/2928))
* Can't convert nil into Array in compute resouce info ([#7699](http://projects.theforeman.org/issues/7699))
* Use correct domain for system locales, only load one domain ([#9648](http://projects.theforeman.org/issues/9648))
* Allow disablement of record_to_common_format ([#8227](http://projects.theforeman.org/issues/8227))
* Puppet-classes in host and hostgroup returns without an error ([#7473](http://projects.theforeman.org/issues/7473))
* Does not resolve a nested host group to id when updating a host ([#9318](http://projects.theforeman.org/issues/9318))
* User info doesn't display timezone and locale ([#9114](http://projects.theforeman.org/issues/9114))
* Update to gettext 3.x ([#8980](http://projects.theforeman.org/issues/8980))
* Commands for settings ([#2918](http://projects.theforeman.org/issues/2918))
* Adds dns name association to domain cli ([#3630](http://projects.theforeman.org/issues/3630))
* List of host facts is shown correctly ([#7187](http://projects.theforeman.org/issues/7187))
* Add config directory to gemspec ([#8829](http://projects.theforeman.org/issues/8829))
* List commands should not be interactive for csv output ([#3898](http://projects.theforeman.org/issues/3898))


### 0.1.4 (2014-12-11)
* sending puppet class ids ([#8651](http://projects.theforeman.org/issues/8651))
* setting --puppet-class-ids on host create/update throws api exception ([#8642](http://projects.theforeman.org/issues/8642))
* adding name equivalents to params in host/hostgroup create/update ([#8299](http://projects.theforeman.org/issues/8299))
* id resolution for associted resources ([#8246](http://projects.theforeman.org/issues/8246))
* added missing search option error message ([#5556](http://projects.theforeman.org/issues/5556))
* OSs referenced by title ([#8247](http://projects.theforeman.org/issues/8247))
* credentials definition moved to ApipieBindings ([#7408](http://projects.theforeman.org/issues/7408))
* listing filters for roles always fail with an exception ([#7913](http://projects.theforeman.org/issues/7913))
* api for operating systems now uses field 'title' ([#7917](http://projects.theforeman.org/issues/7917))
* i18n - add zh_CN language
* i18n - add de, it, pt_BR, zh_TW, ru, ja, ko languages
* external user groups CLI ([#6879](http://projects.theforeman.org/issues/6879))
* moved LDAP auth sources to separate command
* adds command to manage ldap auth sources ([#2924](http://projects.theforeman.org/issues/2924))
* avoid locale domain name conflict ([#7262](http://projects.theforeman.org/issues/7262))


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

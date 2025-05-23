Release notes
=============
### 3.15.0 (2025-05-14)
* Use 3.15 test data
* Fix hammer insights inventory sync error message ([PR #640](https://github.com/theforeman/hammer-cli-foreman/pull/640)), [#38401](http://projects.theforeman.org/issues/38401)
* Fix hammer host update error messages, [#38291](http://projects.theforeman.org/issues/38291)
* Bump to 3.15.0-develop

### 3.14.0 (2025-02-20)
* Invalidate tokens for specific user/users ([PR #636](https://github.com/theforeman/hammer-cli-foreman/pull/636)), [#38124](http://projects.theforeman.org/issues/38124)
* Don't build hidden params as options ([PR #634](https://github.com/theforeman/hammer-cli-foreman/pull/634)), [#38077](http://projects.theforeman.org/issues/38077)
* Use master branch of apipie-bindings in ci
* Drop el 8 from packit config
* Add secure boot and tpm options to vmware ([PR #630](https://github.com/theforeman/hammer-cli-foreman/pull/630)), [#37685](http://projects.theforeman.org/issues/37685)
* Add firmware option for libvirt hosts creation ([PR #631](https://github.com/theforeman/hammer-cli-foreman/pull/631)), [#37692](http://projects.theforeman.org/issues/37692)
* Use non-deprecated gpl-3.0-or-later license tag
* Bump to 3.14.0-develop

### 3.13.0 (2024-11-08)
* Bump to 3.13.0-develop

### 3.12.0 (2024-08-14)
* Ensure foreman_version usage in all tests
* Prune test data prior to 3.0
* Use 3.12 test data
* Drop cpu mode option for libvirt, [#36999](http://projects.theforeman.org/issues/36999)
* Add nvme controllers to hammer help ([PR #628](https://github.com/theforeman/hammer-cli-foreman/pull/628)), [#37689](http://projects.theforeman.org/issues/37689)
* Bump to 3.12.0-develop

### 3.11.0 (2024-05-22)
* Update test data to 3.11
* Bump to 3.11.0-develop

### 3.10.0 (2024-02-21)
* Update packit ([PR #627](https://github.com/theforeman/hammer-cli-foreman/pull/627))
* Use require_relative for 'coverage_reporter' ([PR #626](https://github.com/theforeman/hammer-cli-foreman/pull/626)), [#37163](http://projects.theforeman.org/issues/37163)
* Show mac address in vmware info ([PR #624](https://github.com/theforeman/hammer-cli-foreman/pull/624)), [#36991](http://projects.theforeman.org/issues/36991)
* Bump to 3.10.0-develop

### 3.9.0 (2023-11-29)
* Add cache status to ping output ([PR #622](https://github.com/theforeman/hammer-cli-foreman/pull/622)), [#36954](http://projects.theforeman.org/issues/36954)
* Use strings, not floats to denote ruby versions ([PR #623](https://github.com/theforeman/hammer-cli-foreman/pull/623))
* Update packit
* Drop rackspace cr support ([PR #619](https://github.com/theforeman/hammer-cli-foreman/pull/619)), [#36813](http://projects.theforeman.org/issues/36813)
* Update rel-eng
* Bump to 3.9.0-develop

### 3.8.0 (2023-08-25)
* Support mocha 2.1 ([PR #618](https://github.com/theforeman/hammer-cli-foreman/pull/618)), [#34879](http://projects.theforeman.org/issues/34879)
* Add ga to run tests on ruby 3+ ([PR #617](https://github.com/theforeman/hammer-cli-foreman/pull/617))
* Update tx for hammer-cli-foreman, [#36315](http://projects.theforeman.org/issues/36315)
* Add packit config
* Bump to 3.8.0-develop

### 3.7.0 (2023-05-23)
* Update rake for hammer-cli-foreman ([PR #613](https://github.com/theforeman/hammer-cli-foreman/pull/613)), [#36337](http://projects.theforeman.org/issues/36337)
* Update minitest version ([PR #611](https://github.com/theforeman/hammer-cli-foreman/pull/611)), [#36349](http://projects.theforeman.org/issues/36349)
* Allow to suppress nothing to update message, [#36213](http://projects.theforeman.org/issues/36213)
* Bump to 3.7.0-develop

### 3.6.0 (2023-02-23)
* Support basic auth for external sources, [#11317](http://projects.theforeman.org/issues/11317)
* Remove underscore from labels ([PR #608](https://github.com/theforeman/hammer-cli-foreman/pull/608)), [#35904](http://projects.theforeman.org/issues/35904)
* Update foreman.yml - add a comment on defining the server address in a development environment ([PR #602](https://github.com/theforeman/hammer-cli-foreman/pull/602))
* Fix typo in ovirt disk interface names
* Bump to 3.6.0-develop

### 3.5.0 (2022-10-31)
* Extract gce related info ([PR #606](https://github.com/theforeman/hammer-cli-foreman/pull/606)), [#35659](http://projects.theforeman.org/issues/35659)
* Change auth endpoint for negotiation, [#35473](http://projects.theforeman.org/issues/35473)
* Enhance vmware listing commands and switch to cluster_name param ([PR #604](https://github.com/theforeman/hammer-cli-foreman/pull/604)), [#35438](http://projects.theforeman.org/issues/35438)
* Bump to 3.5.0-develop

### 3.4.0 (2022-08-09)
* Add options for table preferences cli ([PR #603](https://github.com/theforeman/hammer-cli-foreman/pull/603)), [#35219](http://projects.theforeman.org/issues/35219)
* I18n - extracting new, pulling from tx, [#34629](http://projects.theforeman.org/issues/34629)
* Fix config for transifex, [#34629](http://projects.theforeman.org/issues/34629)
* Bump to 3.4.0-develop

### 3.3.0 (2022-05-10)
* Add kerberos negotiate auth support ([PR #555](https://github.com/theforeman/hammer-cli-foreman/pull/555)), [#8923](http://projects.theforeman.org/issues/8923)
* Pin mocha gem to < 1.14.0
* Force api docs checksum check, [#28283](http://projects.theforeman.org/issues/28283)
* Add template report-remplate and partition-table export command ([PR #595](https://github.com/theforeman/hammer-cli-foreman/pull/595)), [#34503](http://projects.theforeman.org/issues/34503)
* Add template import and partition-table import commands ([PR #596](https://github.com/theforeman/hammer-cli-foreman/pull/596)), [#22692](http://projects.theforeman.org/issues/22692)
* Add resource information to download command ([PR #598](https://github.com/theforeman/hammer-cli-foreman/pull/598)), [#34621](http://projects.theforeman.org/issues/34621)
* Add command to import ipv4 subnet from smart proxy ([PR #593](https://github.com/theforeman/hammer-cli-foreman/pull/593)), [#33255](http://projects.theforeman.org/issues/33255)
* Bump to 3.3.0-develop

### 3.2.0 (2022-02-10)
* Domain update doesn't reset dns implicitly ([PR #591](https://github.com/theforeman/hammer-cli-foreman/pull/591)), [#34177](http://projects.theforeman.org/issues/34177)
* Send filter's tax params only when required ([PR #592](https://github.com/theforeman/hammer-cli-foreman/pull/592)), [#34199](http://projects.theforeman.org/issues/34199)
* Add boot_order to compute-attribute ([PR #588](https://github.com/theforeman/hammer-cli-foreman/pull/588)), [#33910](http://projects.theforeman.org/issues/33910)
* Add mail_enabled to user list/info command ([PR #589](https://github.com/theforeman/hammer-cli-foreman/pull/589)), [#34180](http://projects.theforeman.org/issues/34180)
* Add token to host info command ([PR #586](https://github.com/theforeman/hammer-cli-foreman/pull/586)), [#34120](http://projects.theforeman.org/issues/34120)
* Bump to 3.2.0-develop

### 3.1.0 (2021-11-10)
* Update test data for 3.1
* Make sure provided options override defaults, [#33711](http://projects.theforeman.org/issues/33711)
* Make template create/update commands use resolver, [#33721](http://projects.theforeman.org/issues/33721)
* Revert fix rake version
* Fix rake version
* Show status once for proxy info ([PR #581](https://github.com/theforeman/hammer-cli-foreman/pull/581)), [#19510](http://projects.theforeman.org/issues/19510)
* Add proxy status and version to info command ([PR #572](https://github.com/theforeman/hammer-cli-foreman/pull/572))
* Associate a vm via hammer to a compute resource, [#33047](http://projects.theforeman.org/issues/33047)
* Fix option builders and tests, [#33226](http://projects.theforeman.org/issues/33226)
* Bump to 3.1.0-develop
* Add parent title option for hostgroup, [#32878](http://projects.theforeman.org/issues/32878)

### 3.0.0 (2021-08-04)
* Puppet extraction ([PR #571](https://github.com/theforeman/hammer-cli-foreman/pull/571)), [#33174](http://projects.theforeman.org/issues/33174)
* Update rel-eng notebook ([PR #573](https://github.com/theforeman/hammer-cli-foreman/pull/573))
* Bump version to 3.0-develop
* Deprecate root-pass and remove deprecation warning, [#22574](http://projects.theforeman.org/issues/22574)
* Return org and loc options to all hammer commands ([PR #575](https://github.com/theforeman/hammer-cli-foreman/pull/575)), [#32872](http://projects.theforeman.org/issues/32872)
*  prevent full-help from failure if apidoc not available ([PR #574](https://github.com/theforeman/hammer-cli-foreman/pull/574)), [#32861](http://projects.theforeman.org/issues/32861)
* Show new msg for empty update commands, [#32454](http://projects.theforeman.org/issues/32454)
* Remove --environment deprecations ([PR #569](https://github.com/theforeman/hammer-cli-foreman/pull/569)), [#28862](http://projects.theforeman.org/issues/28862)
* Force name resolving due defaults, [#32392](http://projects.theforeman.org/issues/32392)
* Bump to 2.6.0-develop

### 2.5.0 (2021-05-04)
* Update test data to latest foreman
*  change to resource_type_label, [#11454](http://projects.theforeman.org/issues/11454)
* Display the report origin, [#32428](http://projects.theforeman.org/issues/32428)
* Apply option family on searchablesoptionbuilder, [#30996](http://projects.theforeman.org/issues/30996)
* Add associate vms command for compute resource ([PR #563](https://github.com/theforeman/hammer-cli-foreman/pull/563)), [#32271](http://projects.theforeman.org/issues/32271)
* Support unrecognized services in ping, [#32265](http://projects.theforeman.org/issues/32265)
* Change --owner_type's default to user ([PR #562](https://github.com/theforeman/hammer-cli-foreman/pull/562)), [#30814](http://projects.theforeman.org/issues/30814)
* Drop puppetrun command from hammer ([PR #561](https://github.com/theforeman/hammer-cli-foreman/pull/561)), [#31806](http://projects.theforeman.org/issues/31806)
* Global registration module ([PR #558](https://github.com/theforeman/hammer-cli-foreman/pull/558)), [#31630](http://projects.theforeman.org/issues/31630)
* Add support for vnic profile ([PR #552](https://github.com/theforeman/hammer-cli-foreman/pull/552)), [#31493](http://projects.theforeman.org/issues/31493)
* Bump to 2.5.0-develop
* Bump to 2.4.0
* Correct descriptions for resources, [#31668](http://projects.theforeman.org/issues/31668)


### 2.4.0 (2021-02-01)
* Fix hammer list failure when defaults are set ([PR #551](https://github.com/theforeman/hammer-cli-foreman/pull/551)), [#31384](http://projects.theforeman.org/issues/31384)
* Deprecating puppetrun command ([PR #554](https://github.com/theforeman/hammer-cli-foreman/pull/554)), [#31536](http://projects.theforeman.org/issues/31536)
* Set new owner with host update ([PR #556](https://github.com/theforeman/hammer-cli-foreman/pull/556)), [#31609](http://projects.theforeman.org/issues/31609)
* Consume structured statuses api data ([PR #553](https://github.com/theforeman/hammer-cli-foreman/pull/553)), [#31570](http://projects.theforeman.org/issues/31570)
* Added missing tests to filter ([PR #549](https://github.com/theforeman/hammer-cli-foreman/pull/549)), [#31074](http://projects.theforeman.org/issues/31074')
* Bump to 2.4.0-develop

### 2.3.0 (2020-11-03)
* Hammer ping skip authentication ([PR #550](https://github.com/theforeman/hammer-cli-foreman/pull/550)), [#31140](http://projects.theforeman.org/issues/31140)
* Return non-zero exit code if services failed, [#30496](http://projects.theforeman.org/issues/30496)
* Better option assignment for nested params ([PR #544](https://github.com/theforeman/hammer-cli-foreman/pull/544)), [#30910](http://projects.theforeman.org/issues/30910)
* Use parent resource instead of hardcoded one, [#30938](http://projects.theforeman.org/issues/30938)
* Added missing tests to setting, [#30886](http://projects.theforeman.org/issues/30886)
* Added missing tests to installation medium test, [#30805](http://projects.theforeman.org/issues/30805)
* Added missing tests to location test, [#30829](http://projects.theforeman.org/issues/30829)
* Added missing tests to organization test, [#30794](http://projects.theforeman.org/issues/30794)
* Added missing tests to audit test ([PR #537](https://github.com/theforeman/hammer-cli-foreman/pull/537)), [#30740](http://projects.theforeman.org/issues/30740)
* Use underscores in `login oauth` option values ([PR #536](https://github.com/theforeman/hammer-cli-foreman/pull/536)), [#30720](http://projects.theforeman.org/issues/30720)
* Drop trends from hammer-cli-foreman ([PR #535](https://github.com/theforeman/hammer-cli-foreman/pull/535)), [#30134](http://projects.theforeman.org/issues/30134)
* Added highly available option to ovirt ([PR #532](https://github.com/theforeman/hammer-cli-foreman/pull/532)), [#30494](http://projects.theforeman.org/issues/30494)
* Add ptables and realms to location and organization info ([PR #534](https://github.com/theforeman/hammer-cli-foreman/pull/534)), [#30663](http://projects.theforeman.org/issues/30663)
* Bump to 2.3.0-develop
* Bump to 2.2.0
* Added missing tests to user test, [#30593](http://projects.theforeman.org/issues/30593)

### 2.2.0 (2020-08-11)
* Change config templates to provisioning templates ([PR #531](https://github.com/theforeman/hammer-cli-foreman/pull/531)), [#29971](http://projects.theforeman.org/issues/29971)
* Fix minitest deprecation ([PR #523](https://github.com/theforeman/hammer-cli-foreman/pull/523))
* Add a coverage test ([PR #522](https://github.com/theforeman/hammer-cli-foreman/pull/522))
* Return 'set current context for request' to help ([PR #530](https://github.com/theforeman/hammer-cli-foreman/pull/530)), [#30182](http://projects.theforeman.org/issues/30182)
* Display request uuid for audit ([PR #528](https://github.com/theforeman/hammer-cli-foreman/pull/528)), [#30130](http://projects.theforeman.org/issues/30130)
* Use parent resource instead of hardcoded one ([PR #527](https://github.com/theforeman/hammer-cli-foreman/pull/527)), [#30125](http://projects.theforeman.org/issues/30125)
* Added missing tests to realm command ([PR #526](https://github.com/theforeman/hammer-cli-foreman/pull/526)), [#30096](http://projects.theforeman.org/issues/30096)
* Added missing tests to trend test ([PR #525](https://github.com/theforeman/hammer-cli-foreman/pull/525)), [#30070](http://projects.theforeman.org/issues/30070)
* Revert "skip one test on ruby 2.7" ([PR #520](https://github.com/theforeman/hammer-cli-foreman/pull/520)), [#28601](http://projects.theforeman.org/issues/28601)
* Eliminate auth_type from sessions file ([PR #521](https://github.com/theforeman/hammer-cli-foreman/pull/521)), [#29876](http://projects.theforeman.org/issues/29876)
* Add disable option for user ([PR #497](https://github.com/theforeman/hammer-cli-foreman/pull/497)), [#28973](http://projects.theforeman.org/issues/28973)
* Added manage command to user mail notifications ([PR #513](https://github.com/theforeman/hammer-cli-foreman/pull/513)), [#7665](http://projects.theforeman.org/issues/7665)
* Bump to 2.2.0-develop

### 2.1.0 (2020-05-14)
* Bump hammer_cli to 2.1.0 ([PR #519](https://github.com/theforeman/hammer-cli-foreman/pull/519))
* Ask for oauth code only when needed ([PR #517](https://github.com/theforeman/hammer-cli-foreman/pull/517)), [#29635](http://projects.theforeman.org/issues/29635)
* Possibility to create ipv6 subnet, [#28760](http://projects.theforeman.org/issues/28760)
* Add the ability to manage bookmarks ([PR #510](https://github.com/theforeman/hammer-cli-foreman/pull/510)), [#12845](http://projects.theforeman.org/issues/12845)
* Add aliases for info/list/delete commands ([PR #512](https://github.com/theforeman/hammer-cli-foreman/pull/512)), [#29413](http://projects.theforeman.org/issues/29413)
* Help contains squeezed options ([PR #489](https://github.com/theforeman/hammer-cli-foreman/pull/489)), [#28440](http://projects.theforeman.org/issues/28440)
* Add cr to hostgroup info, [#29140](http://projects.theforeman.org/issues/29140)
* Add rake task with plugin template
* Added virtual machine command for compute resource ([PR #469](https://github.com/theforeman/hammer-cli-foreman/pull/469)), [#20451](http://projects.theforeman.org/issues/20451)
* Add display options to host creation on ovirt ([PR #507](https://github.com/theforeman/hammer-cli-foreman/pull/507)), [#29254](http://projects.theforeman.org/issues/29254)
* Add mail notification command ([PR #509](https://github.com/theforeman/hammer-cli-foreman/pull/509)), [#29326](http://projects.theforeman.org/issues/29326)
* Use right param for os default template ([PR #508](https://github.com/theforeman/hammer-cli-foreman/pull/508)), [#29274](http://projects.theforeman.org/issues/29274)
* Update api docs to 2.1
* Correct hot add options ([PR #505](https://github.com/theforeman/hammer-cli-foreman/pull/505)), [#29253](http://projects.theforeman.org/issues/29253)
* Feature #28836 - allow multiple disassociating of provisioning templates ([PR #502](https://github.com/theforeman/hammer-cli-foreman/pull/502)), [#28836](http://projects.theforeman.org/issues/28836)
* Fixed updating host owner when ownertype is usergroup ([PR #501](https://github.com/theforeman/hammer-cli-foreman/pull/501)), [#11279](http://projects.theforeman.org/issues/11279)
* Remove duplicate api requests on addassociatedcommand ([PR #503](https://github.com/theforeman/hammer-cli-foreman/pull/503)), [#29096](http://projects.theforeman.org/issues/29096)
* Fix help for ovirt boolean values, [#29026](http://projects.theforeman.org/issues/29026)
* Deprecate --root-pass in host group, [#22573](http://projects.theforeman.org/issues/22573)
* Bump to 2.1.0-develop

### 2.0.0 (2020-02-12)
* Change the description of the scoped loc and org ([PR #494](https://github.com/theforeman/hammer-cli-foreman/pull/494)), [#28869](http://projects.theforeman.org/issues/28869)
* Fixes tests
* Bump version to 2.0.0
* Support associating multiple provisioning templates ([PR #484](https://github.com/theforeman/hammer-cli-foreman/pull/484)), [#19999](http://projects.theforeman.org/issues/19999)
* Add command for managing trends ([PR #488](https://github.com/theforeman/hammer-cli-foreman/pull/488)), [#12471](http://projects.theforeman.org/issues/12471)
* Bump hammer version 2.0 develop ([PR #491](https://github.com/theforeman/hammer-cli-foreman/pull/491))
* Host update doesn't delete assigned puppet classes, [#28899](http://projects.theforeman.org/issues/28899)
* Better promts for missing arguments, [#28793](http://projects.theforeman.org/issues/28793)
* Fix help for filter create command, [#28765](http://projects.theforeman.org/issues/28765)
* Fix host creation from image and hostgroup ([PR #471](https://github.com/theforeman/hammer-cli-foreman/pull/471)), [#28541](http://projects.theforeman.org/issues/28541)
* Remove deprecated permissions api parameters, [#28747](http://projects.theforeman.org/issues/28747)
* Drop smart variable handling ([PR #473](https://github.com/theforeman/hammer-cli-foreman/pull/473)), [#28599](http://projects.theforeman.org/issues/28599)
* Add auth source external command ([PR #480](https://github.com/theforeman/hammer-cli-foreman/pull/480)), [#28704](http://projects.theforeman.org/issues/28704)
* Fix unauthorized user error message ([PR #478](https://github.com/theforeman/hammer-cli-foreman/pull/478)), [#28646](http://projects.theforeman.org/issues/28646)
* Add specific oidc option information ([PR #475](https://github.com/theforeman/hammer-cli-foreman/pull/475)), [#28628](http://projects.theforeman.org/issues/28628)
* Fixes #28420: unpin mocha version & fix deprecation warning ([PR #476](https://github.com/theforeman/hammer-cli-foreman/pull/476)), [#28420](http://projects.theforeman.org/issues/28420)
* Fix undefined method  on wrong oidc token endpoint ([PR #479](https://github.com/theforeman/hammer-cli-foreman/pull/479)), [#28196](http://projects.theforeman.org/issues/28196)
* Remove dropped api endpoints from hammer, [#28610](http://projects.theforeman.org/issues/28610)
* Skip one test on ruby 2.7, [#28601](http://projects.theforeman.org/issues/28601)
* Increase id column width for available networks ([PR #468](https://github.com/theforeman/hammer-cli-foreman/pull/468)), [#28503](http://projects.theforeman.org/issues/28503)
* Remove url field from gce info ([PR #466](https://github.com/theforeman/hammer-cli-foreman/pull/466)), [#28135](http://projects.theforeman.org/issues/28135)
* Add organizations and locations http-proxy info command, [#28472](http://projects.theforeman.org/issues/28472)
* Added disk interface to ovirt vm creation help ([PR #462](https://github.com/theforeman/hammer-cli-foreman/pull/462)), [#28454](http://projects.theforeman.org/issues/28454)
* Help message change to support attributes names in ovirt ([PR #464](https://github.com/theforeman/hammer-cli-foreman/pull/464)), [#28464](http://projects.theforeman.org/issues/28464)
* Fixed help message for vmware network-id or name ([PR #465](https://github.com/theforeman/hammer-cli-foreman/pull/465)), [#19702](http://projects.theforeman.org/issues/19702)
* Update taxonomies for auth sources ([PR #461](https://github.com/theforeman/hammer-cli-foreman/pull/461)), [#28451](http://projects.theforeman.org/issues/28451)
* Restrict mocha to not use version > 1.9.0 ([PR #460](https://github.com/theforeman/hammer-cli-foreman/pull/460)), [#28417](http://projects.theforeman.org/issues/28417)
* Re-add owner-id output in hammer host info ([PR #459](https://github.com/theforeman/hammer-cli-foreman/pull/459)), [#28397](http://projects.theforeman.org/issues/28397)
* Add report-template import command ([PR #458](https://github.com/theforeman/hammer-cli-foreman/pull/458)), [#28098](http://projects.theforeman.org/issues/28098)
* Add images uuid to cr images ([PR #457](https://github.com/theforeman/hammer-cli-foreman/pull/457)), [#28132](http://projects.theforeman.org/issues/28132)
* Handle empty params for codegrant flow ([PR #456](https://github.com/theforeman/hammer-cli-foreman/pull/456)), [#28196](http://projects.theforeman.org/issues/28196)
* Add http-proxy to hammer ([PR #454](https://github.com/theforeman/hammer-cli-foreman/pull/454)), [#28176](http://projects.theforeman.org/issues/28176)
* Gce cr info shows zone field ([PR #455](https://github.com/theforeman/hammer-cli-foreman/pull/455)), [#28135](http://projects.theforeman.org/issues/28135)
* Handle error when empty parameters are passed ([PR #453](https://github.com/theforeman/hammer-cli-foreman/pull/453)), [#28196](http://projects.theforeman.org/issues/28196)
* Allow login in tty-less execution ([PR #452](https://github.com/theforeman/hammer-cli-foreman/pull/452)), [#28318](http://projects.theforeman.org/issues/28318)
* Allow adapters print page by page, [#17819](http://projects.theforeman.org/issues/17819)
* Add release documentation ([PR #451](https://github.com/theforeman/hammer-cli-foreman/pull/451)), [#28149](http://projects.theforeman.org/issues/28149)
* Fix method typo ([PR #450](https://github.com/theforeman/hammer-cli-foreman/pull/450)), [#27868](http://projects.theforeman.org/issues/27868)
* Bump to 0.20-develop
* Better prompts for missing arguments, [#27595](http://projects.theforeman.org/issues/27595)

### 0.19.0 (2019-10-26)
* Add option to support host's param type ([PR #448](https://github.com/theforeman/hammer-cli-foreman/pull/448)), [#27868](http://projects.theforeman.org/issues/27868)
* Adding sso func. through cli using openid-connect ([PR #405](https://github.com/theforeman/hammer-cli-foreman/pull/405)), [#25848](http://projects.theforeman.org/issues/25848)
* Ping command ([PR #394](https://github.com/theforeman/hammer-cli-foreman/pull/394)), [#3036](http://projects.theforeman.org/issues/3036), [#12587](http://projects.theforeman.org/issues/12587), [#3956](http://projects.theforeman.org/issues/3956)
* Add description field to templates ([PR #449](https://github.com/theforeman/hammer-cli-foreman/pull/449)), [#27997](http://projects.theforeman.org/issues/27997)
* New lines in text attr dont break output ([PR #415](https://github.com/theforeman/hammer-cli-foreman/pull/415)), [#25878](http://projects.theforeman.org/issues/25878)
* Fixed inconsistent in output format, [#27597](http://projects.theforeman.org/issues/27597)
* Added gateway to subnet list, [#27596](http://projects.theforeman.org/issues/27596)
* Improve help for compute resources, [#25584](http://projects.theforeman.org/issues/25584)
* Fix interfaces when creating a host ([PR #439](https://github.com/theforeman/hammer-cli-foreman/pull/439)), [#27652](http://projects.theforeman.org/issues/27652)
* Additional compute resource attrs for ovirt ([PR #440](https://github.com/theforeman/hammer-cli-foreman/pull/440)), [#27554](http://projects.theforeman.org/issues/27554)
* Change the search fields to search / order fields, [#27602](http://projects.theforeman.org/issues/27602)
* Update docs for scl ruby to include bundle exec

### 0.18.0 (2019-08-01)
* Report template schedule works with --name ([#27339](http://projects.theforeman.org/issues/27339))
* Possibility to change host loc/org via hammer ([PR #416](https://github.com/theforeman/hammer-cli-foreman/pull/416)) ([#26536](http://projects.theforeman.org/issues/26536))
* Consider value not display name of compute_resource ([PR #432](https://github.com/theforeman/hammer-cli-foreman/pull/432)) ([#27343](http://projects.theforeman.org/issues/27343))
* Return missing helper methods for host ([#27444](http://projects.theforeman.org/issues/27444))
* Customize CR fields using provider_specific_fields ([#27342](http://projects.theforeman.org/issues/27342))
* Added volume attributes for GCE ([#27342](http://projects.theforeman.org/issues/27342))
* Add additional keys in GCE compute resource ([#27342](http://projects.theforeman.org/issues/27342))
* Adds project domain flags ([#26668](http://projects.theforeman.org/issues/26668))
* Remove duplicate options ([#27375](http://projects.theforeman.org/issues/27375))
* Full-help doesn't asks for credentials ([#26894](http://projects.theforeman.org/issues/26894))
* Update environments options for puppet context ([#27323](http://projects.theforeman.org/issues/27323))
* Report template schedule shows job ID ([#27341](http://projects.theforeman.org/issues/27341))
* Host creation with multi SCSI controllers ([#25093](http://projects.theforeman.org/issues/25093), [#26421](http://projects.theforeman.org/issues/26421))
* Add Location and Description Fields ([#21764](http://projects.theforeman.org/issues/21764))
* Create hostgroup with puppet classes ([#24717](http://projects.theforeman.org/issues/24717))
* Consistent puppet environment naming in hammer ([#23204](http://projects.theforeman.org/issues/23204))
* Add abstraction for subcommand searching ([PR #342](https://github.com/theforeman/hammer-cli-foreman/pull/342)) ([#21674](http://projects.theforeman.org/issues/21674))
* Possibility to limit fields that are displayed ([PR #407](https://github.com/theforeman/hammer-cli-foreman/pull/407)) ([#19135](http://projects.theforeman.org/issues/19135))
* action for false:FalseClass ([#26865](http://projects.theforeman.org/issues/26865))
* Move image_id to the compute_attributes ([#6159](http://projects.theforeman.org/issues/6159))

### 0.17.0 (2019-04-24)
* Add public key option in create compute resource CLI ([#25491](http://projects.theforeman.org/issues/25491))
* Background template rendering ([PR #414](https://github.com/theforeman/hammer-cli-foreman/pull/414)) ([#26355](http://projects.theforeman.org/issues/26355))
* Parameter type to parameter commands ([#26008](http://projects.theforeman.org/issues/26008))
* New API data that needed for parameter_type fix ([#26008](http://projects.theforeman.org/issues/26008))
* parameter_type option to parameter commands ([#26008](http://projects.theforeman.org/issues/26008))
* Move compute resource validation to their class ([#26234](http://projects.theforeman.org/issues/26234))
* Improve documentation of id fields in ovirt ([#26334](http://projects.theforeman.org/issues/26334))
* Add rebuild-config subcommand for hostgroups ([#26129](http://projects.theforeman.org/issues/26129))
* Add compute profile commands ([PR #398](https://github.com/theforeman/hammer-cli-foreman/pull/398)) ([#20538](http://projects.theforeman.org/issues/20538))
* Display uptime ([#26019](http://projects.theforeman.org/issues/26019))
* Hammer host update and set-parameters need clarification ([#25964](http://projects.theforeman.org/issues/25964))

### 0.16.0 (2019-01-16)
* Use make targets for translations from core ([#25724](http://projects.theforeman.org/issues/25724))
* Allow mixing option sources and validations ([PR #402](https://github.com/theforeman/hammer-cli-foreman/pull/402)) ([#22253](http://projects.theforeman.org/issues/22253))
* Include information about search fields ([#11431](http://projects.theforeman.org/issues/11431))
* IPv6 subnet option in hostgroup create/update ([#18752](http://projects.theforeman.org/issues/18752))
* Tests for message formats ([#7451](http://projects.theforeman.org/issues/7451))
* Report templates - inputs, clone, interactive updates ([#24489](http://projects.theforeman.org/issues/24489))
* Update API doc in tests to match Foreman 1.20 ([#25376](http://projects.theforeman.org/issues/25376))
* Add a command for report templates ([#24489](http://projects.theforeman.org/issues/24489))
* Re-add --thin into host list ([PR #395](https://github.com/theforeman/hammer-cli-foreman/pull/395)) ([#25349](http://projects.theforeman.org/issues/25349))
* Request password regardless of redirection ([#14832](http://projects.theforeman.org/issues/14832))

### 0.15.0 (2018-10-24)
* Use SPDX 2.0 codes
* Provides a way of listing compute attribute values ([#3651](http://projects.theforeman.org/issues/3651))
* Foreman CLI command for BMC boot commands ([#24099](http://projects.theforeman.org/issues/24099))
* Update VMware helpers and host create page ([#25192](http://projects.theforeman.org/issues/25192))
* Enable structured formatters for refernces. ([#24980](http://projects.theforeman.org/issues/24980))
* Correct homepage and license in the gemspec
* Display Host Status in Hammer ([#20187](http://projects.theforeman.org/issues/20187))
* Subnet create/update should accept proxy names ([#20609](http://projects.theforeman.org/issues/20609))
* Add Cluster option to Hammer CR. ([#24748](http://projects.theforeman.org/issues/24748))
* Retain data while host update in hammer ([#20725](http://projects.theforeman.org/issues/20725))

### 0.14.0 (2018-08-27)
* Add template combinations commands ([#3969](http://projects.theforeman.org/issues/3969))
* Fix and extend tests for user update ([#23996](http://projects.theforeman.org/issues/23996))
* Hammer asks for user password though -p option provided ([#23996](http://projects.theforeman.org/issues/23996))
* Stop overriding apipie help for host flags ([PR #380](https://github.com/theforeman/hammer-cli-foreman/pull/380)) ([#24490](http://projects.theforeman.org/issues/24490))
* Hammer report info doesn't show logs resources and messages ([PR #375](https://github.com/theforeman/hammer-cli-foreman/pull/375)) ([#12189](http://projects.theforeman.org/issues/12189))
* Remove legacy code for Ruby < 2.0 ([#21360](http://projects.theforeman.org/issues/21360))
* Add disassociate command to host ([#15674](http://projects.theforeman.org/issues/15674))
* Align subnet translations in hammer with UI ([#9906](http://projects.theforeman.org/issues/9906))
* Propagate the error message from core ([#24285](http://projects.theforeman.org/issues/24285))
* Hammer uses /config_reports rather than /reports ([PR #374](https://github.com/theforeman/hammer-cli-foreman/pull/374)) ([#14510](http://projects.theforeman.org/issues/14510))
* Setting list should show full names ([#20360](http://projects.theforeman.org/issues/20360))
* Show cidr notation ([#22988](http://projects.theforeman.org/issues/22988))
* Removed redundant info about OS from hostgroup ([#23722](http://projects.theforeman.org/issues/23722))
* Add MTU to subnet info ([#23401](http://projects.theforeman.org/issues/23401))

### 0.13.0 (2018-05-09)
* Listing all auth sources ([#19651](http://projects.theforeman.org/issues/19651))
* Tests are green with 1.18 API docs ([#23219](http://projects.theforeman.org/issues/23219))
* Add commands for Audits ([#2921](http://projects.theforeman.org/issues/2921))
* fix logging by requiring logger ([PR #364](https://github.com/theforeman/hammer-cli-foreman/pull/364)) ([#23108](http://projects.theforeman.org/issues/23108))
* Add personal access token cli support ([#21514](http://projects.theforeman.org/issues/21514))
* Update to API doc form 1.17 ([PR #362](https://github.com/theforeman/hammer-cli-foreman/pull/362)) ([#22989](http://projects.theforeman.org/issues/22989))
* Improve class import output ([#4609](http://projects.theforeman.org/issues/4609))
* Some numeric options are no longer recognized as numeric ([#22964](http://projects.theforeman.org/issues/22964))
* Pull in the latest strings from Dev ([#22866](http://projects.theforeman.org/issues/22866))
* Temporary fix for override values ([#22751](http://projects.theforeman.org/issues/22751))
* Raise error when wrong number of ids is resolved ([#22718](http://projects.theforeman.org/issues/22718))
* Puppetrun command is moved from hosts to puppet hosts ([#22658](http://projects.theforeman.org/issues/22658))
* Hammer should provide commands for showing host's ENC YAML ([#16423](http://projects.theforeman.org/issues/16423))
* Remove deprecation warning from --root-password in host create/update ([#18636](http://projects.theforeman.org/issues/18636))

### 0.12.0 (2018-02-19)
* Do not resolve already resolved id params ([#22517](http://projects.theforeman.org/issues/22517))
* Generate --provision-method from apidoc ([#22552](http://projects.theforeman.org/issues/22552))
* Review whitespace in extracted strings ([#7451](http://projects.theforeman.org/issues/7451))
* Allow nil searchables ([#21768](http://projects.theforeman.org/issues/21768))
* Fix typo for hostgroup in functional test ([#22094](http://projects.theforeman.org/issues/22094))
* Rename add-override-value to add-matcher ([#12999](http://projects.theforeman.org/issues/12999))
* Handle 400 bad request - concat response message ([#21627](http://projects.theforeman.org/issues/21627))
* Make hammer host reports work ([#20742](http://projects.theforeman.org/issues/20742))
* "unknown template kind" message translated ([#4573](http://projects.theforeman.org/issues/4573))
* Add status for Void authenticator ([#20505](http://projects.theforeman.org/issues/20505))
* Add show command for ssh-keys ([#20476](http://projects.theforeman.org/issues/20476))
* Add org/loc in ptable info command ([#21264](http://projects.theforeman.org/issues/21264))
* Create compute-resource VMware - URL optional ([#17568](http://projects.theforeman.org/issues/17568))
* Test to expect integer params as a number ([#21013](http://projects.theforeman.org/issues/21013))
* Add ssh-keys commands ([#20476](http://projects.theforeman.org/issues/20476))
* Remove --include and --thin from host-hostgroup list ([#20754](http://projects.theforeman.org/issues/20754))
* Added fields info to hostgroup/host info command ([#18750](http://projects.theforeman.org/issues/18750))
* Don't store session_id for unauthorized responses ([#20575](http://projects.theforeman.org/issues/20575))
* Owner Name is shown in hammer host info command ([#20709](http://projects.theforeman.org/issues/20709))
* Show empty table field with ReferenceFormatter ([#20758](http://projects.theforeman.org/issues/20758))
* Better logging of 403 responses ([#20120](http://projects.theforeman.org/issues/20120))
* Update documentation for sessions ([#20315](http://projects.theforeman.org/issues/20315))

### 0.11.0 (2017-08-01)
* Adding a list normalizer to override-value-order ([#17135](http://projects.theforeman.org/issues/17135))
* Correctly reset taxonomies for overriding filters ([#20117](http://projects.theforeman.org/issues/20117))
* Sessions mutually exclusive with basic auth ([#20315](http://projects.theforeman.org/issues/20315))
* Disable auth login when sessions are off ([#19602](http://projects.theforeman.org/issues/19602))
* Add all_parameters to host info ([#20286](http://projects.theforeman.org/issues/20286))
* Fix Hammer-cli display groups base dn ([#20227](http://projects.theforeman.org/issues/20227))
* Fix Hammer-cli current user password update ([#18005](http://projects.theforeman.org/issues/18005))
* Don't send snippet flag when --type is undefined ([#20145](http://projects.theforeman.org/issues/20145))
* Fix merging .edit.po into .po files ([#17671](http://projects.theforeman.org/issues/17671))
* Enable taxonomy titles ([#19157](http://projects.theforeman.org/issues/19157))
* Provide default exception handler ([#19470](http://projects.theforeman.org/issues/19470))
* Accept hostgroup title in host create ([#19048](http://projects.theforeman.org/issues/19048))
* Retry command on session expiry ([#19431](http://projects.theforeman.org/issues/19431))
* More detailed instructions on SSL verification fail ([#19390](http://projects.theforeman.org/issues/19390))
* Add additional attributes on user list command ([#4396](http://projects.theforeman.org/issues/4396))
* Add description to hostgroup ([#19361](http://projects.theforeman.org/issues/19361))
* Require apipie-bindings >= 0.2.0 ([#19362](http://projects.theforeman.org/issues/19362))
* Require rest-client >= 1.8.0 ([#19358](http://projects.theforeman.org/issues/19358))
* Rustom error for 401 unauthorized ([#19362](http://projects.theforeman.org/issues/19362))
* Correctly resolve empty arrays ([#18742](http://projects.theforeman.org/issues/18742))
* Use Array for empty attributes ([#19312](http://projects.theforeman.org/issues/19312))
* Compute-resources has images subcommand ([#19156](http://projects.theforeman.org/issues/19156))
* Prevent sending nil values in hostgroup update ([#14872](http://projects.theforeman.org/issues/14872))
* Install server CA cert without root access ([#19083](http://projects.theforeman.org/issues/19083))
* Add description to subnet ([#19172](http://projects.theforeman.org/issues/19172))
* Replaces --subnet-parameters-attributes with parameter commands ([#18663](http://projects.theforeman.org/issues/18663))
* Make session authenticator compatible with rest-client 1.8 ([#19159](http://projects.theforeman.org/issues/19159))
* Add vlan id field to subnet ([#19134](http://projects.theforeman.org/issues/19134))

### 0.10.0 (2017-03-28)
* Adding --hidden-value option to parameters (#290) ([#18878](http://projects.theforeman.org/issues/18878))
* Add command to clone user role ([#18318](http://projects.theforeman.org/issues/18318))
* Default organization/location work with authenticators ([#17936](http://projects.theforeman.org/issues/17936))
* Display hostgroup title on host actions ([#18739](http://projects.theforeman.org/issues/18739))
* Respect original request_params ([#18790](http://projects.theforeman.org/issues/18790))
* Rename config template to provisioning template ([#18654](http://projects.theforeman.org/issues/18654))
* User create/update accepts organization/location name ([#17923](http://projects.theforeman.org/issues/17923))
* Skip generating option --root-pass for host create ([#18337](http://projects.theforeman.org/issues/18337))
* Session authenticator keeps asking for user ([#18170](http://projects.theforeman.org/issues/18170))
* Host create uses name options ([#18339](http://projects.theforeman.org/issues/18339))
* Only include .mo files below locale/ ([#18439](http://projects.theforeman.org/issues/18439))
* Add config group commands ([#7520](http://projects.theforeman.org/issues/7520))
* Poweroff hosts when using --force option ([#18319](http://projects.theforeman.org/issues/18319))
* Resolve subnet and domain for host create/update (#273) ([#17247](http://projects.theforeman.org/issues/17247))
* Prevent from setting taxonomies for non-overriding filters ([#17730](http://projects.theforeman.org/issues/17730))

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

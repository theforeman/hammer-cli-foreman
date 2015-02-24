%global gemname hammer_cli_foreman
%global confdir hammer

%if 0%{?rhel} < 7
%global gem_dir /usr/lib/ruby/gems/1.8
%endif

%global geminstdir %{gem_dir}/gems/%{gemname}-%{version}

Summary: Universal command-line interface for Foreman
Name: rubygem-%{gemname}
Version: 0.1.4.3
Release: 1%{?dist}
Group: Development/Languages
License: GPLv3
URL: http://github.com/theforeman/hammer-cli-foreman
Source0: %{gemname}-%{version}.gem
Source1: foreman.yml

%if !(0%{?rhel} > 6 || 0%{?fedora} > 18)
Requires: ruby(abi)
%endif

Requires: ruby(rubygems)
Requires: rubygem(hammer_cli) >= 0.1.1
Requires: rubygem(apipie-bindings) >= 0.0.8
BuildRequires: ruby(rubygems)
%if 0%{?fedora} || 0%{?rhel} > 6
BuildRequires: rubygems-devel
%endif
BuildRequires: ruby
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
Hammer cli provides universal extendable CLI interface for ruby apps


%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}


%prep
%setup -n %{gemname}-%{version} -T -c
mkdir -p .%{gem_dir}
gem install --local --install-dir .%{gem_dir} \
            --force %{SOURCE0}

%install
mkdir -p %{buildroot}%{_sysconfdir}/%{confdir}/cli.modules.d
install -m 755 %{SOURCE1} %{buildroot}%{_sysconfdir}/%{confdir}/cli.modules.d/foreman.yml
mkdir -p %{buildroot}%{gem_dir}
cp -pa .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

%files
%dir %{geminstdir}
%{geminstdir}/config
%{geminstdir}/lib
%{geminstdir}/locale
%config(noreplace) %{_sysconfdir}/%{confdir}/cli.modules.d/foreman.yml
%exclude %{gem_dir}/cache/%{gemname}-%{version}.gem
%{gem_dir}/specifications/%{gemname}-%{version}.gemspec

%files doc
%doc %{gem_dir}/doc/%{gemname}-%{version}
%doc %{geminstdir}/doc/release_notes.md
%doc %{geminstdir}/README.md
%doc %{geminstdir}/doc/host_create.md
%doc %{geminstdir}/doc/configuration.md
%doc %{geminstdir}/test
%doc %{geminstdir}/doc/developer_docs.md
%doc %{geminstdir}/doc/option_builder.md
%doc %{geminstdir}/doc/name_id_resolution.md

%changelog
* Tue Jan 27 2015 Jason Montleon <jmontleo@redhat.com> 0.1.4.3-1
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.1.0
  (jmontleo@redhat.com)
- fixes #3630 - adds dns name association to domain cli (cfouant@redhat.com)

* Tue Jan 20 2015 Jason Montleon <jmontleo@redhat.com> 0.1.4.2-1
- package config (jmontleo@redhat.com)

* Tue Jan 20 2015 Jason Montleon <jmontleo@redhat.com> 0.1.4.1-1
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.1.0
  (jmontleo@redhat.com)
- Fixes #7187 - List of host facts is shown correctly (orabin@redhat.com)
- Fixes #8829 - add config directory to gemspec (kvedulv@kvedulv.de)
- fixes #3898 - list commands should not be interactive for csv output
  (tcaspy@gmail.com)
- i18n - extracting new, pulling from tx (martin.bacovsky@gmail.com)
- Bump to 0.1.4 (martin.bacovsky@gmail.com)
- Fixes #8651 - sending puppet class ids (tstrachota@redhat.com)
- Fixes #8642 - setting --puppet-class-ids on host create/update throws api
  exception (tstrachota@redhat.com)
- Fixes #8299 - adding name equivalents to params in host/hostgroup
  create/update (tstrachota@redhat.com)
- Fixes #8246 - plural resolution (tstrachota@redhat.com)
- Fixes #5556 - missing search option error message (tstrachota@redhat.com)

* Tue Jan 13 2015 Jason Montleon <jmontleo@redhat.com> 0.1.3.3-1
- install foreman.yml from SOURCE1 (jmontleo@redhat.com)

* Tue Jan 13 2015 Jason Montleon <jmontleo@redhat.com> 0.1.3.2-1
- add foreman.yml source to rpm spec (jmontleo@redhat.com)

* Tue Jan 13 2015 Jason Montleon <jmontleo@redhat.com> 0.1.3.1-1
- update versioning (jmontleo@redhat.com)

* Tue Dec 09 2014 Jason Montleon <jmontleo@redhat.com> 0.1.3-2
- fix rpm spec to include unpackaged new file (jmontleo@redhat.com)

* Tue Dec 09 2014 Jason Montleon <jmontleo@redhat.com> 0.1.3-1
- use distribution tagger (jmontleo@redhat.com)
- update to 0.1.3

* Wed Aug 27 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-16
- Refs BZ#1097672 - removed credentials from config file (mbacovsk@redhat.com)

* Wed Jul 30 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-15
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.4
  (jmontleo@redhat.com)
- Fixes #6766 - Pagination is failing (martin.bacovsky@gmail.com)

* Tue Jul 29 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-14
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.4
  (jmontleo@redhat.com)
- Fixes #6779: Restrict ci_reporter gem to less than 2.0.0 to fix CI
  (martin.bacovsky@gmail.com)
- fixes #3387 - add proxy refresh-features command (dcleal@redhat.com)
- Fixed simplecov dependences (martin.bacovsky@gmail.com)
- Fixes #6343 - params from searchables are not wrapped
  (martin.bacovsky@gmail.com)

* Tue Jul 22 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-13
- update foreman.yml (jmontleo@redhat.com)

* Tue Jul 15 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-12
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.4
  (jmontleo@redhat.com)
- Merge pull request #135 from tstrachota/roles (martin.bacovsky@gmail.com)
- Refs #2922 - tests updated to use apidoc export for v1.6
  (tstrachota@redhat.com)
- fix (tstrachota@redhat.com)
- Fixes #2922 and #4004 - commands for managing roles, filters, permissions and
  usergroups (tstrachota@redhat.com)

* Mon Jul 14 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-11
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.4
  (jmontleo@redhat.com)
- Fixes #6534 - rest-client > 1.7 does not support ruby 1.8
  (tstrachota@redhat.com)
- update releasers (jmontleo@redhat.com)

* Tue Jul 08 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-10
- Merge pull request #130 from domcleal/6343-nested-resolver
  (martin.bacovsky@gmail.com)
- fixes #6478 - obey refresh_cache default of false (dcleal@redhat.com)
- ref #6203 - creating a more generic hook for search_options, BZ1108905
  (komidore64@gmail.com)
- fixes #6335 - permit only --hostgroup when creating host (dcleal@redhat.com)
- Merge pull request #128 from tstrachota/aliases (tstrachota@redhat.com)
- Fixes #6093 - better option descriptions (tstrachota@redhat.com)
- Fixes #6092 - mapping resource names in options (tstrachota@redhat.com)
- fixes #6219 - add --server cli option (thomasmckay@redhat.com)
- Fixes #6090 - fix for wrong parameters in proxy import
  (tstrachota@redhat.com)
- Refs #6090 - resolving ids in foreman base command (tstrachota@redhat.com)
- Merge pull request #125 from tstrachota/opts2 (tstrachota@redhat.com)
- Refs #5747 - Documentation for fine grained control over name expansion
  (tstrachota@redhat.com)
- Fixes #5747 - Fine grained control over name expansion
  (tstrachota@redhat.com)
- Merge pull request #124 from mbacovsky/3512_associated_descrs
  (tstrachota@redhat.com)
- Refs #5873 - scoped options were not cleaning original options
  (tstrachota@redhat.com)
- Fixes #5873 - list actions don't resolve ids for optional parameters
  (tstrachota@redhat.com)
- Fixes #3512 - help for associating commands is too generic
  (martin.bacovsky@gmail.com)

* Wed Jun 11 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-9
- Fixes #6090 - fix for wrong parameters in proxy import
  (tstrachota@redhat.com)
- Refs #6090 - resolving ids in foreman base command (tstrachota@redhat.com)

* Wed Jun 04 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-8
- package new docs files (jmontleo@redhat.com)

* Wed Jun 04 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-7
- Refs #5747 - Documentation for fine grained control over name expansion
  (tstrachota@redhat.com)
- Fixes #5747 - Fine grained control over name expansion
  (tstrachota@redhat.com)
- Refs #5873 - scoped options were not cleaning original options
  (tstrachota@redhat.com)
- Fixes #5873 - list actions don't resolve ids for optional parameters
  (tstrachota@redhat.com)

* Wed Jun 04 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-6
- Fixes #3512 - help for associating commands is too generic
  (martin.bacovsky@gmail.com)

* Wed May 28 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-5
- update dependencies in rpm spec for 0.1.1 (jmontleo@redhat.com)

* Wed May 28 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-4
- Revert "Revert "Bump to 0.1.1"" (jmontleo@redhat.com)

* Wed May 28 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-3
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.3
  (jmontleo@redhat.com)
- Revert "revert version to 0.1.0 for time being" (jmontleo@redhat.com)
- refs #5793 - add pkg:generate_source task to generate gem (dcleal@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-15
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com>
- revert version to 0.1.0 for time being (jmontleo@redhat.com)
- Revert "Bump to 0.1.1" (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-2
- add release_notes.md to package (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com> 0.1.1-1
- bump version to 0.1.1 (jmontleo@redhat.com)

* Thu May 22 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-14
- update apipie-bindings dep in rpm spec file (jmontleo@redhat.com)
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.3
  (jmontleo@redhat.com)
- Merge pull request #121 from tstrachota/release_notes
  (martin.bacovsky@gmail.com)
- Release notes (tstrachota@redhat.com)
- Bump to 0.1.1 (martin.bacovsky@gmail.com)
- Refs #3102 - temporary fix for api not returning param values for hosts
  (tstrachota@redhat.com)
- Merge pull request #119 from mbacovsky/4478_localized_api
  (tstrachota@redhat.com)
- Refs #4478 - support for API lacalization (martin.bacovsky@gmail.com)
- Refs #3102 - reference definition turned into functions
  (tstrachota@redhat.com)
- More readable output of failed tests for column presence
  (tstrachota@redhat.com)
- Fixes #3102 - listing associated resources (tstrachota@redhat.com)

* Sat May 17 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-13
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.3
  (jmontleo@redhat.com)
- Merge pull request #116 from tstrachota/resolver (martin.bacovsky@gmail.com)
- Refs #5598 - fancy names for all id options (tstrachota@redhat.com)
- refs #3272 - default password will be going away (dcleal@redhat.com)
- Fixes #5657 - Latest string extract (bkearney@redhat.com)

* Wed May 07 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-12
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.3
  (jmontleo@redhat.com)
- Fixes #5209 - setting infinite timeouts (tstrachota@redhat.com)

* Tue May 06 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-11
- add new file to package file list (jmontleo@redhat.com)

* Tue May 06 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-10
- Merge remote-tracking branch 'upstream/master' into SATELLITE-6.0.3
  (jmontleo@redhat.com)
- FIxes #5209 - negative timeout config value causes errors
  (tstrachota@redhat.com)
- Refs #4311 - additional tests for the id resolver and option builders
  (tstrachota@redhat.com)
- removed log_api_calls setting (tstrachota@redhat.com)
- Refs #4311 - single resource command, associated list command
  (tstrachota@redhat.com)
- Refs #4311 - test fixes (tstrachota@redhat.com)
- fix in String#format (tstrachota@redhat.com)
- Refs #4311 - get_resource_id refactoring (tstrachota@redhat.com)
- Refs #4311 - read and write commands merged (tstrachota@redhat.com)
- Fixes #4311 - searchables, id resolver and option builders
  (tstrachota@redhat.com)

* Fri May 02 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-9
- remove erroniously added README (jmontleo@redhat.com)

* Fri May 02 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-8
- Adjust macros to work with EL7 and rebuild

* Fri May 02 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-7
- make packaging changes to support RHEL 7 (jmontleo@redhat.com)
* Mon Mar 31 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-6
- Merge remote-tracking branch 'upstream/master' (jmontleo@redhat.com)
- Merge pull request #97 from StephanDollberg/3970_os_default_template
  (tstrachota@redhat.com)
- fixes 3970 - adds support for os default templates
  (stephan.dollberg@gmail.com)

* Thu Mar 27 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-5
- update confdir (jmontleo@redhat.com)

* Thu Mar 27 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-4
- update yml config location (jmontleo@redhat.com)

* Wed Mar 26 2014 Jason Montleon <jmontleo@redhat.com> 0.1.0-3
- update rpm spec file to match upstream and add foreman.yml config
  (jmontleo@redhat.com)

* Wed Mar 26 2014 Jason Montleon <jmontleo@redhat.com>
- update rpm spec file to match upstream and add foreman.yml config
  (jmontleo@redhat.com)

* Wed Mar 26 2014 Jason Montleon <jmontleo@redhat.com>
- update rpm spec file to match upstream and add foreman.yml config
  (jmontleo@redhat.com)

* Wed Mar 26 2014 Jason Montleon <jmontleo@redhat.com>
- update rpm spec file to match upstream and add foreman.yml config
  (jmontleo@redhat.com)

* Wed Jan 29 2014 Martin Bačovský <mbacovsk@redhat.com> 0.0.18-1
- Bump to 0.0.18 (mbacovsk@redhat.com)

* Thu Jan 23 2014 Martin Bačovský <mbacovsk@redhat.com> 0.0.17-1
- Bump to 0.0.17 (mbacovsk@redhat.com)

* Tue Jan 21 2014 Martin Bačovský <mbacovsk@redhat.com> 0.0.16-1
- Bump to 0.0.16 (mbacovsk@redhat.com)

* Thu Dec 19 2013 Martin Bačovský <mbacovsk@redhat.com> 0.0.15-1
- Bump to 0.0.15 (mbacovsk@redhat.com)

* Wed Dec 18 2013 Martin Bačovský <mbacovsk@redhat.com> 0.0.13-1
- Bump to 0.0.13 (mbacovsk@redhat.com)

* Thu Dec 05 2013 Martin Bačovský <mbacovsk@redhat.com> 0.0.12-1
- Bump to 0.0.12 (mbacovsk@redhat.com)

* Tue Nov 26 2013 Martin Bačovský <mbacovsk@redhat.com> 0.0.11-1
- Bump to 0.0.11 (mbacovsk@redhat.com)

* Fri Nov 08 2013 Martin Bačovský <mbacovsk@redhat.com> 0.0.10-1
- bump to 0.0.10 (mbacovsk@redhat.com)
- updated dependencies

* Mon Nov 04 2013 Dominic Cleal <dcleal@redhat.com> 0.0.9-2
- Mark cli_config.yml as a config file (dcleal@redhat.com)
- Update default config for Foreman installation and non-root users
  (dcleal@redhat.com)

* Tue Oct 29 2013 Tomas Strachota <tstrachota@redhat.com> 0.0.9-1
- Update to Hammer CLI Foreman 0.0.9

* Wed Oct 23 2013 Martin Bačovský <mbacovsk@redhat.com> 0.0.8-1
- Rebase to 0.0.8 (mbacovsk@redhat.com)

* Thu Oct 10 2013 Martin Bačovský <mbacovsk@redhat.com> 0.0.7-1
- Bumped to 0.0.7 (mbacovsk@redhat.com)
- Fixed default config file
- remove deps on awesome_print and terminal-table

* Tue Oct 08 2013 Tomas Strachota <tstrachota@redhat.com> 0.0.6-1
- Update to the latest version of Hammer CLI Foreman

* Thu Sep 26 2013 Sam Kottler <shk@redhat.com> 0.0.5-1
- Bump the version in the spec (shk@redhat.com)
- Update to the latest version (shk@redhat.com)

* Mon Aug 26 2013 Sam Kottler <shk@redhat.com> 0.0.3-2
- Use rubygems-devel on fedora instead of custom macros (shk@redhat.com)

* Mon Aug 26 2013 Sam Kottler <shk@redhat.com> 0.0.3-1
- Remove the 0.0.1 gem bin (shk@redhat.com)
- Bump to version 0.0.3 (shk@redhat.com)

* Thu Aug 15 2013 Sam Kottler <shk@redhat.com> 0.0.1-5
- Add configuration to install (shk@redhat.com)

* Thu Aug 15 2013 Sam Kottler <shk@redhat.com> 0.0.1-4
- Version bump for rebuild

* Thu Aug 15 2013 Sam Kottler <shk@redhat.com> 0.0.1-3
- Bump version

* Thu Aug 15 2013 Sam Kottler <shk@redhat.com>
- Initial import of the gem (shk@redhat.com)

* Thu Aug 15 2013 Sam Kottler <shk@redhat.com> - 0.0.1-1
- Initial package

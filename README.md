Foreman commands for Hammer CLI
===============================

This [Hammer CLI](https://github.com/theforeman/hammer-cli) plugin contains
set of commands for [Foreman](http://theforeman.org/).

Check out the [release notes](doc/release_notes.md#release-notes) to see what's new in the latest version.

Documentation
-------------

 - [Configuration](doc/configuration.md#configuration)
 - [Host creation](doc/host_create.md#host-creation)

How to run
----------

We build rpms, debs and gems. Alternatively you can install hammer from a git checkout.
See our [Hammer CLI installation and configuration instuctions](https://github.com/theforeman/hammer-cli/blob/master/doc/installation.md#installation).


Having issues?
--------------

If one of hammer commands doesn't work as you would expect, you can run `hammer -d ...` to get
full debug output from the loggers. It should give you an idea what went wrong.

If you have questions, don't hesitate to contact us on `foreman-users@googlegroups.com` or
the `Freenode#theforeman` IRC channel.


Developer Docs
--------------
If you're planning to contribute,
look at [the development documentation](doc/developer_docs.md#hammer-development-docs).

If you'd like to contribute and you're looking for an easy to start with issue, there's a list of such bugs in [the Foreman's Redmine](http://projects.theforeman.org/projects/hammer-cli/issues?utf8=%E2%9C%93&set_filter=1&f[]=cf_3&op[cf_3]=%3D&v[cf_3][]=trivial&v[cf_3][]=easy&f[]=status_id&op[status_id]=o).

How to test
------------
Please read our [testing documentation](doc/testing.md#testing-hammer-commands) for more information about how to write and run tests. good test


License
-------

This project is licensed under the GPLv3+.

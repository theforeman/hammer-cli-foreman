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

The work is still in progress and there are no builds ready yet. You can install the plugin from source.
See [Hammer CLI readme](https://github.com/theforeman/hammer-cli/blob/master/README.md#how-to-run) for details.


Having issues?
--------------

If one of hammer commands doesn't work as you would expect, you can run `hammer -d ...` to get
full debug output from the loggers. It should give you an idea what went wrong.

If you have questions, don't hesitate to contact us on `foreman-users@googlegroups.com` or
`FreeNode#foreman` irc channel.


Developer Docs
--------------
If you're planning to contribute,
look at [the development documentation](doc/developer_docs.md#hammer-development-docs).


How to test
------------

    $ bundle install
    $ bundle exec "rake test"

Generated coverage reports are stored in ./coverage directory.

License
-------

This project is licensed under the GPLv3+.

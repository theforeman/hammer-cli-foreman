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


How to test
------------

```bash
   $ bundle install
   $ bundle exec "rake test"
```

Generated coverage reports are stored in ./coverage directory.

There is support for testing against API documentation (and sample data) generated from different versions of Foreman.
The required version of Foreman can be set in env variable `TEST_API_VERSION`. Make sure the requested data are
in `test/unit/data/<version>/`.

```bash
  $ TEST_API_VERSION=1.10 bundle exec rake test
```


License
-------

This project is licensed under the GPLv3+.

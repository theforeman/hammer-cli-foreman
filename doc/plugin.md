# Writing a plugin

### Basic

If you want to create a plugin for hammer-cli-foreman, you might want to create
a simple draft at first.

To do so, just run the following:
```
# You will need to checkout this repository first if you don't have it already
$ git checkout https://github.com/theforeman/hammer-cli-foreman.git
$ cd hammer-cli-foreman
$ rake plugin:draft
# fill prompts
```
This will create a directory called `hammer-cli-foreman-prompted-name` with
basic structure where you can put your code afterwards. Please, don't forget to
take a look at `TODO`s as there might be places you want to change or adjust to
your needs first.

For more information, please see: https://github.com/theforeman/hammer-cli/blob/master/doc/developer_docs.md
as well as https://github.com/theforeman/hammer-cli-foreman/blob/master/doc/developer_docs.md

Configuration
=============

Configuration is expected to be placed in one of hammer's configuration directories for plugins:
- `/etc/hammer/cli.modules.d/`
- `~/.hammer/cli.modules.d/`
- `./.config/cli.modules.d/` (config dir in CWD)

If you install `hammer_cli_foreman` from source you'll have to copy the config file manually
from `config/foreman.yml`.

See our [sample config file](https://github.com/theforeman/hammer-cli-foreman/blob/master/config/foreman.yml)
that lists all available configuration options with descriptions.

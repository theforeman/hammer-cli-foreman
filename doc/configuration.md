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

## Authentication
### Basic auth
Basic authentication with username and password is currently the only supported method.

You can save your credentials into hammer config file in your home directory:
`~/.hammer/cli.modules.d/foreman.yml`
```yaml
:foreman:
  :username: 'admin'
  :password: 'example'
```

Credentials can be passed directly on the command line too:
```bash
hammer -u admin -p example ...
```

If there are no credentials in neither config files nor command line, hammer asks for them interactively:
```
>> hammer host list
[Foreman] Username: admin
[Foreman] Password for admin:
...
```

**Sessions**

Hammer supports session authentication to reduce the need of entering credentials for each command.
It's disabled by default. To turn it on, put following into your config file:
```yaml
:foreman:
  :use_sessions: true
```
Unfortunately retry on session expiry is yet to be implemented. Therefore you'll observe first command to fail
after the session expires.

The default session timeout is 1 hour. This can be changed in the Foreman: `Settings > Authentication > Idle timeout`

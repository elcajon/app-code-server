# Home Assistant App: Advanced Code Server

VS Code in the Home Assistant frontend, extended for system administration.
The Home Assistant, ESPHome, YAML and MDI extensions work out of the box.

This app is based on the community app
[Studio Code Server][hassio-addons]. Use that one if you only want to edit
your Home Assistant configuration. Use this one if you also want to manage
the host from the editor.

**Warning**: this app runs with the Supervisor `admin` role and can access
Docker. Used carelessly, it can break your entire system.

## Differences from Studio Code Server

Added:

- Docker CLI with access to the host's Docker (see [Docker](#docker))
- `reboot` and `shutdown` for the host, `restart` for Home Assistant Core
- [Custom services](#custom-services) and a running cron daemon
- Tailscale, 1Password CLI (`op`), git-crypt, yq, PHP, ShellCheck, htop,
  nano, netcat, yamllint and ESPHome
- An OpenSSH server, installed but not started. Start it from a
  [custom service](#custom-services) if you want it.
- Extensions: Container Tools, GitHub Pull Requests, Ruff, markdownlint,
  Material Icon Theme and GitHub Theme

Not available:

- The `packages`, `init_commands` and `config_path` options

## Installation

Add [this add-on repository][ha-addons] to Home Assistant or click the button
below, then install and start "Advanced Code Server".

[![Add Repository to HA][my-ha-badge]][my-ha-url]

## Configuration

**Note**: _Restart the app after changing the configuration._

### Option: `log_level`

Sets the log level of the app and of code-server: `trace`, `debug`,
`info` (default), `notice`, `warning`, `error` or `fatal`.

`debug` and `trace` also skip your [custom services](#custom-services).

## Docker

The `docker` command only works if **Protection mode** is disabled on the
app's info page. Restart the app after disabling it. With protection
mode on, `docker` prints instructions instead.

## Custom services

Place your own [s6-rc][s6-rc] service definitions in
`/addon_configs/<id>_code-server/custom-services/`, one folder per service.
The app starts every service listed in the bundle `custom-services`:

```text
custom-services/
├── custom-services/        # bundle
│   ├── type                # contains: bundle
│   └── contents.d/
│       └── my-service      # empty file, one per service
└── my-service/
    ├── type                # contains: longrun or oneshot
    └── run                 # or "up" for oneshot services
```

If a custom service keeps the app from starting, set `log_level` to
`debug`. This skips all custom services until you set it back.

## Claude Code

Claude Code is not part of this app, but it runs in it and its login is kept
across restarts.

Install the `Anthropic.claude-code` extension from the Extensions view. It is
published on [Open VSX][open-vsx], the registry code-server uses for extensions
you install yourself, and it brings its own `claude` binary, so nothing else has
to be installed. GitHub Copilot, by contrast, is only published on the Microsoft
Marketplace and cannot be installed here.

Sign in from a terminal rather than the editor: the browser flow redirects to a
`vscode://` URL, which does not survive Home Assistant's ingress. Open a
terminal in VS Code, run `claude`, then use `/login` and paste back the code it
asks for.

Everything Claude Code stores is kept in `/data` instead of the home folder, so
your login survives restarts and updates of this app. That works through
`CLAUDE_CONFIG_DIR`, which this app exports before starting the code server;
terminals inside VS Code inherit it. A login left behind by an earlier version
of this app is copied over on the first start, without overwriting anything
already there.

The `claude` binary lives inside the extension folder under
`/data/code-server/extensions/`. Symlink it into `/usr/local/bin` if you want it
on your `PATH` in every terminal.

## Persistent data

The following survive restarts and updates:

- VS Code settings and extensions you install yourself
- `~/.ssh`, `~/.gitconfig` and the zsh history
- The Claude Code login and settings, if you install the extension

Common folders such as `homeassistant`, `share` and `addon_configs` are linked
into the workspace (`/root`).

## Resetting the VS Code settings

The app keeps its default settings up to date until you change them.
To go back to the defaults, open a terminal in VS Code and run
`reset-settings`.

[open-vsx]: https://open-vsx.org
[hassio-addons]: https://github.com/hassio-addons/app-vscode
[ha-addons]: https://github.com/elcajon/ha-repository-edge
[my-ha-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[my-ha-url]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Felcajon%2Fha-repository-edge
[s6-rc]: https://skarnet.org/software/s6-rc/overview.html

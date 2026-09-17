# Home Assistant Add-on: Advanced Code Server

VS Code in the Home Assistant frontend, extended for system administration.
The Home Assistant, ESPHome, YAML and MDI extensions work out of the box.

This add-on is based on the community add-on
[Studio Code Server][hassio-addons]. Use that one if you only want to edit
your Home Assistant configuration. Use this one if you also want to manage
the host from the editor.

**Warning**: this add-on runs with the Supervisor `admin` role and can access
Docker. Used carelessly, it can break your entire system.

## Differences from Studio Code Server

Added:

- Docker CLI with access to the host's Docker (see [Docker](#docker))
- `reboot` and `shutdown` for the host, `restart` for Home Assistant Core
- [Custom services](#custom-services) and a running cron daemon
- Tailscale, 1Password CLI (`op`), git-crypt, yq, PHP, ShellCheck, htop,
  nano, netcat, yamllint and ESPHome
- Extensions: Container Tools, GitHub Pull Requests, Ruff, markdownlint,
  Material Icon Theme and GitHub Theme

Not available:

- The `packages`, `init_commands` and `config_path` options
- aarch64 (amd64 only)

## Installation

Add [this add-on repository][ha-addons] to Home Assistant or click the button
below, then install and start "Advanced Code Server".

[![Add Repository to HA][my-ha-badge]][my-ha-url]

## Configuration

**Note**: _Restart the add-on after changing the configuration._

### Option: `log_level`

Sets the log level of the add-on and of code-server: `trace`, `debug`,
`info` (default), `notice`, `warning`, `error` or `fatal`.

`debug` and `trace` also skip your [custom services](#custom-services).

## Docker

The `docker` command only works if **Protection mode** is disabled on the
add-on's info page. Restart the add-on after disabling it. With protection
mode on, `docker` prints instructions instead.

## Custom services

Place your own [s6-rc][s6-rc] service definitions in
`/addon_configs/<id>_code-server/custom-services/`, one folder per service.
The add-on starts every service listed in the bundle `custom-services`:

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

If a custom service keeps the add-on from starting, set `log_level` to
`debug`. This skips all custom services until you set it back.

## Persistent data

The following survive restarts and updates:

- VS Code settings and extensions you install yourself
- `~/.ssh`, `~/.gitconfig` and the zsh history

Common folders such as `homeassistant`, `share` and `addon_configs` are linked
into the workspace (`/root`).

## Resetting the VS Code settings

The add-on keeps its default settings up to date until you change them.
To go back to the defaults, open a terminal in VS Code and run
`reset-settings`.

[hassio-addons]: https://github.com/hassio-addons/app-vscode
[ha-addons]: https://github.com/elcajon/ha-repository-edge
[my-ha-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[my-ha-url]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Felcajon%2Fha-repository-edge
[s6-rc]: https://skarnet.org/software/s6-rc/overview.html

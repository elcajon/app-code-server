# Home Assistant Add-on: Advanced Code Server

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[![Github Actions][github-actions-shield]][github-actions]
![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

[code-server][code-server] (VS Code in the browser) inside the Home Assistant
frontend, extended for system administration.

## About

This add-on is based on the community add-on
[Studio Code Server][hassio-addons] and keeps its core: VS Code in the Home
Assistant sidebar, with the Home Assistant, ESPHome, YAML and MDI extensions
pre-configured.

On top of that, it is built for managing the whole host, not just the
Home Assistant configuration. Compared to the original:

|                                                | Original | This add-on |
| ---------------------------------------------- | -------- | ----------- |
| Docker CLI with host access                    | –        | ✓           |
| `reboot`, `shutdown`, `restart`                | –        | ✓           |
| Custom s6 services and cron                    | –        | ✓           |
| Tailscale, 1Password CLI, git-crypt, yq, PHP   | –        | ✓           |
| Extra extensions (Container Tools, GitHub PRs) | –        | ✓           |
| `packages`, `init_commands`, `config_path`     | ✓        | –           |
| aarch64                                        | ✓        | –           |

**Warning**: this add-on runs with the Supervisor `admin` role and can access
Docker. Used carelessly, it can break your entire system.

[:books: Read the full add-on documentation][docs]

## Installation

Add [this add-on repository][ha-addons] to Home Assistant or click the button
below.

[![Add Repository to HA][my-ha-badge]][my-ha-url]

[aarch64-shield]: https://img.shields.io/badge/aarch64-no-red.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[code-server]: https://github.com/coder/code-server
[commits-shield]: https://img.shields.io/github/commit-activity/y/elcajon/app-code-server.svg
[commits]: https://github.com/elcajon/app-code-server/commits/main
[docs]: https://github.com/elcajon/app-code-server/blob/main/code-server/DOCS.md
[github-actions-shield]: https://github.com/elcajon/app-code-server/workflows/CI/badge.svg
[github-actions]: https://github.com/elcajon/app-code-server/actions
[license-shield]: https://img.shields.io/github/license/elcajon/app-code-server.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2026.svg
[releases-shield]: https://img.shields.io/github/release/elcajon/app-code-server.svg
[releases]: https://github.com/elcajon/app-code-server/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[hassio-addons]: https://github.com/hassio-addons/app-vscode
[my-ha-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[my-ha-url]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Felcajon%2Fha-repository-edge
[ha-addons]: https://github.com/elcajon/ha-repository-edge

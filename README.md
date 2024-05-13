
# dorian/gray

* Dorian - Pyzer docker-packaged installation
* Gray - CLI tool for managing Dorian

## Migration and installation instruction

Please visit the [Dorian/Gray Confluence page](https://swissinnolab.atlassian.net/wiki/spaces/PYZER/pages/2404319233/) for detailed instructions.

## Switch descriptions

| Switch | Argument | Effect |
|--------|----------|--------|
| `-a`    | `<api key>`| Sets DMP API key.        |
| `-d`    | `<device id>`| Sets DMP device ID.        |
| `-h`    | | Sets hostname to `dorian-<device id>`. Must be previously set using `-d` |
| `-o`    | `[normal\|left\|right\|inverted]` | Sets screen orientation and applies immediately. |
| `-p`    | `<profile>` | Set installation profile (UI). `none` for no UI. |
|--------|----------|--------|
| `-C`    | | Converts `loytra` installation to `Dorian`. Use on old devices. |
| `-D`    | | Installs Docker. Use everywhere. |
| `-I`    | | Installs `Dorian`. Use on new devices.|
| `-U`    | | Installs UI prerequisites. Use on devices with a screen. |
| `-V`    | | Installs and sets up VPN. Use everywhere, but after Dorian conversion or clean installation. |
|--------|----------|--------|
| `-m`    |          | Stops all containers.       |
| `-M`    |          | (Re)starts all containers.        |
| `-u`    |          | Downloads updates from stable (main) branch. Does not restart containers after download.        |
| `-e`    |          | Downloads updates from develop (experimental). Does not restart containers after download.        |


# dorian/gray

* Dorian - Pyzer docker-packaged installation
* Gray - CLI tool for managing Dorian

## Migration and installation instruction

Please visit the Dorian/Gray confluence page for detailed instructions.

## Switch descriptions

| Switch | Argument | Effect |
|--------|----------|--------|
| `-a`    | `<api key>`| Sets DMP API key.        |
| `-d`    | `<device id>`| Sets DMP device ID.        |
| `-p`    | `[profile]` | Set installation profile (UI). With no argument, disables UI. |
|--------|----------|--------|
| `-C`    | | Converts `loytra` installation to `Dorian`. Use on old devices. |
| `-D`    | | Installs Docker. Use everywhere. |
| `-I`    | | Installs `Dorian`. Use on new devices.|
| `-U`    | | Installs UI prerequisites. Use on devices with a screen. |
| `-V`    | | Installs and sets up VPN. Use everywhere, but after Dorian conversion or clean installation. |
|--------|----------|--------|
| `-m`    |          | Stops all containers.       |
| `-M`    |          | (Re)starts all containers.        |
| `-u`    |          | Downloads updates. Does not restart containers after upload.        |

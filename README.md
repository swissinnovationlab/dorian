
# dorian

Docker toolset for managing Pyzer Docker-powered installations

## Migration process

Log into target device over LAN or VPN.

### 0. Download

```sh
$ cd ~
$ git clone https://github.com/swissinnovationlab/dorian.git
$ chmod +x ~/dorian/*.sh
$ cp ~/dorian/*.sh ~/
$ cp ~/dorian/*.yml ~/
```

Before continuing, run

```sh
$ sudo ls .
```

to prevent Linux from asking for sudo password during installation.

### 1. Preinstall Docker

Run:

```sh
$ gray_install_docker.sh
```

If running from an Arch device, you will be prompted to logout and login.
Failure to do so will prevent the installation from continuing normally.

# WORK IN PROGRESS

### 2. Migrate

If installing on a device _**with no screen**_, run:

```sh
$ ./migrate.sh
```

If installing on a device _**running Residential UI**_, run:

```sh
$ ./migrate.sh -r
```

The process should automatically migrate the existing resources and flows and start the containerized installation.

## Maintenance cookbook

### Checking running containers

```sh
$ docker ps
```

### Stopping VPN container

⚠⚠⚠ If run over an active VPN connection it will make the device unreachable.
Do this operation only if connected via LAN.

```sh
$ docker compose -f docker_compose_vpn.yml down
```

### Starting VPN container

```sh
$ docker compose -f docker_compose_vpn.yml up --build -d
```

### Stopping main container

```sh
$ docker compose down
```

### Starting main container

```sh
$ docker compose up --build -d
```

### Changing running UI on device

The `docker_compose.yml` services may optionally contain a `profiles: [..., ...]` descriptor.
A service may have zero profiles, or one or more profiles stored in an array.
Services that do not have a profile are _always_ started.
Services that have a profile are started if the `docker compose --profile <descriptor here> up` command is used.

Alternatively, the `COMPOSE_PROFILES=profile1,profile2` environment variable can store which profiles are needed.
In this case, the profiled service will also be started during a regular `docker compose up` command.

To change the required profile:

1. Stop the main container
2. Edit the `~/.bashrc` file and add, update or remove the `COMPOSE_PROFILES=...` line and save
3. `$ source ~/.bashrc` to reload the profile
4. Start the main container

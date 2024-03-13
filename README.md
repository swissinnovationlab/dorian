
# dorian

Docker toolset for managing Pyzer Docker-powered installations

## Migration process

Log into target device over LAN or VPN.

### 0. Download

```sh
$ cd ~
$ git clone https://github.com/swissinnovationlab/dorian.git
$ chmod +x ~/dorian/gray.sh
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
$ gray.sh -D
```

If running from an Arch device, you will be prompted to logout and login.
Failure to do so will prevent the installation from continuing normally.

### 2. Convert from loytra to dorian

If installing on a device _**with no screen**_, run:

```sh
$ gray.sh -c
```

`gray` will:

* stop `loytra` processes (except for VPN)
* disable `loytra` command so it can no longer be executed
* migrate DMP data from the loytra storage to `~/devconn.env`
* migrate resources and flows from the loytra storage to the `dorian`

If installing on a device _**running Residential UI**_, run:

```sh
$ gray.sh -r -c
```

Before running the conversion, `gray` will place a variable in the `~/.bashrc` file marking which UI is needed. When docker detects that variable, it will start the appropriate UI. If the variable does not exist, no UI is started.

### 3. Start

Start the VPN container by running:

```sh
$ gray.sh -V
```

Start the core container by running:

```sh
$ gray.sh -M
```

## Maintenance cookbook

### Checking running containers

```sh
$ docker ps
```

### Stopping and starting VPN container

⚠ The VPN container cannot be stopped if you're connected over VPN.

* `$ ./gray.sh -V` (uppercase V) - start
* `$ ./gray.sh -v` (lowercase V) - stop

### Stopping and starting main container

* `$ ./gray.sh -M` (uppercase M) - start
* `$ ./gray.sh -m` (lowercase m) - stop

### Changing running UI on device

⚠ Always stop the main container first before changing the UI.

* `$ ./gray.sh -n` - disable
* `$ ./gray.sh -r` - residential UI
* `$ ./gray.sh -p` - Porsche UI

### Changing credentials

* `$ ./gray.sh -d <deviceId>` - set new DMP device ID
* `$ ./gray.sh -a <apiKey>  ` - set new DMP API key

### Updating dorian

⚠ Always stop the main container first before updating.

* `$ ./gray.sh -u` - updates Dorian

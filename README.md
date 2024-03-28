
# dorian/gray

* Dorian - Pyzer docker-packaged installation
* Gray - CLI tool for managing Dorian

## A. Migration process

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

### 1. Preinstall docker

Run:

```sh
$ ./gray.sh -D
```

If running from an Arch device, you will be prompted to logout and login.
Failure to do so will prevent the installation from continuing normally.

### 2. Convert from loytra to dorian

If converting a device _**with no screen**_, run:

```sh
$ ./gray.sh -c
```

`gray` will:

* stop `loytra` processes (except for VPN)
* disable `loytra` command so it can no longer be executed
* migrate DMP data from the loytra storage to `~/devconn.env`
* migrate resources and flows from the loytra storage to `dorian`'s docker volume

If converting a device _**running Residential UI**_, run:

```sh
$ ./gray.sh -p residential -c
```

Before running the conversion, `gray` will place a variable in the `~/.env` file marking which UI is needed.

When docker detects that file with that variable, it will start the appropriate UI.
If the variable or file do not exist, no UI is started.

### 3. Start

Start the core container by running:

```sh
$ ./gray.sh -M
```

### 4. Install and activate VPN

Install and auto-activate VPN by running:

```sh
$ ./gray.sh -V
```

This action will:

* automatically extract VPN data from `~/devconn.env`
* contact DMP to retrieve VPN configuration
* create the appropriate files in `/etc/openvpn/client`
* start the openvpn service

## B. Installation process

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

### 1. Preinstall docker

Run:

```sh
$ ./gray.sh -D
```

If running from an Arch device, you will be prompted to logout and login.

Failure to do so will prevent the installation from continuing normally.

### 2. (on devices with UI) Preinstall UI

Run:

```sh
$ ./gray.sh -U
```
### 3. Set up the device credentials and install Dorian:

Run:

```sh
$ ./gray.sh -d <device DMP ID>
$ ./gray.sh -a <device API key>
$ ./gray.sh -I
```

To set up the credentials and start the installation.

This will automatically start the Dorian containers.

### 4. Install and activate VPN

Install and auto-activate VPN by running:

```sh
$ ./gray.sh -V
```

This action will:

* automatically extract VPN data from `~/devconn.env`
* contact DMP to retrieve VPN configuration
* create the appropriate files in `/etc/openvpn/client`
* start the openvpn service


## Maintenance cookbook

### Checking running containers

```sh
$ docker ps
```

### Stopping and starting main container

* `$ ./gray.sh -M` (uppercase M) - start
* `$ ./gray.sh -m` (lowercase m) - stop

### Changing running UI on device

⚠ Always stop the main container first before changing the UI.

* `$ ./gray.sh -p` --- disable UI profile
* `$ ./gray.sh -p residential` --- residential UI
* `$ ./gray.sh -p item_storage` --- Porsche UI

### Changing credentials

* `$ ./gray.sh -d <deviceId>` - set new DMP device ID
* `$ ./gray.sh -a <apiKey>  ` - set new DMP API key

### Updating dorian

⚠ Always stop the main container first before updating.

* `$ ./gray.sh -u` - updates Dorian

# Scripts to make deveoping on WSL(2) easier.

| Script | Description |
| ------ | ----------- |
|  [gen-resolve-conf.sh](./gen-resolv-conf.sh) | Creates an /etc/resolv.conf that lists IPV4 nameservers from the windows host first and the wsl gateway (i.e. vEthernet (WSL) on the windows host), last.  This allows for DNS when on VPN connections.  This can be run as your non-root user and will use sudo when updating the `resolv.conf` file.  It can also be run as root. |
| [setup-wsl-dev.sh](./setup-wsl-dev.sh) | Adds some common hosts to /etc/hosts for work development inside wsl |



# Installating `gen-resolv-conf.sh`

Clone the repo:

```
git clone git@github.com:evaneaston/wsl-tools.git
```

If you don't have access to network inside WLS2, clone the git repo in Windows, then copy it into the distro from `/mnt/<drive>/...`

## With systemd

[Distrod](https://github.com/nullpo-head/wsl-distrod/tree/main/distrod) makes it easy to install a variety of distributions
in WSL2 with systemd running.  Once you get your distro setup run the following:

```
wsl-tools/install-gen-resolv-conf-systemd.sh
```

This will install the service and a timer that calls it every minute.  It will run from the wherever you cloned your repo.  It does not install the script into `/usr` or `/opt`.

## Without systemd

Without systemd, the steps below will configure things so that:

1. `cron` be started if it's not running the first time you log in to your WSL2 shell
1. cron will run `gen-resolv-conf.sh` every minute
1. run `gen-resolv-conf.sh` upon each login for good measure

### 1. Turn off WSL's automatic generation of `/etc/resolv.conf`

`sudo` edit `/etc/wsl.conf` to include `generateResolvConf=false` in the `[network]` section.  Mine looks like this:

```
[network]
generateResolvConf = false
```

### 2. Allow your default linxu distro user to run `cron` and run `gen-resolv-conf.sh` without a password

From within your wsl distro, run `sudo visudo` to edit the `sudoers` and **add** a line (do not remove the existing lines for your users):

```
<username> ALL=(ALL) NOPASSWD: /etc/init.d/cron, <pathto>/gen-resolv-conf.sh
```

For example, this is at the end of mine:

```
eeaston ALL=(ALL) NOPASSWD: /etc/init.d/cron, /home/eeaston/bin/gen-resolv-conf.sh
```

### 3. Schedule `cron` job to run `gen-resolv-conf.sh` as root

Schedule a job to run  `gen-resolv-conf.sh` once a minute as root.

1. run `sudo crontab -e` 
1. add `* * * * * <pathto>/gen-resolv-conf.sh`

### 4. Auto-start `cron` and run `gen-resolv-conf.sh` from your profile

Add the following at the top of your `.profile`:

```
echo Ensuring cron is running
sudo /etc/init.d/cron start > /dev/null

echo Rebuilding resolv.conf in background
(<pathto>/gen-resolv-conf.sh &> /dev/null &)
```

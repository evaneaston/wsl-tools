# Scripts to make deveoping on WSL(2) easier.

| Script | Description |
| ------ | ----------- |
|  [gen-resolve-conf.sh](./gen-resolv-conf.sh) | Creates an /etc/resolv.conf that lists IPV4 nameservers from the windows host first  and the wsl gateway (i.e. vEthernet (WSL) on the windows host), last.  This allows for DNS when on VPN connections. |
| [setup-wsl-dev.sh](./setup-wsl-dev.sh) | Adds some common hosts to /etc/hosts for work development inside wsl |


# Automating

## 1. Turn off automatic generation of `/etc/resolv.conf`

`sudo` edit `/etc/wsl.conf` to include `generateResolvConf=false` in the `[network]` section.  Mine looks like this:

```
[network]
generateResolvConf = false
````

## 2. Allow your default linxu distro user to run `cron` and run `gen-resolv-conf.sh` without a password

From within your wsl distro, run `sudo visudo` to edit the `sudoers` and **add** a line (do no tremove the existing lines for your users):

  `<username> ALL=(ALL) NOPASSWD: /etc/init.d/cron, <pathto>/gen-resolv-conf.sh` 

for example, this is at the end of mine:

```
eeaston ALL=(ALL) NOPASSWD: /home/eeaston/bin/gen-resolv-conf.sh
```

## 3. Schedule cron job to run `gen-resolv-conf.sh` as root

Schedule a job to run  `gen-resolv-conf.sh` once a minute as root.

1. run `sudo crontab -e` 
1. add `* * * * * <pathto>/gen-resolv-conf.sh`

## 4. Ensure `resolv.conf` gets generated on login and then periodically via cron

Add the following at the top of your `.profile`:

```
echo Ensuring cron is running
sudo /etc/init.d/cron start > /dev/null

echo Rebuilding resolv.conf in background
(<pathto>/gen-resolv-conf.sh &> /dev/null &)
```

This will:

1. start cron if it's not running when you log in to your WSL2 shell
1. run `gen-resolv-conf.sh` once to ensure your `/etc/resolv.conf` is correct right away. 
# Invidious-Ban-Check

[Invidious is an alternative front-end to YouTube](https://github.com/omarroth/invidious)

[Invidious-Updater (And Installer)](https://github.com/tmiland/Invidious-Updater)

## Installation

#### Download and execute the script:

```bash
$ wget https://github.com/tmiland/Invidious-Ban-Check/raw/master/invidious_ban_check.sh
$ chmod +x invidious_ban_check.sh
$ ./invidious_ban_check.sh [check] [force]
```

***Note: you will be prompted to enter root password***

If root password is not set, type:

```bash
sudo passwd root
```

## Usage

* Check: Just check if the IP is banned
* Force: Change force_resolve in config.yml
* E.G: If Google ban on IPv4, change to force_resolve: IPv6
* Note: Invidious will be restarted

## Cron job

`$ crontab -e`

`@hourly bash /path/to/script/invidious_ban_check.sh check force > /dev/null 2>&1`


## Donations 
- [PayPal me](https://paypal.me/milanddata)
- [BTC] : 33mjmoPxqfXnWNsvy8gvMZrrcG3gEa3YDM

## Web Hosting

Sign up for web hosting using this link, and receive $100 in credit over 60 days.

[DigitalOcean](https://m.do.co/c/f1f2b475fca0)

#### Disclaimer 

*** ***Use at own risk*** ***

### License

[![MIT License Image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MIT_logo.svg/220px-MIT_logo.svg.png)](https://github.com/tmiland/Invidious-Ban-Check/blob/master/LICENSE)

[MIT License](https://github.com/tmiland/Invidious-Ban-Check/blob/master/LICENSE)

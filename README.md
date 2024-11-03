# cloudflare-dns-challenge-hooks

<img alt="GitHub" src="https://img.shields.io/github/license/contracode/cloudflare-dns-challenge-hooks?color=black"> <img alt="GitHub last commit (branch)" src="https://img.shields.io/github/last-commit/contracode/cloudflare-dns-challenge-hooks/main"> <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/contracode/cloudflare-dns-challenge-hooks">

This script implements support for the Automatic Certificate Management Environment ([ACME](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment) protocol's [DNS-01](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge) challenge. In this scenario, the domain owner creates a DNS TXT record containing a specific token for the domain. Following this, the Certificate Authority ([CA](https://en.wikipedia.org/wiki/Certificate_authority) queries the [DNS](https://en.wikipedia.org/wiki/Domain_Name_System) system to confirm that the correct TXT record exists.

## Installation

```bash
git clone https://github.com/contracode/cloudflare-dns-challenge-hooks.git
```

## Usage
This script is used with crontab. Specify the frequency of execution through crontab.

```bash
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday 7 is also Sunday on some systems)
# │ │ │ │ │ ┌───────────── command to issue                               
# │ │ │ │ │ │
# │ │ │ │ │ │
# * * * * * /bin/bash {Location of the script}
```

## Tested Environments:
Ubuntu 20.04 LTS

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GNU General Public License, version 3](https://github.com/contracode/cloudflare-ddns-updater/blob/main/LICENSE)

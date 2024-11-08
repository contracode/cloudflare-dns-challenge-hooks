# cloudflare-dns-challenge-hooks

<img alt="GitHub" src="https://img.shields.io/github/license/contracode/cloudflare-dns-challenge-hooks?color=black"> <img alt="GitHub last commit (branch)" src="https://img.shields.io/github/last-commit/contracode/cloudflare-dns-challenge-hooks/main"> <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/contracode/cloudflare-dns-challenge-hooks">

These scripts automate support for the Automatic Certificate Management Environment ([ACME](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment)) protocol [DNS-01](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge) challenge. In this challenge, the domain owner creates a DNS TXT record containing a specific token for the domain. Following this, the Certificate Authority ([CA](https://en.wikipedia.org/wiki/Certificate_authority) queries the [DNS](https://en.wikipedia.org/wiki/Domain_Name_System) system to confirm that the correct TXT record exists.

## Installation

```bash
git clone https://github.com/contracode/cloudflare-dns-challenge-hooks.git
```
After cloning, enter the `cloudflare-dns-challenge-hooks` directory and run either of the scripts using `./cloudflare-auth.sh` or `./cloudflare-cleanup.sh`. This will create a `secrets.env` file at `~/.config/cloudflare/` that must be populated with Cloudflare API authentication details prior to use.

## Usage

These scripts are used with [certbot](https://certbot.eff.org/pages/about) via crontab to automate the renewal of HTTPS certificates. The execution frequency is specified through crontab.

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
For example, by first running `sudo crontab -e`, and adding

```bash
0 0 * * * /usr/bin/certbot renew --preferred-challenges=dns --manual-auth-hook "/home/pi/cloudflare-dns-challenge-hooks/cloudflare-auth.sh" --post-hook "systemctl reload nginx" --manual-cleanup-hook "/home/pi/cloudflare-dns-challenge-hooks/cloudflare-cleanup.sh"
```
to the `cron` table, `certbot` will will check whether the domain's HTTPS certificate expires within 30 days. If so, automatic renewal will take place via the ACME DNS-01 challenge. 

## Testing

Assuming that authentication details have been specified at `~/.config/cloudflare/secrets.env`:

```bash
sudo CERTBOT_DOMAIN=foo.com CERTBOT_VALIDATION=bar ./cloudflare-auth.sh
```

will create a `TXT` DNS record for `foo.com` with the name, _acme-challenge_, and content, _bar_.

Conversely,

```bash
sudo CERTBOT_DOMAIN=foo.com ./cloudflare-cleanup.sh
```

will remove it.

To perform component testing, use

```bash
sudo /usr/bin/certbot renew --force-renewal --preferred-challenges=dns --manual-auth-hook "/home/pi/cloudflare-dns-challenge-hooks/cloudflare-auth.sh" --post-hook "systemctl reload nginx" --manual-cleanup-hook "/home/pi/cloudflare-dns-challenge-hooks/cloudflare-cleanup.sh"
```

which forces a renewal attempt against the same mechanism specified in the `cron` table.

If this succeeds, the domain will have an HTTPS certificate that expires 90 days from the current time, specified in the UTC time zone.

The Certificate SHA-256 fingerprint will match the output from

```bash
sudo cat /etc/letsencrypt/live/foo.com/fullchain.pem | openssl x509 -noout -fingerprint -sha256
```

executed on the server, and the Public Key SHA-256 fingerprint will match the output from

```bash
sudo cat /etc/letsencrypt/live/contracode.com/fullchain.pem | openssl x509 -noout -pubkey | sed '/^-----BEGIN PUBLIC KEY-----/d;/^-----END PUBLIC KEY-----/d' | tr -d '\n' | base64 --decode | openssl dgst -sha256 -hex
```

executed on the server.

## Tested Environments:
Ubuntu 20.04 LTS

## Contributing
Pull requests are welcome. For major changes, please [open an issue](https://github.com/contracode/cloudflare-dns-challenge-hooks/issues/new) first to discuss the proposed change.

## License
[GNU General Public License, version 3](https://github.com/contracode/cloudflare-dns-challenge-hooks/blob/main/LICENSE)

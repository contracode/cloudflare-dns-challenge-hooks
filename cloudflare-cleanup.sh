#!/bin/bash
## change to "bin/sh" when necessary

# Set client secrets location.
# From: https://www.reddit.com/r/bash/comments/puujxk/comment/he7bz9s/
API_KEY_DIR=${XDG_CONF_HOME:-$HOME/.config}/cloudflare

# Create a directory for client secrets if it does not exist.
if [ ! -d "${API_KEY_DIR}" ]; then
    mkdir -p "${API_KEY_DIR}"
    SECRETS_FILE=${API_KEY_DIR}/secrets.env

    # Create a secrets.env file template.
    touch ${SECRETS_FILE}
    echo -en "#/bin/bash\n\n# These are secrets used by the 'cloudflare-ddns-updater' script.\n\n" > ${SECRETS_FILE}

    echo "CLOUDFLARE_AUTH_EMAIL=\"\"                                       # The email used to login 'https://dash.cloudflare.com'" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_AUTH_METHOD=\"token\"                                 # Set to "global" for Global API Key or "token" for Scoped API Token" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_AUTH_KEY=\"\"                                         # Your API Token or Global API Key" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_ZONE_IDENTIFIER=\"\"                                  # Can be found in the "Overview" tab of your domain" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_RECORD_NAME=\"\"                                      # Which record you want to be synced (hint: the fully-qualified domain name)" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_TTL=\"3600\"                                          # Set the DNS TTL (seconds)" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_PROXY=\"false\"                                       # Set the proxy to true or false" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_SITENAME=\"\"                                         # Title of site \"Example Site\" used in Slack and/or Discord notifications" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_SLACKCHANNEL=\"\"                                     # Slack Channel #example" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_SLACKURI=\"\"                                         # URI for Slack WebHook "https://hooks.slack.com/services/xxxxx"" >> ${SECRETS_FILE}
    echo "CLOUDFLARE_DISCORDURI=\"\"                                       # URI for Discord WebHook "https://discordapp.com/api/webhooks/xxxxx"" >> ${SECRETS_FILE}

    echo "No client secrets file was found. Please fill in the values in ${SECRETS_FILE}"
    exit
fi

SECRETS_FILE="${API_KEY_DIR}/secrets.env"

# Load client secrets.
. ${SECRETS_FILE}

# Domain and challenge info from Certbot
DOMAIN="$CERTBOT_DOMAIN"
TXT_RECORD_NAME="_acme-challenge.${DOMAIN}"

###########################################
## Check and set the proper auth header
###########################################
if [[ "${CLOUDFLARE_AUTH_METHOD}" == "global" ]]; then
  auth_header="X-Auth-Key:"
else
  auth_header="Authorization: Bearer"
fi

# Get the DNS record ID for the TXT record that was created
response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_IDENTIFIER}/dns_records?type=TXT&name=${TXT_RECORD_NAME}" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "$auth_header ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json")

# Check for errors
case "$response" in
*"\"success\":false"*)
  echo -e "Cloudflare Cleanup: DNS Challenge record was not found for ${DOMAIN}. DUMPING RESULTS:\n$response" | logger -s
  exit 1;;
*)
  echo -e "Cloudflare Cleanup: DNS Challenge record found for ${DOMAIN}."
esac

###########################################
## Set the record identifier from result
###########################################
record_identifier=$(echo "$response" | sed -E 's/.*"id":"([A-Za-z0-9_]+)".*/\1/')

response=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_IDENTIFIER}/dns_records/${record_identifier}" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "$auth_header ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json")

# Check for errors
case "$response" in
*"\"success\":false"*)
  echo -e "Cloudflare Cleanup: DNS Challenge record cleanup failed for ${DOMAIN}. DUMPING RESULTS:\n$response" | logger -s
  exit 1;;
*)
  echo -e "Cloudflare Cleanup: DNS Challenge record cleanup successful for ${DOMAIN}."
  exit 0;;
esac

unset CLOUDFLARE_AUTH_EMAIL
unset CLOUDFLARE_AUTH_METHOD
unset CLOUDFLARE_AUTH_KEY
unset CLOUDFLARE_ZONE_IDENTIFIER
unset CLOUDFLARE_RECORD_NAME
unset CLOUDFLARE_TTL
unset CLOUDFLARE_PROXY
unset CLOUDFLARE_SITENAME
unset CLOUDFLARE_SLACKCHANNEL
unset CLOUDFLARE_SLACKURI
unset CLOUDFLARE_DISCORDURI


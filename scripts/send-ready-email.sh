#!/usr/bin/env bash
set -euo pipefail

EMAIL_TO=$1
EMAIL_FROM=$2
APACHE_URL=$3
NGINX_URL=$4
TOMCAT_URL=$5

SUBJECT="Codespace is ready: Apache/Nginx/Tomcat links"
BODY="Your GitHub Codespace finished provisioning.\n\nLinks:\n- Apache: ${APACHE_URL}\n- Nginx:  ${NGINX_URL}\n- Tomcat: ${TOMCAT_URL}\n\nTip: If a link times out, wait a few seconds and retry."

curl -sS -X POST https://api.sendgrid.com/v3/mail/send \
  -H "Authorization: Bearer ${SENDGRID_API_KEY}" \
  -H 'Content-Type: application/json' \
  -d @<(jq -n \
    --arg to    "${EMAIL_TO}" \
    --arg from  "${EMAIL_FROM}" \
    --arg sub   "${SUBJECT}" \
    --arg body  "${BODY}" \
    '{
      personalizations: [{ to: [{ email: $to }] }],
      from: { email: $from },
      subject: $sub,
      content: [{ type: "text/plain", value: $body }]
    }'
  )

echo "📧 Email sent to ${EMAIL_TO}"

#!/usr/bin/env bash
set -euo pipefail

EMAIL_TO=$1
EMAIL_FROM=$2
APACHE_URL=$3
NGINX_URL=$4
TOMCAT_URL=$5

SUBJECT="Codespace is ready: Apache/Nginx/Tomcat links"
BODY="Your GitHub Codespace finished provisioning.\n\nLinks:\n- Apache: ${APACHE_URL}\n- Nginx:  ${NGINX_URL}\n- Tomcat: ${TOMCAT_URL}\n\nTip: If a link times out, wait a few seconds and retry."

# SMTP via curl (SMTPS 465), mirrors your working command
curl --fail --silent --show-error \
  --url "smtps://${SMTP_HOST:-smtp.gmail.com}:${SMTP_PORT:-465}" --ssl-reqd \
  --mail-from "${EMAIL_FROM}" \
  --mail-rcpt "${EMAIL_TO}" \
  --upload-file <(printf "From: %s\nTo: %s\nSubject: %s\n\n%s\n" \
                          "${EMAIL_FROM}" "${EMAIL_TO}" "${SUBJECT}" "${BODY}") \
  --user "${SMTP_USER}:${SMTP_PASS}"

echo "📧 Email sent to ${EMAIL_TO}"

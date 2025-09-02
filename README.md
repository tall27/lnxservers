# Codespaces: Apache + Nginx + Tomcat

This devcontainer stands up three servers on different ports and emails you the preview links when ready.

- Apache → **8080**
- Nginx  → **8081**
- Tomcat → **8082**

## Quick start
1. Push this repo to GitHub and open it in **Codespaces**.
2. During first build, the `postCreateCommand` runs `scripts/provision.sh` to configure and start services.
3. Links appear in the terminal output and in the forwarded ports pane.

## Email notification (optional)
Set these env vars in `.devcontainer/devcontainer.json` before creating the Codespace:
- `SENDGRID_API_KEY` – your SendGrid API key.
- `EMAIL_TO` – recipient email address.
- `EMAIL_FROM` – verified sender address in SendGrid.

When set, an email with the three URLs is sent automatically at the end of provisioning.

## Notes
- Codespaces preview URLs follow: `https://$CODESPACE_NAME-$PORT.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN/`.
- If you change ports, also update `forwardPorts` in `devcontainer.json`.
- Landing pages are minimal "it works" placeholders per server.

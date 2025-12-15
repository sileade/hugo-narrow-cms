# Webhook Configuration Examples

This directory contains example configuration files for setting up GitHub webhook auto-deployment.

## Files

- **hooks.json** - Webhook configuration for the webhook server
- **deploy.sh** - Deployment script executed on webhook trigger
- **webhook.service** - Systemd service configuration
- **setup-webhook.sh** - Automated setup script

## Quick Setup

```bash
# Run the automated setup script
cd ~/hugo-narrow-cms
./examples/webhook/setup-webhook.sh
```

This will:
1. Install webhook server
2. Generate a secure secret
3. Create configuration files
4. Set up systemd service
5. Configure firewall
6. Provide GitHub webhook URL and secret

## Manual Setup

See [WEBHOOK_SETUP.md](../../WEBHOOK_SETUP.md) for detailed instructions.

## Usage

After setup, every push to the main branch will automatically:
1. Pull latest code from GitHub
2. Rebuild Docker containers
3. Deploy the updated site

## Monitoring

```bash
# View webhook server logs
sudo journalctl -u webhook -f

# View deployment logs
tail -f ~/webhooks/deploy.log

# Check webhook service status
sudo systemctl status webhook
```

## Troubleshooting

If webhook doesn't trigger:
1. Check webhook service is running: `sudo systemctl status webhook`
2. Check firewall: `sudo ufw status`
3. Check GitHub webhook deliveries in repo settings
4. Check logs: `sudo journalctl -u webhook -f`

For more help, see [WEBHOOK_SETUP.md](../../WEBHOOK_SETUP.md)

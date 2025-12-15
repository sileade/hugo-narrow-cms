#!/bin/bash

# ============================================
# Webhook Setup Script for Hugo Narrow CMS
# Автоматическая настройка webhook для GitHub
# ============================================

set -e

echo "🔗 Hugo Narrow CMS - Webhook Setup"
echo "===================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Please do not run as root${NC}"
    exit 1
fi

# Get current user
CURRENT_USER=$(whoami)
HOME_DIR=$(eval echo ~$CURRENT_USER)

echo -e "${BLUE}Current user:${NC} $CURRENT_USER"
echo -e "${BLUE}Home directory:${NC} $HOME_DIR"
echo ""

# Step 1: Install webhook
echo -e "${GREEN}Step 1: Installing webhook...${NC}"
if command -v webhook &> /dev/null; then
    echo "✅ Webhook already installed"
    webhook --version
else
    echo "Installing webhook..."
    sudo apt update
    sudo apt install -y webhook
    echo "✅ Webhook installed"
fi
echo ""

# Step 2: Create directories
echo -e "${GREEN}Step 2: Creating directories...${NC}"
mkdir -p $HOME_DIR/webhooks
mkdir -p $HOME_DIR/backups
echo "✅ Directories created"
echo ""

# Step 3: Generate secret
echo -e "${GREEN}Step 3: Generating webhook secret...${NC}"
SECRET=$(openssl rand -hex 32)
echo $SECRET > $HOME_DIR/webhooks/secret.txt
chmod 600 $HOME_DIR/webhooks/secret.txt
echo "✅ Secret generated and saved to ~/webhooks/secret.txt"
echo ""
echo -e "${YELLOW}Your webhook secret:${NC}"
echo -e "${BLUE}$SECRET${NC}"
echo ""
echo -e "${YELLOW}⚠️ Save this secret! You'll need it for GitHub webhook configuration.${NC}"
echo ""

# Step 4: Create hooks.json
echo -e "${GREEN}Step 4: Creating hooks.json...${NC}"
cat > $HOME_DIR/webhooks/hooks.json << EOF
[
  {
    "id": "hugo-deploy",
    "execute-command": "$HOME_DIR/hugo-narrow-cms/deploy.sh",
    "command-working-directory": "$HOME_DIR/hugo-narrow-cms",
    "response-message": "Deployment started successfully",
    "pass-arguments-to-command": [
      {
        "source": "payload",
        "name": "head_commit.id"
      },
      {
        "source": "payload",
        "name": "pusher.name"
      },
      {
        "source": "payload",
        "name": "head_commit.message"
      }
    ],
    "pass-environment-to-command": [
      {
        "source": "payload",
        "envname": "COMMIT_ID",
        "name": "head_commit.id"
      },
      {
        "source": "payload",
        "envname": "PUSHER",
        "name": "pusher.name"
      },
      {
        "source": "payload",
        "envname": "COMMIT_MSG",
        "name": "head_commit.message"
      }
    ],
    "trigger-rule": {
      "and": [
        {
          "match": {
            "type": "payload-hash-sha256",
            "secret": "$SECRET",
            "parameter": {
              "source": "header",
              "name": "X-Hub-Signature-256"
            }
          }
        },
        {
          "match": {
            "type": "value",
            "value": "refs/heads/main",
            "parameter": {
              "source": "payload",
              "name": "ref"
            }
          }
        }
      ]
    }
  }
]
EOF
echo "✅ hooks.json created"
echo ""

# Step 5: Copy deploy script
echo -e "${GREEN}Step 5: Creating deploy script...${NC}"
if [ ! -f "$HOME_DIR/hugo-narrow-cms/deploy.sh" ]; then
    cp examples/webhook/deploy.sh $HOME_DIR/hugo-narrow-cms/deploy.sh
    # Update paths in deploy script
    sed -i "s|/home/hugo|$HOME_DIR|g" $HOME_DIR/hugo-narrow-cms/deploy.sh
    chmod +x $HOME_DIR/hugo-narrow-cms/deploy.sh
    echo "✅ deploy.sh created and configured"
else
    echo "⚠️ deploy.sh already exists, skipping"
fi
echo ""

# Step 6: Create systemd service
echo -e "${GREEN}Step 6: Creating systemd service...${NC}"
sudo tee /etc/systemd/system/webhook.service > /dev/null << EOF
[Unit]
Description=Webhook Server for Hugo Narrow CMS
Documentation=https://github.com/adnanh/webhook
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
Group=$CURRENT_USER
WorkingDirectory=$HOME_DIR/webhooks

ExecStart=/usr/bin/webhook \\
    -hooks $HOME_DIR/webhooks/hooks.json \\
    -port 9000 \\
    -verbose \\
    -hotreload

Restart=always
RestartSec=10

NoNewPrivileges=true
PrivateTmp=true

StandardOutput=journal
StandardError=journal
SyslogIdentifier=webhook

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
echo "✅ Systemd service created"
echo ""

# Step 7: Start webhook service
echo -e "${GREEN}Step 7: Starting webhook service...${NC}"
sudo systemctl enable webhook
sudo systemctl start webhook
sleep 2

if sudo systemctl is-active --quiet webhook; then
    echo "✅ Webhook service is running"
else
    echo -e "${RED}❌ Failed to start webhook service${NC}"
    sudo systemctl status webhook
    exit 1
fi
echo ""

# Step 8: Configure firewall
echo -e "${GREEN}Step 8: Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 9000/tcp
    echo "✅ Firewall configured (port 9000 opened)"
else
    echo "⚠️ UFW not found, please open port 9000 manually"
fi
echo ""

# Step 9: Get server IP
echo -e "${GREEN}Step 9: Getting server information...${NC}"
SERVER_IP=$(curl -s ifconfig.me || echo "Unable to detect")
echo "✅ Server IP: $SERVER_IP"
echo ""

# Summary
echo "=========================================="
echo -e "${GREEN}✅ Webhook Setup Complete!${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Configure GitHub Webhook:"
echo "   URL: https://github.com/sileade/hugo-narrow-cms/settings/hooks"
echo ""
echo "2. Click 'Add webhook' and fill in:"
echo -e "   ${YELLOW}Payload URL:${NC} http://$SERVER_IP:9000/hooks/hugo-deploy"
echo -e "   ${YELLOW}Content type:${NC} application/json"
echo -e "   ${YELLOW}Secret:${NC} $SECRET"
echo -e "   ${YELLOW}Events:${NC} Just the push event"
echo ""
echo "3. Test the webhook:"
echo "   Make a commit and push to main branch"
echo ""
echo "4. Check logs:"
echo "   sudo journalctl -u webhook -f"
echo "   tail -f ~/webhooks/deploy.log"
echo ""
echo -e "${YELLOW}⚠️ Important:${NC}"
echo "   - Save your secret: ~/webhooks/secret.txt"
echo "   - Check webhook status: sudo systemctl status webhook"
echo "   - View logs: sudo journalctl -u webhook -f"
echo ""
echo "=========================================="
echo ""

# Offer to show status
read -p "Show webhook service status? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo systemctl status webhook
fi

echo ""
echo -e "${GREEN}Happy deploying! 🚀${NC}"

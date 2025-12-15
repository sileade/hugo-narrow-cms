#!/bin/bash

# Hugo Narrow Site - Automated Setup Script
# This script helps you quickly set up and deploy your Hugo site

set -e

echo "🚀 Hugo Narrow Site - Setup Wizard"
echo "=================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI (gh) is not installed."
    echo "   Install it from: https://cli.github.com/"
    echo "   Or continue with manual setup."
    USE_GH_CLI=false
else
    USE_GH_CLI=true
fi

# Get repository information
echo "📝 Repository Setup"
echo "-------------------"
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter repository name (e.g., my-hugo-blog): " REPO_NAME

# Update hugo.yaml with user's information
echo ""
echo "🎨 Site Configuration"
echo "--------------------"
read -p "Enter your site title: " SITE_TITLE
read -p "Enter your name: " AUTHOR_NAME
read -p "Enter site description: " SITE_DESC

# Update hugo.yaml
sed -i "s|title: Hugo Narrow|title: $SITE_TITLE|g" hugo.yaml
sed -i "s|defaultAuthor: \"Hugo Narrow\"|defaultAuthor: \"$AUTHOR_NAME\"|g" hugo.yaml
sed -i "s|description: \".*\"|description: \"$SITE_DESC\"|g" hugo.yaml

# Update CMS config
sed -i "s|YOUR_USERNAME/YOUR_REPO|$GITHUB_USERNAME/$REPO_NAME|g" static/admin/config.yml

echo ""
echo "✅ Configuration updated!"
echo ""

# Initialize git if not already initialized
if [ ! -d .git ]; then
    echo "📦 Initializing Git repository..."
    git init
    git branch -M main
fi

# Create GitHub repository
if [ "$USE_GH_CLI" = true ]; then
    echo ""
    read -p "🌐 Create GitHub repository now? (y/n): " CREATE_REPO
    
    if [ "$CREATE_REPO" = "y" ] || [ "$CREATE_REPO" = "Y" ]; then
        echo "Creating repository on GitHub..."
        gh repo create "$REPO_NAME" --public --source=. --remote=origin
        
        echo "✅ Repository created!"
    fi
else
    echo ""
    echo "📝 Manual Steps Required:"
    echo "1. Go to https://github.com/new"
    echo "2. Create a repository named: $REPO_NAME"
    echo "3. Run these commands:"
    echo ""
    echo "   git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    echo ""
    read -p "Press Enter when you've created the repository..."
fi

# Commit and push
echo ""
echo "📤 Committing and pushing to GitHub..."
git add .
git commit -m "Initial commit: Hugo Narrow with CMS" || echo "Nothing to commit"

if [ "$USE_GH_CLI" = false ]; then
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" 2>/dev/null || true
fi

git push -u origin main

echo ""
echo "✅ Code pushed to GitHub!"
echo ""

# Deployment instructions
echo "🚀 Next Steps - Deploy to Vercel:"
echo "=================================="
echo ""
echo "1. Go to https://vercel.com"
echo "2. Click 'New Project'"
echo "3. Import: $GITHUB_USERNAME/$REPO_NAME"
echo "4. Configure:"
echo "   - Framework: Hugo"
echo "   - Build Command: hugo --minify"
echo "   - Output Directory: public"
echo "5. Click 'Deploy'"
echo ""
echo "📝 Admin Panel Setup:"
echo "===================="
echo ""
echo "Option 1 - GitHub Backend (Simplest):"
echo "   - Go to https://your-site.vercel.app/admin/"
echo "   - Authorize with GitHub"
echo "   - Start editing!"
echo ""
echo "Option 2 - Netlify Identity (More secure):"
echo "   1. Create a Netlify site (for Identity only)"
echo "   2. Enable Identity in Netlify settings"
echo "   3. Enable Git Gateway"
echo "   4. Update static/admin/config.yml with your Netlify URL"
echo ""
echo "📚 Documentation: See README.md for detailed instructions"
echo ""
echo "🎉 Setup complete! Happy blogging!"

#!/bin/bash

# Hugo Narrow CMS - Quick Installation Script
# Installs Hugo and dependencies for local development

set -e

echo "🚀 Hugo Narrow CMS - Installation Script"
echo "========================================="
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "🖥️  Detected OS: $MACHINE"
echo ""

# Check if Hugo is already installed
if command -v hugo &> /dev/null; then
    HUGO_VERSION=$(hugo version | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    echo "✅ Hugo is already installed (version $HUGO_VERSION)"
    
    # Check if it's extended version
    if hugo version | grep -q "extended"; then
        echo "✅ Hugo extended version detected"
    else
        echo "⚠️  Hugo standard version detected. Extended version recommended."
        read -p "Install Hugo extended? (y/n): " INSTALL_EXTENDED
        if [ "$INSTALL_EXTENDED" != "y" ]; then
            echo "Continuing with current version..."
        fi
    fi
else
    echo "❌ Hugo not found. Installing..."
    INSTALL_EXTENDED="y"
fi

# Install Hugo if needed
if [ "$INSTALL_EXTENDED" = "y" ]; then
    echo ""
    echo "📦 Installing Hugo Extended..."
    
    case "${MACHINE}" in
        Linux)
            echo "Installing for Linux..."
            HUGO_VERSION="0.146.0"
            wget -q "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
            sudo dpkg -i "hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
            rm "hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
            echo "✅ Hugo installed successfully"
            ;;
        
        Mac)
            echo "Installing for macOS..."
            if command -v brew &> /dev/null; then
                brew install hugo
                echo "✅ Hugo installed successfully"
            else
                echo "❌ Homebrew not found. Please install Homebrew first:"
                echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi
            ;;
        
        *)
            echo "❌ Unsupported OS. Please install Hugo manually:"
            echo "   https://gohugo.io/installation/"
            exit 1
            ;;
    esac
fi

echo ""
echo "🔍 Verifying installation..."
hugo version

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 Next steps:"
echo "1. Start development server:"
echo "   hugo server -D"
echo ""
echo "2. Open browser:"
echo "   http://localhost:1313"
echo ""
echo "3. Access admin panel:"
echo "   http://localhost:1313/admin/"
echo ""
echo "4. Build for production:"
echo "   hugo --minify"
echo ""
echo "📚 See README.md for more information"
echo ""
echo "🎉 Happy coding!"

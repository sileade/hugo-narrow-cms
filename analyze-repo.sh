#!/bin/bash

echo "=========================================="
echo "Repository Analysis Report"
echo "=========================================="
echo ""

# 1. Check Hugo configuration
echo "1. Checking Hugo Configuration..."
if hugo config > /tmp/hugo-config-check.log 2>&1; then
    echo "   ✅ Hugo configuration is valid"
else
    echo "   ❌ Hugo configuration has errors:"
    cat /tmp/hugo-config-check.log
fi
echo ""

# 2. Check for missing files
echo "2. Checking for missing critical files..."
CRITICAL_FILES=(
    "hugo.yaml"
    "static/admin/config.yml"
    "static/admin/index.html"
    "content/_index.md"
    "content/about.md"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file is missing"
    fi
done
echo ""

# 3. Check YAML syntax
echo "3. Checking YAML syntax..."
for yaml_file in hugo.yaml static/admin/config.yml; do
    if [ -f "$yaml_file" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
            echo "   ✅ $yaml_file syntax is valid"
        else
            echo "   ❌ $yaml_file has syntax errors"
        fi
    fi
done
echo ""

# 4. Check JSON syntax
echo "4. Checking JSON syntax..."
for json_file in data/*.json; do
    if [ -f "$json_file" ]; then
        if python3 -c "import json; json.load(open('$json_file'))" 2>/dev/null; then
            echo "   ✅ $json_file syntax is valid"
        else
            echo "   ❌ $json_file has syntax errors"
        fi
    fi
done
echo ""

# 5. Check for broken internal links
echo "5. Checking content files..."
CONTENT_COUNT=$(find content -name "*.md" 2>/dev/null | wc -l)
echo "   Found $CONTENT_COUNT markdown files"
echo ""

# 6. Check theme
echo "6. Checking theme..."
if [ -d "themes/hugo-narrow" ]; then
    echo "   ✅ Theme directory exists"
    LAYOUT_COUNT=$(find themes/hugo-narrow/layouts -name "*.html" 2>/dev/null | wc -l)
    echo "   Found $LAYOUT_COUNT layout files"
else
    echo "   ❌ Theme directory missing"
fi
echo ""

# 7. Check Docker files
echo "7. Checking Docker configuration..."
if [ -f "Dockerfile" ]; then
    echo "   ✅ Dockerfile exists"
else
    echo "   ❌ Dockerfile missing"
fi

if [ -f "docker-compose.yml" ]; then
    echo "   ✅ docker-compose.yml exists"
else
    echo "   ❌ docker-compose.yml missing"
fi
echo ""

# 8. Check scripts
echo "8. Checking scripts..."
SCRIPTS=(
    "docker-deploy.sh"
    "test-repository.sh"
    "run-tests-20x.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "   ✅ $script exists and is executable"
        else
            echo "   ⚠️  $script exists but is not executable"
        fi
    else
        echo "   ❌ $script is missing"
    fi
done
echo ""

# 9. Check documentation
echo "9. Checking documentation..."
DOCS=(
    "README.md"
    "DOCKER.md"
    "WEBHOOK_SETUP.md"
    "TESTING.md"
    "CONTRIBUTING.md"
    "ADMIN_PANEL.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        SIZE=$(wc -c < "$doc")
        echo "   ✅ $doc exists (${SIZE} bytes)"
    else
        echo "   ❌ $doc is missing"
    fi
done
echo ""

# 10. Check Git status
echo "10. Checking Git repository..."
if git status > /dev/null 2>&1; then
    echo "   ✅ Git repository is valid"
    UNCOMMITTED=$(git status --porcelain | wc -l)
    if [ "$UNCOMMITTED" -eq 0 ]; then
        echo "   ✅ No uncommitted changes"
    else
        echo "   ⚠️  $UNCOMMITTED uncommitted changes"
    fi
else
    echo "   ❌ Git repository has issues"
fi
echo ""

echo "=========================================="
echo "Analysis Complete"
echo "=========================================="

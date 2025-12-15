#!/bin/bash

echo "=========================================="
echo "Checking for Potential Issues"
echo "=========================================="
echo ""

# Check 1: Verify admin config has correct repo
echo "1. Checking admin config repository..."
REPO_LINE=$(grep "repo:" static/admin/config.yml)
echo "   $REPO_LINE"
if echo "$REPO_LINE" | grep -q "sileade/hugo-narrow-cms"; then
    echo "   ✅ Repository is correctly configured"
else
    echo "   ❌ Repository configuration may be incorrect"
fi
echo ""

# Check 2: Verify baseURL in hugo.yaml
echo "2. Checking baseURL..."
BASE_URL=$(grep "^baseURL:" hugo.yaml)
echo "   $BASE_URL"
echo ""

# Check 3: Check for empty content files
echo "3. Checking for empty content files..."
EMPTY_COUNT=0
for file in content/**/*.md; do
    if [ -f "$file" ]; then
        SIZE=$(wc -c < "$file")
        if [ "$SIZE" -lt 10 ]; then
            echo "   ⚠️  $file is very small ($SIZE bytes)"
            EMPTY_COUNT=$((EMPTY_COUNT + 1))
        fi
    fi
done
if [ "$EMPTY_COUNT" -eq 0 ]; then
    echo "   ✅ No empty content files found"
fi
echo ""

# Check 4: Verify theme configuration
echo "4. Checking theme configuration..."
THEME_LINE=$(grep "^theme:" hugo.yaml)
echo "   $THEME_LINE"
if echo "$THEME_LINE" | grep -q "hugo-narrow"; then
    echo "   ✅ Theme is correctly configured"
else
    echo "   ❌ Theme configuration may be incorrect"
fi
echo ""

# Check 5: Check for TODO or FIXME comments
echo "5. Checking for TODO/FIXME comments..."
TODO_COUNT=$(grep -r "TODO\|FIXME" --include="*.md" --include="*.html" --include="*.yml" --include="*.yaml" . 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    echo "   ⚠️  Found $TODO_COUNT TODO/FIXME comments"
    grep -r "TODO\|FIXME" --include="*.md" --include="*.html" --include="*.yml" --include="*.yaml" . 2>/dev/null | head -5
else
    echo "   ✅ No TODO/FIXME comments found"
fi
echo ""

# Check 6: Verify all markdown files have frontmatter
echo "6. Checking markdown frontmatter..."
NO_FRONTMATTER=0
for file in content/**/*.md; do
    if [ -f "$file" ]; then
        if ! head -1 "$file" | grep -q "^---"; then
            echo "   ⚠️  $file may be missing frontmatter"
            NO_FRONTMATTER=$((NO_FRONTMATTER + 1))
        fi
    fi
done
if [ "$NO_FRONTMATTER" -eq 0 ]; then
    echo "   ✅ All content files have frontmatter"
fi
echo ""

# Check 7: Verify images directory exists
echo "7. Checking images directory..."
if [ -d "static/images" ]; then
    IMAGE_COUNT=$(find static/images -type f 2>/dev/null | wc -l)
    echo "   ✅ Images directory exists with $IMAGE_COUNT files"
else
    echo "   ⚠️  Images directory doesn't exist, creating it..."
    mkdir -p static/images/uploads
    echo "   ✅ Created static/images/uploads"
fi
echo ""

# Check 8: Verify data files are valid JSON
echo "8. Validating JSON files..."
for json_file in data/*.json; do
    if [ -f "$json_file" ]; then
        if python3 -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "   ✅ $json_file is valid JSON"
        else
            echo "   ❌ $json_file has JSON errors"
        fi
    fi
done
echo ""

echo "=========================================="
echo "Issue Check Complete"
echo "=========================================="

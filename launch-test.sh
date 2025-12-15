#!/bin/bash

echo "=========================================="
echo "Launch Testing - Iteration $1"
echo "=========================================="
echo ""

START_TIME=$(date +%s)

# Test 1: Hugo Build
echo "Test 1: Hugo Build..."
rm -rf public/
if hugo --minify > /tmp/build-$1.log 2>&1; then
    BUILD_TIME=$(grep "Total in" /tmp/build-$1.log | awk '{print $3}')
    echo "   ✅ Build successful in $BUILD_TIME"
else
    echo "   ❌ Build failed"
    cat /tmp/build-$1.log
    exit 1
fi

# Test 2: Check Output
echo "Test 2: Checking output..."
if [ -d "public" ]; then
    FILE_COUNT=$(find public -type f | wc -l)
    DIR_SIZE=$(du -sh public | awk '{print $1}')
    echo "   ✅ Output directory created"
    echo "   Files: $FILE_COUNT"
    echo "   Size: $DIR_SIZE"
else
    echo "   ❌ Output directory not created"
    exit 1
fi

# Test 3: Verify Critical Files
echo "Test 3: Verifying critical files..."
CRITICAL_FILES=(
    "public/index.html"
    "public/admin/index.html"
    "public/admin/config.yml"
    "public/404.html"
)

ALL_EXIST=true
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(wc -c < "$file")
        echo "   ✅ $file exists ($SIZE bytes)"
    else
        echo "   ❌ $file missing"
        ALL_EXIST=false
    fi
done

if [ "$ALL_EXIST" = false ]; then
    exit 1
fi

# Test 4: Check HTML Validity
echo "Test 4: Checking HTML structure..."
if grep -q "<html" public/index.html && grep -q "</html>" public/index.html; then
    echo "   ✅ HTML structure is valid"
else
    echo "   ❌ HTML structure may be invalid"
fi

# Test 5: Check Admin Panel
echo "Test 5: Checking admin panel..."
if grep -q "Decap CMS" public/admin/index.html; then
    echo "   ✅ Admin panel configured"
else
    echo "   ⚠️  Admin panel may not be configured correctly"
fi

# Test 6: Check Static Assets
echo "Test 6: Checking static assets..."
if [ -d "public/css" ] && [ -d "public/js" ]; then
    CSS_COUNT=$(find public/css -name "*.css" | wc -l)
    JS_COUNT=$(find public/js -name "*.js" 2>/dev/null | wc -l)
    echo "   ✅ Static assets present"
    echo "   CSS files: $CSS_COUNT"
    echo "   JS files: $JS_COUNT"
else
    echo "   ⚠️  Some static assets may be missing"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "=========================================="
echo "Iteration $1 Complete in ${DURATION}s"
echo "=========================================="
echo ""

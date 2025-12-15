#!/bin/bash
# Comprehensive Test Suite for Hugo Narrow CMS
# Tests all components: Hugo, Docker, Admin Panel, Configs, etc.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Test result tracking
declare -a FAILED_TEST_NAMES
declare -a WARNING_MESSAGES

# Helper functions
test_start() {
    ((TOTAL_TESTS++))
    echo -n "  Testing: $1... "
}

test_pass() {
    ((PASSED_TESTS++))
    echo -e "${GREEN}✓${NC}"
}

test_fail() {
    ((FAILED_TESTS++))
    FAILED_TEST_NAMES+=("$1")
    echo -e "${RED}✗${NC}"
    if [ -n "$2" ]; then
        echo -e "    ${RED}Error: $2${NC}"
    fi
}

test_warn() {
    ((WARNINGS++))
    WARNING_MESSAGES+=("$1")
    echo -e "${YELLOW}⚠${NC}"
    if [ -n "$2" ]; then
        echo -e "    ${YELLOW}Warning: $2${NC}"
    fi
}

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║         HUGO NARROW CMS - COMPREHENSIVE TEST SUITE         ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# 1. REPOSITORY STRUCTURE TESTS
# ============================================================================
echo -e "${BLUE}[1/10] Repository Structure Tests${NC}"

test_start "Root directory exists"
if [ -d "$(pwd)" ]; then test_pass; else test_fail "Root directory"; fi

test_start "Hugo config file (hugo.yaml)"
if [ -f "hugo.yaml" ]; then test_pass; else test_fail "hugo.yaml not found"; fi

test_start "Content directory"
if [ -d "content" ]; then test_pass; else test_fail "content/ not found"; fi

test_start "Themes directory"
if [ -d "themes/hugo-narrow" ]; then test_pass; else test_fail "themes/hugo-narrow not found"; fi

test_start "Static directory"
if [ -d "static" ]; then test_pass; else test_fail "static/ not found"; fi

test_start "Admin panel files"
if [ -d "admin" ] && [ -f "admin/app.py" ]; then test_pass; else test_fail "admin/ not complete"; fi

test_start "Docker files"
if [ -f "Dockerfile" ] && [ -f "docker-compose.yml" ]; then test_pass; else test_fail "Docker files missing"; fi

test_start "Production Docker Compose"
if [ -f "docker-compose.prod.yml" ]; then test_pass; else test_fail "docker-compose.prod.yml missing"; fi

test_start "Deployment scripts"
if [ -x "deploy-prod.sh" ] && [ -x "quick-start.sh" ]; then test_pass; else test_warn "Deployment scripts" "Scripts not executable"; fi

test_start "Documentation files"
if [ -f "README.md" ] && [ -f "DOCKER.md" ]; then test_pass; else test_warn "Documentation" "Some docs missing"; fi

echo ""

# ============================================================================
# 2. HUGO CONFIGURATION TESTS
# ============================================================================
echo -e "${BLUE}[2/10] Hugo Configuration Tests${NC}"

test_start "Hugo config syntax (YAML)"
if python3 -c "import yaml; yaml.safe_load(open('hugo.yaml'))" 2>/dev/null; then
    test_pass
else
    test_fail "Hugo config syntax" "Invalid YAML"
fi

test_start "baseURL configured"
if grep -q "baseURL:" hugo.yaml; then test_pass; else test_warn "baseURL" "Not configured"; fi

test_start "Theme configured"
if grep -q "theme:" hugo.yaml; then test_pass; else test_fail "Theme" "Not configured"; fi

test_start "Language configured"
if grep -q "languageCode:" hugo.yaml; then test_pass; else test_warn "Language" "Not configured"; fi

test_start "Title configured"
if grep -q "title:" hugo.yaml; then test_pass; else test_warn "Title" "Not configured"; fi

echo ""

# ============================================================================
# 3. HUGO BUILD TESTS
# ============================================================================
echo -e "${BLUE}[3/10] Hugo Build Tests${NC}"

test_start "Hugo binary available"
if command -v hugo &> /dev/null; then
    test_pass
else
    test_warn "Hugo binary" "Not installed locally (will use Docker)"
fi

if command -v hugo &> /dev/null; then
    test_start "Hugo version"
    HUGO_VERSION=$(hugo version 2>/dev/null | grep -oP 'v\d+\.\d+\.\d+' | head -1)
    if [ -n "$HUGO_VERSION" ]; then
        echo -e "${GREEN}✓${NC} ($HUGO_VERSION)"
    else
        test_warn "Hugo version" "Could not determine version"
    fi

    test_start "Hugo build (clean)"
    rm -rf public 2>/dev/null
    if hugo --minify > /tmp/hugo-build.log 2>&1; then
        test_pass
    else
        test_fail "Hugo build" "Build failed (see /tmp/hugo-build.log)"
    fi

    test_start "Public directory created"
    if [ -d "public" ]; then test_pass; else test_fail "Public directory" "Not created after build"; fi

    test_start "Index.html generated"
    if [ -f "public/index.html" ]; then test_pass; else test_fail "index.html" "Not generated"; fi

    test_start "Admin panel in public"
    if [ -f "public/admin/index.html" ]; then test_pass; else test_fail "Admin panel" "Not copied to public/"; fi

    test_start "CSS files generated"
    if find public -name "*.css" | grep -q .; then test_pass; else test_warn "CSS files" "No CSS found"; fi

    test_start "Build performance"
    BUILD_TIME=$(grep "Total in" /tmp/hugo-build.log 2>/dev/null | grep -oP '\d+ ms' || echo "unknown")
    if [ "$BUILD_TIME" != "unknown" ]; then
        echo -e "${GREEN}✓${NC} ($BUILD_TIME)"
    else
        test_warn "Build performance" "Could not measure"
    fi
fi

echo ""

# ============================================================================
# 4. DOCKER CONFIGURATION TESTS
# ============================================================================
echo -e "${BLUE}[4/10] Docker Configuration Tests${NC}"

test_start "Dockerfile exists"
if [ -f "Dockerfile" ]; then test_pass; else test_fail "Dockerfile" "Not found"; fi

test_start "Dockerfile syntax"
if grep -q "FROM" Dockerfile && grep -q "WORKDIR" Dockerfile; then
    test_pass
else
    test_fail "Dockerfile syntax" "Invalid format"
fi

test_start "docker-compose.yml syntax"
if python3 -c "import yaml; yaml.safe_load(open('docker-compose.yml'))" 2>/dev/null; then
    test_pass
else
    test_fail "docker-compose.yml" "Invalid YAML"
fi

test_start "docker-compose.prod.yml syntax"
if python3 -c "import yaml; yaml.safe_load(open('docker-compose.prod.yml'))" 2>/dev/null; then
    test_pass
else
    test_fail "docker-compose.prod.yml" "Invalid YAML"
fi

test_start "Docker services defined"
SERVICES=$(grep -c "^  [a-z]" docker-compose.prod.yml 2>/dev/null || echo 0)
if [ "$SERVICES" -ge 5 ]; then
    echo -e "${GREEN}✓${NC} ($SERVICES services)"
else
    test_warn "Docker services" "Only $SERVICES services defined"
fi

test_start ".dockerignore exists"
if [ -f ".dockerignore" ]; then test_pass; else test_warn ".dockerignore" "Not found"; fi

echo ""

# ============================================================================
# 5. ADMIN PANEL TESTS
# ============================================================================
echo -e "${BLUE}[5/10] Admin Panel Tests${NC}"

test_start "Admin app.py exists"
if [ -f "admin/app.py" ]; then test_pass; else test_fail "app.py" "Not found"; fi

test_start "Admin requirements.txt"
if [ -f "admin/requirements.txt" ]; then test_pass; else test_fail "requirements.txt" "Not found"; fi

test_start "Admin Dockerfile"
if [ -f "admin/Dockerfile" ]; then test_pass; else test_fail "Admin Dockerfile" "Not found"; fi

test_start "Flask imports"
if grep -q "from flask import" admin/app.py; then test_pass; else test_fail "Flask imports" "Not found in app.py"; fi

test_start "Admin templates"
TEMPLATE_COUNT=$(find admin/templates -name "*.html" 2>/dev/null | wc -l)
if [ "$TEMPLATE_COUNT" -ge 4 ]; then
    echo -e "${GREEN}✓${NC} ($TEMPLATE_COUNT templates)"
else
    test_fail "Admin templates" "Only $TEMPLATE_COUNT templates found (need 4+)"
fi

test_start "Python syntax (app.py)"
if python3 -m py_compile admin/app.py 2>/dev/null; then
    test_pass
else
    test_fail "Python syntax" "Syntax error in app.py"
fi

echo ""

# ============================================================================
# 6. STATIC ADMIN PANEL TESTS
# ============================================================================
echo -e "${BLUE}[6/10] Static Admin Panel (Decap CMS) Tests${NC}"

test_start "Admin index.html"
if [ -f "static/admin/index.html" ]; then test_pass; else test_fail "admin/index.html" "Not found"; fi

test_start "Admin config.yml"
if [ -f "static/admin/config.yml" ]; then test_pass; else test_fail "admin/config.yml" "Not found"; fi

test_start "Decap CMS script"
if grep -q "netlify-cms" static/admin/index.html 2>/dev/null; then
    test_pass
else
    test_fail "Decap CMS" "Script not found in index.html"
fi

test_start "CMS config syntax"
if python3 -c "import yaml; yaml.safe_load(open('static/admin/config.yml'))" 2>/dev/null; then
    test_pass
else
    test_fail "CMS config" "Invalid YAML"
fi

test_start "CMS backend configured"
if grep -q "backend:" static/admin/config.yml; then test_pass; else test_fail "CMS backend" "Not configured"; fi

test_start "CMS collections defined"
COLLECTIONS=$(grep -c "^  - name:" static/admin/config.yml 2>/dev/null || echo 0)
if [ "$COLLECTIONS" -ge 2 ]; then
    echo -e "${GREEN}✓${NC} ($COLLECTIONS collections)"
else
    test_warn "CMS collections" "Only $COLLECTIONS collections"
fi

echo ""

# ============================================================================
# 7. CONFIGURATION FILES TESTS
# ============================================================================
echo -e "${BLUE}[7/10] Configuration Files Tests${NC}"

test_start ".env.example exists"
if [ -f ".env.example" ]; then test_pass; else test_fail ".env.example" "Not found"; fi

test_start ".gitignore exists"
if [ -f ".gitignore" ]; then test_pass; else test_fail ".gitignore" "Not found"; fi

test_start "vercel.json exists"
if [ -f "vercel.json" ]; then test_pass; else test_warn "vercel.json" "Not found"; fi

test_start "netlify.toml exists"
if [ -f "netlify.toml" ]; then test_pass; else test_warn "netlify.toml" "Not found"; fi

test_start "Traefik config"
if [ -f "traefik/traefik.yml" ]; then test_pass; else test_warn "Traefik config" "Not found"; fi

test_start "Makefile exists"
if [ -f "Makefile" ]; then test_pass; else test_warn "Makefile" "Not found"; fi

echo ""

# ============================================================================
# 8. GITHUB ACTIONS TESTS
# ============================================================================
echo -e "${BLUE}[8/10] GitHub Actions Tests${NC}"

test_start ".github/workflows directory"
if [ -d ".github/workflows" ]; then test_pass; else test_fail ".github/workflows" "Not found"; fi

test_start "Workflow files"
WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" 2>/dev/null | wc -l)
if [ "$WORKFLOW_COUNT" -ge 2 ]; then
    echo -e "${GREEN}✓${NC} ($WORKFLOW_COUNT workflows)"
else
    test_warn "Workflows" "Only $WORKFLOW_COUNT workflows found"
fi

test_start "Test workflow (test.yml)"
if [ -f ".github/workflows/test.yml" ]; then test_pass; else test_warn "test.yml" "Not found"; fi

test_start "Deploy workflow (deploy.yml)"
if [ -f ".github/workflows/deploy.yml" ]; then test_pass; else test_warn "deploy.yml" "Not found"; fi

test_start "CI workflow (ci.yml)"
if [ -f ".github/workflows/ci.yml" ]; then test_pass; else test_warn "ci.yml" "Not found"; fi

echo ""

# ============================================================================
# 9. DOCUMENTATION TESTS
# ============================================================================
echo -e "${BLUE}[9/10] Documentation Tests${NC}"

test_start "README.md exists"
if [ -f "README.md" ]; then test_pass; else test_fail "README.md" "Not found"; fi

test_start "README.md not empty"
if [ -s "README.md" ] && [ $(wc -l < README.md) -gt 10 ]; then test_pass; else test_fail "README.md" "Too short or empty"; fi

test_start "DOCKER.md exists"
if [ -f "DOCKER.md" ]; then test_pass; else test_warn "DOCKER.md" "Not found"; fi

test_start "ADMIN_PANEL.md exists"
if [ -f "ADMIN_PANEL.md" ]; then test_pass; else test_warn "ADMIN_PANEL.md" "Not found"; fi

test_start "TESTING.md exists"
if [ -f "TESTING.md" ]; then test_pass; else test_warn "TESTING.md" "Not found"; fi

test_start "LICENSE file"
if [ -f "LICENSE" ]; then test_pass; else test_warn "LICENSE" "Not found"; fi

echo ""

# ============================================================================
# 10. CONTENT TESTS
# ============================================================================
echo -e "${BLUE}[10/10] Content Tests${NC}"

test_start "Posts directory"
if [ -d "content/posts" ]; then test_pass; else test_warn "content/posts" "Not found"; fi

test_start "Sample posts exist"
POST_COUNT=$(find content/posts -name "*.md" 2>/dev/null | wc -l)
if [ "$POST_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} ($POST_COUNT posts)"
else
    test_warn "Sample posts" "No posts found"
fi

test_start "About page"
if [ -f "content/about.md" ] || [ -f "content/pages/about.md" ]; then test_pass; else test_warn "About page" "Not found"; fi

test_start "Frontmatter in posts"
if find content/posts -name "*.md" -exec grep -l "^---$" {} \; 2>/dev/null | grep -q .; then
    test_pass
else
    test_warn "Frontmatter" "No posts with frontmatter found"
fi

echo ""
echo "════════════════════════════════════════════════════════════"

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${BLUE}TEST SUMMARY${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Total Tests:    $TOTAL_TESTS"
echo -e "  ${GREEN}Passed:         $PASSED_TESTS${NC}"
echo -e "  ${RED}Failed:         $FAILED_TESTS${NC}"
echo -e "  ${YELLOW}Warnings:       $WARNINGS${NC}"
echo ""

SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo "  Success Rate:   $SUCCESS_RATE%"
echo ""

# Show failed tests
if [ ${#FAILED_TEST_NAMES[@]} -gt 0 ]; then
    echo -e "${RED}FAILED TESTS:${NC}"
    for test_name in "${FAILED_TEST_NAMES[@]}"; do
        echo -e "  ${RED}✗${NC} $test_name"
    done
    echo ""
fi

# Show warnings
if [ ${#WARNING_MESSAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}WARNINGS:${NC}"
    for warning in "${WARNING_MESSAGES[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $warning"
    done
    echo ""
fi

echo "════════════════════════════════════════════════════════════"
echo ""

# Final verdict
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo ""
    echo "🎉 Repository is ready for deployment!"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo "Please fix the failed tests before deploying."
    exit 1
fi

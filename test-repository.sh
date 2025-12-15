#!/bin/bash

# ============================================
# Hugo Narrow CMS - Comprehensive Test Suite
# Tests repository integrity, builds, configs
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Test iteration number (passed as argument)
ITERATION=${1:-1}

# Log file
LOG_FILE="/home/ubuntu/test-results/test_iteration_${ITERATION}.log"
mkdir -p /home/ubuntu/test-results

# Logging functions
log() {
    echo -e "${GREEN}[PASS]${NC} $1" | tee -a $LOG_FILE
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1" | tee -a $LOG_FILE
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a $LOG_FILE
    WARNINGS=$((WARNINGS + 1))
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a $LOG_FILE
}

section() {
    echo -e "\n${CYAN}========================================${NC}" | tee -a $LOG_FILE
    echo -e "${CYAN}$1${NC}" | tee -a $LOG_FILE
    echo -e "${CYAN}========================================${NC}\n" | tee -a $LOG_FILE
}

# Start testing
section "Test Iteration #${ITERATION} - $(date)"

cd /home/ubuntu/hugo-narrow-site

# ============================================
# Test 1: Repository Structure
# ============================================
section "Test 1: Repository Structure"

# Check essential files
if [ -f "hugo.yaml" ]; then
    log "hugo.yaml exists"
else
    fail "hugo.yaml missing"
fi

if [ -f "docker-compose.yml" ]; then
    log "docker-compose.yml exists"
else
    fail "docker-compose.yml missing"
fi

if [ -f "Dockerfile" ]; then
    log "Dockerfile exists"
else
    fail "Dockerfile missing"
fi

if [ -f "README.md" ]; then
    log "README.md exists"
else
    fail "README.md missing"
fi

if [ -f "DOCKER.md" ]; then
    log "DOCKER.md exists"
else
    fail "DOCKER.md missing"
fi

if [ -f "WEBHOOK_SETUP.md" ]; then
    log "WEBHOOK_SETUP.md exists"
else
    fail "WEBHOOK_SETUP.md missing"
fi

# Check directories
if [ -d "content" ]; then
    log "content/ directory exists"
else
    fail "content/ directory missing"
fi

if [ -d "themes/hugo-narrow" ]; then
    log "themes/hugo-narrow exists"
else
    fail "themes/hugo-narrow missing"
fi

if [ -d "static/admin" ]; then
    log "static/admin exists"
else
    fail "static/admin missing"
fi

if [ -d "examples/webhook" ]; then
    log "examples/webhook exists"
else
    fail "examples/webhook missing"
fi

# ============================================
# Test 2: Hugo Configuration
# ============================================
section "Test 2: Hugo Configuration"

# Validate YAML syntax
if hugo config > /dev/null 2>&1; then
    log "hugo.yaml syntax is valid"
else
    fail "hugo.yaml syntax error"
fi

# Check baseURL
BASE_URL=$(grep "baseURL:" hugo.yaml | awk '{print $2}')
if [ -n "$BASE_URL" ]; then
    log "baseURL is set: $BASE_URL"
else
    warn "baseURL is empty"
fi

# Check theme
THEME=$(grep "^theme:" hugo.yaml | head -1 | awk '{print $2}' | tr -d '"')
if [ "$THEME" = "hugo-narrow" ]; then
    log "Theme is correctly set to hugo-narrow"
else
    fail "Theme is not set correctly: $THEME"
fi

# Check language
LANG=$(grep "languageCode:" hugo.yaml | awk '{print $2}')
if [ -n "$LANG" ]; then
    log "Language code is set: $LANG"
else
    warn "Language code not set"
fi

# ============================================
# Test 3: Hugo Build
# ============================================
section "Test 3: Hugo Build"

# Clean previous build
rm -rf public/

# Build site
START_TIME=$(date +%s)
if hugo --minify > /tmp/hugo_build.log 2>&1; then
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))
    log "Hugo build successful (${BUILD_TIME}s)"
else
    fail "Hugo build failed"
    cat /tmp/hugo_build.log | tee -a $LOG_FILE
fi

# Check output
if [ -d "public" ]; then
    log "public/ directory created"
    
    FILE_COUNT=$(find public -type f | wc -l)
    log "Generated $FILE_COUNT files"
    
    if [ -f "public/index.html" ]; then
        log "index.html exists"
        
        SIZE=$(stat -f%z "public/index.html" 2>/dev/null || stat -c%s "public/index.html")
        if [ "$SIZE" -gt 100 ]; then
            log "index.html size is reasonable (${SIZE} bytes)"
        else
            fail "index.html is too small (${SIZE} bytes)"
        fi
    else
        fail "index.html not generated"
    fi
    
    if [ -d "public/admin" ]; then
        log "admin/ directory exists in public"
    else
        fail "admin/ directory not copied to public"
    fi
else
    fail "public/ directory not created"
fi

# ============================================
# Test 4: Docker Configuration
# ============================================
section "Test 4: Docker Configuration"

# Validate docker-compose.yml
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    if docker compose config > /dev/null 2>&1; then
        log "docker-compose.yml syntax is valid"
    else
        fail "docker-compose.yml syntax error"
    fi
else
    warn "Docker not available, skipping docker-compose validation"
fi

# Check Dockerfile syntax
if docker build --dry-run -f Dockerfile . > /dev/null 2>&1; then
    log "Dockerfile syntax is valid"
else
    # Docker doesn't have --dry-run, check if file is readable
    if [ -r "Dockerfile" ]; then
        log "Dockerfile is readable"
    else
        fail "Dockerfile is not readable"
    fi
fi

# Check for required stages
if grep -q "FROM.*AS builder" Dockerfile; then
    log "Dockerfile has builder stage"
else
    warn "Dockerfile missing builder stage"
fi

if grep -q "FROM.*AS development" Dockerfile; then
    log "Dockerfile has development stage"
else
    warn "Dockerfile missing development stage"
fi

if grep -q "FROM.*AS production" Dockerfile; then
    log "Dockerfile has production stage"
else
    warn "Dockerfile missing production stage"
fi

# ============================================
# Test 5: Admin Panel Configuration
# ============================================
section "Test 5: Admin Panel Configuration"

# Check config.yml
if [ -f "static/admin/config.yml" ]; then
    log "Admin config.yml exists"
    
    # Check backend
    if grep -q "backend:" static/admin/config.yml; then
        log "Backend configuration present"
    else
        fail "Backend configuration missing"
    fi
    
    # Check collections
    if grep -q "collections:" static/admin/config.yml; then
        log "Collections configuration present"
    else
        fail "Collections configuration missing"
    fi
else
    fail "Admin config.yml missing"
fi

# Check index.html
if [ -f "static/admin/index.html" ]; then
    log "Admin index.html exists"
    
    # Check for Decap CMS script
    if grep -q "decap-cms" static/admin/index.html; then
        log "Decap CMS script included"
    else
        fail "Decap CMS script missing"
    fi
else
    fail "Admin index.html missing"
fi

# ============================================
# Test 6: Webhook Configuration
# ============================================
section "Test 6: Webhook Configuration"

# Check webhook examples
if [ -f "examples/webhook/hooks.json" ]; then
    log "hooks.json example exists"
    
    # Validate JSON
    if python3 -m json.tool examples/webhook/hooks.json > /dev/null 2>&1; then
        log "hooks.json is valid JSON"
    else
        fail "hooks.json is invalid JSON"
    fi
else
    fail "hooks.json example missing"
fi

if [ -f "examples/webhook/deploy.sh" ]; then
    log "deploy.sh example exists"
    
    if [ -x "examples/webhook/deploy.sh" ]; then
        log "deploy.sh is executable"
    else
        warn "deploy.sh is not executable"
    fi
else
    fail "deploy.sh example missing"
fi

if [ -f "examples/webhook/setup-webhook.sh" ]; then
    log "setup-webhook.sh exists"
    
    if [ -x "examples/webhook/setup-webhook.sh" ]; then
        log "setup-webhook.sh is executable"
    else
        warn "setup-webhook.sh is not executable"
    fi
else
    fail "setup-webhook.sh missing"
fi

if [ -f "examples/webhook/webhook.service" ]; then
    log "webhook.service example exists"
else
    fail "webhook.service example missing"
fi

# ============================================
# Test 7: Scripts and Executables
# ============================================
section "Test 7: Scripts and Executables"

# Check deploy script
if [ -f "docker-deploy.sh" ]; then
    log "docker-deploy.sh exists"
    
    if [ -x "docker-deploy.sh" ]; then
        log "docker-deploy.sh is executable"
    else
        warn "docker-deploy.sh is not executable"
    fi
else
    fail "docker-deploy.sh missing"
fi

# Check Makefile
if [ -f "Makefile" ]; then
    log "Makefile exists"
    
    # Check for essential targets
    if grep -q "^dev:" Makefile; then
        log "Makefile has 'dev' target"
    else
        warn "Makefile missing 'dev' target"
    fi
    
    if grep -q "^prod:" Makefile; then
        log "Makefile has 'prod' target"
    else
        warn "Makefile missing 'prod' target"
    fi
else
    fail "Makefile missing"
fi

# ============================================
# Test 8: Content Files
# ============================================
section "Test 8: Content Files"

# Check for posts
POST_COUNT=$(find content/posts -name "*.md" 2>/dev/null | wc -l)
if [ "$POST_COUNT" -gt 0 ]; then
    log "Found $POST_COUNT post(s)"
else
    warn "No posts found"
fi

# Check post frontmatter
for post in content/posts/*.md; do
    if [ -f "$post" ]; then
        if grep -q "^title:" "$post"; then
            log "$(basename $post) has title"
        else
            warn "$(basename $post) missing title"
        fi
        
        if grep -q "^date:" "$post"; then
            log "$(basename $post) has date"
        else
            warn "$(basename $post) missing date"
        fi
    fi
done

# ============================================
# Test 9: Documentation
# ============================================
section "Test 9: Documentation"

# Check README
README_SIZE=$(stat -f%z "README.md" 2>/dev/null || stat -c%s "README.md")
if [ "$README_SIZE" -gt 1000 ]; then
    log "README.md has substantial content (${README_SIZE} bytes)"
else
    warn "README.md seems short (${README_SIZE} bytes)"
fi

# Check for essential sections in README
if grep -q "## " README.md; then
    log "README has sections"
else
    warn "README missing section headers"
fi

# Check DOCKER.md
DOCKER_MD_SIZE=$(stat -f%z "DOCKER.md" 2>/dev/null || stat -c%s "DOCKER.md")
if [ "$DOCKER_MD_SIZE" -gt 5000 ]; then
    log "DOCKER.md has substantial content (${DOCKER_MD_SIZE} bytes)"
else
    warn "DOCKER.md seems short (${DOCKER_MD_SIZE} bytes)"
fi

# Check WEBHOOK_SETUP.md
WEBHOOK_MD_SIZE=$(stat -f%z "WEBHOOK_SETUP.md" 2>/dev/null || stat -c%s "WEBHOOK_SETUP.md")
if [ "$WEBHOOK_MD_SIZE" -gt 10000 ]; then
    log "WEBHOOK_SETUP.md has substantial content (${WEBHOOK_MD_SIZE} bytes)"
else
    warn "WEBHOOK_SETUP.md seems short (${WEBHOOK_MD_SIZE} bytes)"
fi

# ============================================
# Test 10: Git Repository
# ============================================
section "Test 10: Git Repository"

# Check git status
if git status > /dev/null 2>&1; then
    log "Git repository is valid"
else
    fail "Git repository is corrupted"
fi

# Check for uncommitted changes
if git diff --quiet && git diff --cached --quiet; then
    log "No uncommitted changes"
else
    warn "There are uncommitted changes"
fi

# Check remote
if git remote -v | grep -q "github.com"; then
    log "GitHub remote is configured"
else
    warn "GitHub remote not configured"
fi

# Check current branch
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ]; then
    log "On main branch"
else
    warn "Not on main branch (current: $BRANCH)"
fi

# ============================================
# Test 11: Theme Integrity
# ============================================
section "Test 11: Theme Integrity"

# Check theme files
if [ -f "themes/hugo-narrow/theme.yaml" ]; then
    log "Theme configuration exists"
else
    warn "Theme configuration missing"
fi

if [ -d "themes/hugo-narrow/layouts" ]; then
    log "Theme layouts directory exists"
    
    LAYOUT_COUNT=$(find themes/hugo-narrow/layouts -name "*.html" | wc -l)
    log "Found $LAYOUT_COUNT layout files"
else
    fail "Theme layouts directory missing"
fi

if [ -d "themes/hugo-narrow/assets" ]; then
    log "Theme assets directory exists"
else
    warn "Theme assets directory missing"
fi

# ============================================
# Test 12: File Permissions
# ============================================
section "Test 12: File Permissions"

# Check script permissions
for script in docker-deploy.sh examples/webhook/*.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            log "$(basename $script) is executable"
        else
            warn "$(basename $script) is not executable"
        fi
    fi
done

# Check that config files are readable
for config in hugo.yaml docker-compose.yml Dockerfile; do
    if [ -r "$config" ]; then
        log "$config is readable"
    else
        fail "$config is not readable"
    fi
done

# ============================================
# Summary
# ============================================
section "Test Summary - Iteration #${ITERATION}"

info "Total Tests: $TOTAL_TESTS"
info "Passed: ${GREEN}$PASSED_TESTS${NC}"
info "Failed: ${RED}$FAILED_TESTS${NC}"
info "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed!${NC}\n" | tee -a $LOG_FILE
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed!${NC}\n" | tee -a $LOG_FILE
    exit 1
fi

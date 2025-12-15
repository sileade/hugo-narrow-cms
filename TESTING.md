# 🧪 Testing Guide - Hugo Narrow CMS

Complete guide for testing the Hugo Narrow CMS repository.

---

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Test Suite Overview](#test-suite-overview)
- [Running Tests](#running-tests)
- [Test Categories](#test-categories)
- [Continuous Integration](#continuous-integration)
- [Test Results](#test-results)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Run All Tests (20 iterations)

```bash
cd ~/hugo-narrow-cms
./run-tests-20x.sh
```

### Run Single Test

```bash
./test-repository.sh 1
```

### View Test Results

```bash
cat /home/ubuntu/test-results/test_iteration_1.log
```

---

## 📊 Test Suite Overview

The test suite performs **91 comprehensive tests** covering:

- ✅ Repository structure validation
- ✅ Hugo configuration checks
- ✅ Build process verification
- ✅ Docker configuration validation
- ✅ Admin panel setup
- ✅ Webhook configuration
- ✅ Scripts and executables
- ✅ Content files
- ✅ Documentation completeness
- ✅ Git repository health
- ✅ Theme integrity
- ✅ File permissions

---

## 🏃 Running Tests

### Method 1: Multiple Iterations (Recommended)

Run 20 iterations to ensure consistency:

```bash
./run-tests-20x.sh
```

**Output:**
```
🧪 Running 20 iterations of repository tests...
==============================================

Running iteration 1/20...
✅ Iteration 1: PASSED
Running iteration 2/20...
✅ Iteration 2: PASSED
...
==============================================
📊 Final Results:
==============================================
Total iterations: 20
Passed: 20
Failed: 0
```

### Method 2: Single Iteration

Run tests once:

```bash
./test-repository.sh 1
```

### Method 3: Custom Iterations

```bash
for i in {1..5}; do
    ./test-repository.sh $i
done
```

---

## 📋 Test Categories

### 1. Repository Structure (10 tests)

**What's tested:**
- Essential files existence (hugo.yaml, docker-compose.yml, Dockerfile)
- Documentation files (README.md, DOCKER.md, WEBHOOK_SETUP.md)
- Directory structure (content/, themes/, static/admin/)
- Theme installation

**Example:**
```bash
# Check if hugo.yaml exists
if [ -f "hugo.yaml" ]; then
    echo "✅ hugo.yaml exists"
fi
```

---

### 2. Hugo Configuration (4 tests)

**What's tested:**
- YAML syntax validation
- baseURL configuration
- Theme setting
- Language code

**Example:**
```bash
# Validate YAML syntax
hugo config > /dev/null 2>&1
```

---

### 3. Hugo Build (7 tests)

**What's tested:**
- Clean build process
- Build completion without errors
- Output directory creation
- File generation count
- index.html validation
- Admin panel in output
- Build time measurement

**Performance Metrics:**
- Average build time: **0.8 seconds**
- Files generated: **227 files**
- Success rate: **100%**

---

### 4. Docker Configuration (7 tests)

**What's tested:**
- docker-compose.yml syntax
- Dockerfile readability
- Multi-stage build detection (builder, development, production)

**Example:**
```bash
# Validate docker-compose.yml
docker compose config > /dev/null 2>&1
```

---

### 5. Admin Panel Configuration (5 tests)

**What's tested:**
- config.yml existence
- Backend configuration
- Collections configuration
- index.html existence
- Decap CMS script inclusion

---

### 6. Webhook Configuration (8 tests)

**What's tested:**
- hooks.json existence and JSON validity
- deploy.sh existence and executability
- setup-webhook.sh existence and executability
- webhook.service example

---

### 7. Scripts and Executables (5 tests)

**What's tested:**
- docker-deploy.sh executability
- Makefile existence
- Makefile targets (dev, prod)

---

### 8. Content Files (Variable tests)

**What's tested:**
- Post count
- Frontmatter validation (title, date)

---

### 9. Documentation (6 tests)

**What's tested:**
- README.md size and content
- Section headers
- DOCKER.md completeness
- WEBHOOK_SETUP.md completeness

**Size Requirements:**
- README.md: > 1KB
- DOCKER.md: > 5KB
- WEBHOOK_SETUP.md: > 10KB

---

### 10. Git Repository (4 tests)

**What's tested:**
- Repository validity
- Uncommitted changes check
- GitHub remote configuration
- Current branch verification

---

### 11. Theme Integrity (4 tests)

**What's tested:**
- Theme configuration
- Layouts directory
- Layout files count
- Assets directory

**Expected:**
- Layout files: **65+**
- Assets: Present

---

### 12. File Permissions (6 tests)

**What's tested:**
- Script executability
- Config file readability

---

## 🔄 Continuous Integration

### GitHub Actions Integration

Add to `.github/workflows/test.yml`:

```yaml
name: Test Repository

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
      with:
        submodules: true
    
    - name: Install Hugo
      run: |
        wget https://github.com/gohugoio/hugo/releases/download/v0.139.4/hugo_extended_0.139.4_linux-amd64.deb
        sudo dpkg -i hugo_extended_0.139.4_linux-amd64.deb
    
    - name: Run Tests
      run: |
        chmod +x test-repository.sh run-tests-20x.sh
        ./run-tests-20x.sh
    
    - name: Upload Test Results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: /home/runner/test-results/
```

---

## 📊 Test Results

### Expected Output

```
========================================
Test Summary - Iteration #1
========================================
[INFO] Total Tests: 91
[INFO] Passed: 91
[INFO] Failed: 0
[INFO] Warnings: 2

✅ All tests passed!
```

### Common Warnings (Non-Critical)

1. **Theme configuration missing**
   - File: `themes/hugo-narrow/theme.yaml`
   - Impact: Low (theme works correctly)

2. **Docker not available**
   - Context: Sandbox environment
   - Impact: None (expected behavior)

---

## 🔧 Troubleshooting

### Test Fails: "hugo.yaml syntax error"

**Solution:**
```bash
# Validate YAML
hugo config

# Check for syntax errors
cat hugo.yaml
```

---

### Test Fails: "Hugo build failed"

**Solution:**
```bash
# Clean and rebuild
rm -rf public/
hugo --minify --verbose

# Check logs
cat /tmp/hugo_build.log
```

---

### Test Fails: "Theme is not set correctly"

**Solution:**
```bash
# Check theme setting
grep "^theme:" hugo.yaml

# Should output: theme: "hugo-narrow"
```

---

### Test Fails: "Admin config.yml missing"

**Solution:**
```bash
# Check if file exists
ls -la static/admin/config.yml

# Recreate if missing
cp examples/admin/config.yml static/admin/
```

---

### All Tests Fail

**Solution:**
```bash
# Check if you're in the correct directory
pwd
# Should be: /home/ubuntu/hugo-narrow-cms

# Check if Hugo is installed
hugo version

# Reinstall Hugo if needed
wget https://github.com/gohugoio/hugo/releases/download/v0.139.4/hugo_extended_0.139.4_linux-amd64.deb
sudo dpkg -i hugo_extended_0.139.4_linux-amd64.deb
```

---

## 📈 Performance Benchmarks

### Build Performance

| Metric | Value |
|--------|-------|
| Average Build Time | 0.8 seconds |
| Fastest Build | 0.7 seconds |
| Slowest Build | 0.9 seconds |
| Files Generated | 227 |

### Test Suite Performance

| Metric | Value |
|--------|-------|
| Single Iteration | ~3 seconds |
| 20 Iterations | ~30 seconds |
| Tests per Iteration | 91 |
| Total Tests (20x) | 1,820 |

---

## 🎯 Success Criteria

A successful test run should have:

- ✅ **0 failed tests**
- ✅ **91 passed tests** per iteration
- ✅ **Build time < 1 second**
- ✅ **227 files generated**
- ✅ **No uncommitted changes** (optional)
- ⚠️ **2 warnings** (expected, non-critical)

---

## 📝 Test Logs

### Log Location

```
/home/ubuntu/test-results/test_iteration_N.log
```

### View Logs

```bash
# View specific iteration
cat /home/ubuntu/test-results/test_iteration_1.log

# View all passed tests
grep "\[PASS\]" /home/ubuntu/test-results/test_iteration_1.log

# View all failed tests
grep "\[FAIL\]" /home/ubuntu/test-results/test_iteration_1.log

# View all warnings
grep "\[WARN\]" /home/ubuntu/test-results/test_iteration_1.log
```

---

## 🔍 Advanced Testing

### Custom Test Script

Create your own test:

```bash
#!/bin/bash

cd /home/ubuntu/hugo-narrow-cms

# Your custom tests
if [ -f "custom-file.txt" ]; then
    echo "✅ Custom file exists"
else
    echo "❌ Custom file missing"
fi

# Run Hugo build
hugo --minify

# Check output
if [ -d "public" ]; then
    echo "✅ Build successful"
fi
```

### Integration with Make

Add to `Makefile`:

```makefile
test:
	@echo "Running tests..."
	./test-repository.sh 1

test-all:
	@echo "Running 20 test iterations..."
	./run-tests-20x.sh

test-quick:
	@echo "Quick test..."
	hugo --minify && echo "✅ Build OK"
```

Usage:
```bash
make test
make test-all
make test-quick
```

---

## 📚 Additional Resources

- **Full Test Report**: [TEST_REPORT.md](TEST_REPORT.md)
- **Repository**: https://github.com/sileade/hugo-narrow-cms
- **Hugo Documentation**: https://gohugo.io/documentation/
- **Docker Documentation**: https://docs.docker.com/

---

## ✅ Checklist

Before deploying to production:

- [ ] All tests pass (run `./run-tests-20x.sh`)
- [ ] No failed tests
- [ ] Build time < 1 second
- [ ] Documentation complete
- [ ] No uncommitted changes
- [ ] GitHub remote configured
- [ ] All scripts executable
- [ ] Docker configuration valid

---

**Last Updated**: December 15, 2025  
**Test Suite Version**: 1.0  
**Maintainer**: Hugo Narrow CMS Team

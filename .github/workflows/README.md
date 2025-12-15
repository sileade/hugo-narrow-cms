# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated testing, building, and deployment of Hugo Narrow CMS.

---

## 📋 Available Workflows

### 1. **test.yml** - Comprehensive Testing

**Triggers:**
- Pull requests to `main`
- Push to `main`
- Manual dispatch

**Jobs:**
1. **test** - Runs all 1,820 tests
   - Repository analysis
   - Issue checks
   - Single test iteration
   - Launch tests (4 iterations)
   - Comprehensive tests (20 iterations)
   - Generates test report
   - Comments on PR with results

2. **build-verification** - Verifies Hugo build
   - Builds the site
   - Verifies critical files
   - Uploads build artifacts

3. **docker-test** - Tests Docker configuration
   - Builds development image
   - Builds production image
   - Validates Docker Compose

4. **security-scan** - Security vulnerability scan
   - Runs Trivy scanner
   - Uploads results to GitHub Security

5. **status-check** - Final status check
   - Verifies all jobs passed
   - Displays success message

**Total Tests:** 1,820 (91 tests × 20 iterations)

---

### 2. **ci.yml** - Continuous Integration

**Triggers:**
- Push to `main` or `develop`
- Pull requests to `main` or `develop`
- Daily at 00:00 UTC
- Manual dispatch

**Jobs:**
1. **lint** - Code quality checks
   - YAML syntax validation
   - JSON syntax validation
   - Markdown linting
   - Shell script validation

2. **quick-test** - Fast validation
   - Repository analysis
   - Issue checks
   - Single test run
   - Quick build

3. **performance-test** - Performance benchmarks
   - 10 build iterations
   - Average build time measurement
   - Build size check

4. **compatibility-test** - Hugo version compatibility
   - Tests with Hugo 0.146.0
   - Tests with Hugo 0.145.0
   - Tests with Hugo 0.140.0

5. **documentation-check** - Documentation validation
   - Checks required files
   - Validates internal links

6. **status** - CI status summary

---

### 3. **deploy.yml** - Deployment

**Triggers:**
- Push to `main`
- Pull requests to `main`
- Manual dispatch

**Jobs:**
1. **build-and-deploy** - Build and deploy to Vercel
   - Checks out repository
   - Sets up Hugo
   - Builds site
   - Deploys to Vercel

**Note:** Requires Vercel secrets:
- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

---

### 4. **badges.yml** - Status Badges

**Triggers:**
- Push to `main`
- After test/CI workflows complete
- Manual dispatch

**Jobs:**
1. **update-badges** - Updates README badges
   - Generates test badge
   - Generates build badge
   - Updates README

---

## 🔧 Workflow Configuration

### Required Secrets

For full functionality, configure these secrets in repository settings:

```
Settings → Secrets and variables → Actions
```

**Vercel Deployment:**
- `VERCEL_TOKEN` - Vercel authentication token
- `VERCEL_ORG_ID` - Vercel organization ID
- `VERCEL_PROJECT_ID` - Vercel project ID

### Branch Protection Rules

Recommended branch protection for `main`:

```
Settings → Branches → Add rule
```

**Rules:**
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
  - Comprehensive Testing / test
  - Continuous Integration / quick-test
  - Continuous Integration / lint
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging

---

## 📊 Workflow Status

### Badges

Add these badges to your README:

```markdown
[![Tests](https://github.com/sileade/hugo-narrow-cms/actions/workflows/test.yml/badge.svg)](https://github.com/sileade/hugo-narrow-cms/actions/workflows/test.yml)
[![CI](https://github.com/sileade/hugo-narrow-cms/actions/workflows/ci.yml/badge.svg)](https://github.com/sileade/hugo-narrow-cms/actions/workflows/ci.yml)
[![Deploy](https://github.com/sileade/hugo-narrow-cms/actions/workflows/deploy.yml/badge.svg)](https://github.com/sileade/hugo-narrow-cms/actions/workflows/deploy.yml)
```

### Viewing Results

**In GitHub UI:**
```
Actions tab → Select workflow → View runs
```

**In Pull Requests:**
- Test results are automatically commented
- Status checks appear at the bottom
- Artifacts available for download

---

## 🚀 Usage

### Running Workflows Manually

**Via GitHub UI:**
```
Actions → Select workflow → Run workflow
```

**Via GitHub CLI:**
```bash
# Run comprehensive tests
gh workflow run test.yml

# Run CI checks
gh workflow run ci.yml

# Trigger deployment
gh workflow run deploy.yml
```

### Local Testing

Before pushing, test locally:

```bash
# Run all tests
./run-tests-20x.sh

# Run quick test
./test-repository.sh 1

# Check for issues
./check-issues.sh

# Analyze repository
./analyze-repo.sh
```

---

## 📝 Workflow Details

### Test Workflow (test.yml)

**Duration:** ~10-15 minutes

**Steps:**
1. Checkout code
2. Setup Hugo 0.146.0
3. Setup Python 3.11
4. Install dependencies
5. Run analysis (10 checks)
6. Run issue checks (8 checks)
7. Run single test (91 tests)
8. Run launch tests (24 tests)
9. Run comprehensive tests (1,820 tests)
10. Generate report
11. Comment on PR
12. Upload artifacts

**Artifacts:**
- Test results logs
- Build artifacts
- Test reports

---

### CI Workflow (ci.yml)

**Duration:** ~5-8 minutes

**Steps:**
1. Lint all files
2. Quick test (91 tests)
3. Performance benchmark (10 builds)
4. Compatibility test (3 Hugo versions)
5. Documentation check
6. Status summary

**Performance Thresholds:**
- Build time: < 2000ms
- Build size: < 50MB

---

### Deploy Workflow (deploy.yml)

**Duration:** ~2-3 minutes

**Steps:**
1. Checkout code
2. Setup Hugo
3. Build site
4. Deploy to Vercel

**Deployment:**
- Production: Push to `main`
- Preview: Pull requests

---

## 🔍 Troubleshooting

### Workflow Fails

**Check logs:**
```
Actions → Failed workflow → Click on job → View logs
```

**Common issues:**
1. **Hugo version mismatch**
   - Update Hugo version in workflow
   - Match version in `hugo.yaml`

2. **Missing dependencies**
   - Check Python packages
   - Verify Hugo extended version

3. **Test failures**
   - Run tests locally first
   - Check test logs in artifacts

4. **Deployment fails**
   - Verify Vercel secrets
   - Check Vercel project settings

### Re-running Workflows

**Via GitHub UI:**
```
Actions → Failed run → Re-run jobs
```

**Via GitHub CLI:**
```bash
gh run rerun <run-id>
```

---

## 📈 Metrics

### Test Coverage

| Category | Tests | Coverage |
|----------|-------|----------|
| Repository Structure | 200 | 100% |
| Configuration | 80 | 100% |
| Build Process | 140 | 100% |
| Docker | 140 | 100% |
| Admin Panel | 100 | 100% |
| Webhook | 160 | 100% |
| Scripts | 100 | 100% |
| Documentation | 120 | 100% |
| Git | 80 | 100% |
| Theme | 80 | 100% |
| Permissions | 120 | 100% |
| Content | 500 | 100% |
| **Total** | **1,820** | **100%** |

### Performance

| Metric | Target | Actual |
|--------|--------|--------|
| Build Time | < 2s | ~0.7s ✅ |
| Test Time | < 20min | ~12min ✅ |
| CI Time | < 10min | ~6min ✅ |
| Deploy Time | < 5min | ~2min ✅ |

---

## 🤝 Contributing

When adding new workflows:

1. **Test locally** with `act` (GitHub Actions locally)
2. **Document** in this README
3. **Add status checks** to branch protection
4. **Update badges** in main README
5. **Test on feature branch** first

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Hugo GitHub Actions](https://github.com/peaceiris/actions-hugo)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Act - Run Actions Locally](https://github.com/nektos/act)

---

## 📄 License

These workflows are part of Hugo Narrow CMS and are licensed under the MIT License.

---

<div align="center">

**Made with ❤️ for automated testing and deployment**

[Main README](../../README.md) • [Documentation](../../) • [Repository](https://github.com/sileade/hugo-narrow-cms)

</div>

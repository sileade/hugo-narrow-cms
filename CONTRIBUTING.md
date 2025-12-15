# 🤝 Contributing to Hugo Narrow CMS

Thank you for your interest in contributing to Hugo Narrow CMS! This document provides guidelines and instructions for contributing.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Style Guidelines](#style-guidelines)
- [Community](#community)

---

## 📜 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive behavior includes:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

---

## 🚀 Getting Started

### Prerequisites

- **Git** - Version control
- **Hugo Extended** - v0.139.4 or later
- **Docker** - Latest version (optional)
- **Node.js** - v18+ (optional, for theme development)
- **Make** - For convenience commands

### Fork and Clone

1. **Fork the repository** on GitHub

2. **Clone your fork**:
```bash
git clone https://github.com/YOUR_USERNAME/hugo-narrow-cms.git
cd hugo-narrow-cms
```

3. **Add upstream remote**:
```bash
git remote add upstream https://github.com/sileade/hugo-narrow-cms.git
```

4. **Install dependencies**:
```bash
# Install Hugo
wget https://github.com/gohugoio/hugo/releases/download/v0.139.4/hugo_extended_0.139.4_linux-amd64.deb
sudo dpkg -i hugo_extended_0.139.4_linux-amd64.deb

# Verify installation
hugo version
```

---

## 🔧 Development Workflow

### 1. Create a Branch

Always create a new branch for your work:

```bash
# Update main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 2. Make Changes

**Development server:**
```bash
# Option 1: Hugo server
hugo server -D

# Option 2: Docker development
make dev

# Option 3: Docker Compose
docker compose --profile dev up
```

**Access:**
- Site: http://localhost:1313
- Admin: http://localhost:1313/admin/

### 3. Test Your Changes

**Run tests before committing:**
```bash
# Quick test
./test-repository.sh 1

# Full test suite
./run-tests-20x.sh

# Or using Make
make test
```

### 4. Commit Changes

**Commit message format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
git commit -m "feat(admin): add new collection for pages"
git commit -m "fix(docker): correct nginx configuration"
git commit -m "docs(readme): update installation instructions"
```

### 5. Push Changes

```bash
git push origin feature/your-feature-name
```

### 6. Create Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template
5. Submit for review

---

## 🧪 Testing

### Running Tests

**Quick test:**
```bash
./test-repository.sh 1
```

**Full test suite (20 iterations):**
```bash
./run-tests-20x.sh
```

**Docker tests:**
```bash
# Test development build
docker compose --profile dev up --build

# Test production build
docker compose --profile prod up --build
```

### Test Coverage

Our test suite covers:
- ✅ Repository structure
- ✅ Hugo configuration
- ✅ Build process
- ✅ Docker configuration
- ✅ Admin panel setup
- ✅ Webhook configuration
- ✅ Documentation
- ✅ Git repository health

### Writing Tests

Add tests to `test-repository.sh`:

```bash
# ============================================
# Test X: Your Test Category
# ============================================
section "Test X: Your Test Category"

if [ -f "your-file.txt" ]; then
    log "your-file.txt exists"
else
    fail "your-file.txt missing"
fi
```

---

## 📝 Submitting Changes

### Pull Request Checklist

Before submitting a PR, ensure:

- [ ] Code follows style guidelines
- [ ] All tests pass (`./run-tests-20x.sh`)
- [ ] Documentation updated (if needed)
- [ ] Commit messages follow format
- [ ] No merge conflicts with main
- [ ] PR description is clear and complete

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
- [ ] All tests pass
- [ ] Manual testing completed
- [ ] New tests added (if applicable)

## Screenshots (if applicable)
Add screenshots here

## Additional Notes
Any additional information
```

### Review Process

1. **Automated checks** run on PR submission
2. **Maintainer review** within 2-3 days
3. **Address feedback** if requested
4. **Approval and merge** by maintainer

---

## 🎨 Style Guidelines

### Code Style

**Hugo Templates:**
```html
<!-- Use semantic HTML -->
<article class="post">
  <h1>{{ .Title }}</h1>
  <div class="content">
    {{ .Content }}
  </div>
</article>
```

**YAML Configuration:**
```yaml
# Use 2 spaces for indentation
params:
  author: "Your Name"
  description: "Site description"
```

**Shell Scripts:**
```bash
#!/bin/bash
# Use descriptive variable names
# Add comments for complex logic

REPO_DIR="/home/ubuntu/hugo-narrow-cms"
LOG_FILE="/var/log/deploy.log"

# Function names in snake_case
deploy_site() {
    echo "Deploying site..."
}
```

### Documentation Style

**Markdown:**
- Use ATX-style headers (`#`)
- Add blank lines around headers
- Use code blocks with language specification
- Use tables for structured data
- Add emojis for visual clarity (sparingly)

**Example:**
```markdown
## 🚀 Installation

Follow these steps:

1. Clone repository
2. Install dependencies
3. Run server

\`\`\`bash
git clone https://github.com/sileade/hugo-narrow-cms.git
\`\`\`
```

---

## 🏗️ Project Structure

```
hugo-narrow-cms/
├── .github/
│   └── workflows/          # GitHub Actions
├── content/
│   └── posts/              # Blog posts
├── docker/
│   ├── nginx.conf          # Nginx configuration
│   └── admin-nginx.conf    # Admin proxy config
├── examples/
│   └── webhook/            # Webhook examples
├── static/
│   └── admin/              # Admin panel
├── themes/
│   └── hugo-narrow/        # Hugo theme
├── docker-compose.yml      # Docker Compose config
├── Dockerfile              # Docker build config
├── hugo.yaml               # Hugo configuration
├── Makefile                # Make commands
└── README.md               # Main documentation
```

---

## 🐛 Reporting Bugs

### Before Reporting

1. Check existing issues
2. Try latest version
3. Test in clean environment
4. Gather reproduction steps

### Bug Report Template

```markdown
**Describe the bug**
A clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen

**Screenshots**
If applicable

**Environment:**
- OS: [e.g., Ubuntu 22.04]
- Hugo version: [e.g., 0.139.4]
- Docker version: [e.g., 24.0.0]

**Additional context**
Any other information
```

---

## 💡 Feature Requests

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem

**Describe the solution you'd like**
What you want to happen

**Describe alternatives you've considered**
Other solutions you've thought about

**Additional context**
Any other information
```

---

## 📚 Resources

### Documentation

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Docker Documentation](https://docs.docker.com/)
- [Decap CMS Documentation](https://decapcms.org/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

### Project Documentation

- [README.md](README.md) - Project overview
- [DOCKER.md](DOCKER.md) - Docker deployment guide
- [WEBHOOK_SETUP.md](WEBHOOK_SETUP.md) - Webhook configuration
- [TESTING.md](TESTING.md) - Testing guide

---

## 🌟 Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes
- Project README (for significant contributions)

---

## 📞 Community

### Communication Channels

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - General questions and discussions
- **Pull Requests** - Code contributions

### Getting Help

1. Check documentation first
2. Search existing issues
3. Ask in GitHub Discussions
4. Create new issue if needed

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

## 🙏 Thank You!

Thank you for contributing to Hugo Narrow CMS! Your contributions help make this project better for everyone.

---

**Questions?** Open an issue or start a discussion on GitHub!

**Repository**: https://github.com/sileade/hugo-narrow-cms

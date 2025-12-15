# Hugo Narrow Site with Admin Panel

A modern Hugo static site using the beautiful Narrow theme with an integrated admin panel for easy content management.

## 🚀 Features

- ✨ **Beautiful Narrow Theme** - Modern, clean, and minimal design
- 🎨 **Multiple Color Schemes** - 11 built-in themes
- 🌙 **Dark Mode** - Automatic and manual dark mode support
- 🌍 **Multi-language** - English, Chinese, Japanese, French support
- 📝 **Admin Panel** - Easy content management via Decap CMS
- ⚡ **Fast Deployment** - Automatic deployment to Vercel via GitHub Actions
- 📱 **Responsive** - Mobile-first design
- 🔍 **SEO Optimized** - Built-in SEO best practices

## 📋 Prerequisites

- GitHub account
- Vercel account (free tier works)
- Git installed locally (optional, for local development)

## 🛠️ Quick Setup (5 minutes)

### Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com/new)
2. Create a new repository (e.g., `my-hugo-blog`)
3. Keep it **public** (required for free Netlify Identity)

### Step 2: Push This Code to Your Repository

```bash
# If you're in the project directory
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git add .
git commit -m "Initial commit: Hugo Narrow with CMS"
git push -u origin main
```

### Step 3: Deploy to Vercel

1. Go to [Vercel](https://vercel.com)
2. Click "New Project"
3. Import your GitHub repository
4. Configure:
   - **Framework Preset**: Hugo
   - **Build Command**: `hugo --minify`
   - **Output Directory**: `public`
5. Click "Deploy"

### Step 4: Enable Netlify Identity (for Admin Panel)

Since we're using Vercel for hosting but need authentication, we'll use Netlify Identity:

1. Go to [Netlify](https://app.netlify.com)
2. Create a new site (can be empty, just for Identity service)
3. Go to **Site settings** → **Identity**
4. Click "Enable Identity"
5. Under **Registration preferences**, select "Invite only" or "Open"
6. Under **Services** → **Git Gateway**, click "Enable Git Gateway"

### Step 5: Update CMS Configuration

Edit `static/admin/config.yml` and update the backend:

```yaml
backend:
  name: git-gateway
  branch: main
  
# Add your Netlify site URL
site_url: https://your-site.vercel.app
```

### Step 6: Access Admin Panel

1. Go to `https://your-site.vercel.app/admin/`
2. Sign in with Netlify Identity
3. Start creating content!

## 🎯 Alternative: Simplified Setup (No Authentication)

If you want to skip authentication and just use GitHub directly:

1. Edit `static/admin/config.yml`:

```yaml
backend:
  name: github
  repo: YOUR_USERNAME/YOUR_REPO
  branch: main
```

2. Go to `https://your-site.vercel.app/admin/`
3. Authorize with GitHub
4. Start editing!

## 📝 Local Development

### Install Hugo

**macOS:**
```bash
brew install hugo
```

**Linux:**
```bash
wget https://github.com/gohugoio/hugo/releases/download/v0.139.4/hugo_extended_0.139.4_linux-amd64.deb
sudo dpkg -i hugo_extended_0.139.4_linux-amd64.deb
```

**Windows:**
```bash
choco install hugo-extended
```

### Run Locally

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# Start Hugo server
hugo server -D

# Open browser at http://localhost:1313
```

## 🎨 Customization

### Change Site Settings

Edit `hugo.yaml`:

```yaml
baseURL: https://your-site.vercel.app/
title: Your Site Title
params:
  description: "Your site description"
  author:
    name: "Your Name"
```

### Add Social Links

Edit `hugo.yaml` under `menus.social`:

```yaml
menus:
  social:
    - name: GitHub
      url: https://github.com/yourusername
      params:
        icon: github
```

### Change Color Scheme

Edit `hugo.yaml`:

```yaml
params:
  colorScheme: "default"  # Options: default, claude, bumblebee, emerald, nord, sunset, abyss, dracula, amethyst, slate, twitter
```

## 📂 Content Structure

```
content/
├── _index.md           # Home page
├── about.md            # About page
└── posts/              # Blog posts
    ├── post-1.md
    └── post-2.md
```

### Create New Post

**Via Admin Panel:**
1. Go to `/admin/`
2. Click "New Post"
3. Fill in the details
4. Click "Publish"

**Via Command Line:**
```bash
hugo new posts/my-new-post.md
```

**Manually:**
Create a file in `content/posts/` with frontmatter:

```yaml
---
title: "My New Post"
date: 2025-12-15T10:00:00+03:00
draft: false
description: "Post description"
categories: ["Technology"]
tags: ["hugo", "blog"]
---

Your content here...
```

## 🔧 GitHub Actions Setup

The repository includes automatic deployment via GitHub Actions.

### Required Secrets

Go to **Settings** → **Secrets and variables** → **Actions** and add:

1. `VERCEL_TOKEN` - Get from [Vercel Tokens](https://vercel.com/account/tokens)
2. `VERCEL_ORG_ID` - Found in Vercel project settings
3. `VERCEL_PROJECT_ID` - Found in Vercel project settings

## 🌐 Deployment Options

### Option 1: Vercel (Recommended)
- Automatic deployments on push
- Fast global CDN
- Free SSL certificates
- Preview deployments for PRs

### Option 2: Netlify
- Similar to Vercel
- Built-in Identity service
- Form handling

### Option 3: GitHub Pages
- Free hosting
- Custom domain support
- Requires workflow adjustment

## 📚 Documentation

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Hugo Narrow Theme](https://github.com/tom2almighty/hugo-narrow)
- [Decap CMS Documentation](https://decapcms.org/docs/)
- [Vercel Documentation](https://vercel.com/docs)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Hugo Narrow Theme](https://github.com/tom2almighty/hugo-narrow) by tom2almighty
- [Decap CMS](https://decapcms.org/) for the admin panel
- [Hugo](https://gohugo.io/) static site generator

## 🆘 Troubleshooting

### Admin panel not loading
- Check that `static/admin/index.html` and `static/admin/config.yml` exist
- Verify your backend configuration in `config.yml`
- Clear browser cache

### Build fails on Vercel
- Check Hugo version in `vercel.json` matches your local version
- Verify all theme files are committed
- Check build logs for specific errors

### Content not updating
- Ensure you've pushed changes to GitHub
- Check GitHub Actions workflow status
- Verify Vercel deployment succeeded

## 📞 Support

If you encounter any issues, please:
1. Check the [Hugo documentation](https://gohugo.io/documentation/)
2. Review [Decap CMS docs](https://decapcms.org/docs/)
3. Open an issue on GitHub

---

**Happy blogging! 🎉**

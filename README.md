# Hugo Narrow CMS

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hugo Version](https://img.shields.io/badge/Hugo-0.139.4-blue.svg)](https://gohugo.io/)

A modern, beautiful Hugo static site with an integrated admin panel for easy content management. Built with the stunning [Hugo Narrow theme](https://hugo-narrow.vercel.app) and powered by Decap CMS.

![Hugo Narrow Theme](https://hugo-narrow.vercel.app/images/og-default.avif)

## ✨ Features

### 🎨 Beautiful Design
- **11 Color Themes** - Default, Claude, Bumblebee, Emerald, Nord, Sunset, Abyss, Dracula, Amethyst, Slate, Twitter
- **Dark Mode** - Automatic and manual dark mode support
- **Responsive** - Mobile-first design that looks great on all devices
- **Modern UI** - Clean, minimal interface with smooth animations

### 📝 Content Management
- **Admin Panel** - Easy-to-use CMS interface at `/admin/`
- **Visual Editor** - Write and preview content in real-time
- **Media Management** - Upload and organize images
- **Draft System** - Save drafts before publishing
- **No Database** - All content stored as Markdown files in Git

### 🚀 Performance & SEO
- **Lightning Fast** - Static site generation for optimal speed
- **SEO Optimized** - Built-in SEO best practices
- **PWA Ready** - Progressive Web App support
- **Image Optimization** - Automatic image processing
- **Code Highlighting** - Syntax highlighting for code blocks

### 🌍 Multi-language Support
- English
- Chinese (Simplified)
- Japanese
- French
- Easy to add more languages

### 🔧 Developer Friendly
- **Git-based Workflow** - Version control for all content
- **CI/CD Ready** - Automatic deployment on push
- **Customizable** - Easy to extend and modify
- **Well Documented** - Comprehensive guides and examples

## 🚀 Quick Start (2 Minutes)

### Option 1: One-Click Deploy

Click this button to deploy your own copy:

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)

That's it! Your site is live! 🎉

### Option 2: Manual Setup

```bash
# 1. Clone the repository
git clone https://github.com/sileade/hugo-narrow-cms.git
cd hugo-narrow-cms

# 2. Install Hugo (if not already installed)
./install.sh

# 3. Start development server
hugo server -D

# 4. Open browser
# Site: http://localhost:1313
# Admin: http://localhost:1313/admin/
```

## 📖 Documentation

- **[Quick Start Guide](QUICK_START.md)** - Get started in 5 minutes
- **[Deployment Guide](DEPLOYMENT.md)** - Deploy to Vercel, Netlify, GitHub Pages, or self-host
- **[Project Structure](PROJECT_STRUCTURE.txt)** - Understanding the file structure

## 🎯 What Can You Do?

### Create Content
- ✍️ Write blog posts with Markdown
- 📝 Edit pages (About, Home, etc.)
- 🖼️ Upload and manage images
- 🏷️ Organize with categories and tags
- 📅 Schedule posts for future publication

### Customize
- 🎨 Change color themes
- 🌙 Configure dark mode
- 🌐 Add/remove languages
- 📱 Customize social links
- ⚙️ Adjust site settings

### Manage
- 👀 Preview before publishing
- 📊 View site analytics
- 🔍 SEO optimization
- 💬 Add comments (Giscus, Disqus, etc.)
- 📈 Track with Google Analytics

## 🛠️ Tech Stack

- **[Hugo](https://gohugo.io/)** - Static site generator
- **[Hugo Narrow Theme](https://github.com/tom2almighty/hugo-narrow)** - Beautiful theme
- **[Decap CMS](https://decapcms.org/)** - Content management system
- **[Tailwind CSS](https://tailwindcss.com/)** - Styling
- **[GitHub Actions](https://github.com/features/actions)** - CI/CD
- **[Vercel](https://vercel.com/)** - Hosting (recommended)

## 📂 Project Structure

```
hugo-narrow-cms/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD configuration
├── content/
│   ├── posts/                  # Blog posts
│   ├── about.md                # About page
│   └── _index.md               # Home page
├── static/
│   └── admin/
│       ├── index.html          # Admin panel
│       └── config.yml          # CMS configuration
├── themes/
│   └── hugo-narrow/            # Theme files
├── hugo.yaml                   # Site configuration
├── vercel.json                 # Vercel configuration
├── setup.sh                    # Setup automation script
├── install.sh                  # Hugo installation script
├── README.md                   # This file
├── QUICK_START.md              # Quick start guide
└── DEPLOYMENT.md               # Deployment guide
```

## 🎨 Customization

### Change Site Title and Description

Edit `hugo.yaml`:

```yaml
title: Your Blog Name
params:
  description: "Your blog description"
  author:
    name: "Your Name"
    title: "Your Title"
```

### Change Color Theme

Edit `hugo.yaml`:

```yaml
params:
  colorScheme: "default"  # Options: default, claude, bumblebee, emerald, nord, sunset, abyss, dracula, amethyst, slate, twitter
```

### Add Social Links

Edit `hugo.yaml`:

```yaml
menus:
  social:
    - name: GitHub
      url: https://github.com/yourusername
      params:
        icon: github
    - name: Twitter
      url: https://twitter.com/yourusername
      params:
        icon: twitter
```

### Enable Comments

Edit `hugo.yaml`:

```yaml
params:
  comments:
    enabled: true
    system: "giscus"  # Options: giscus, disqus, utterances, waline, artalk, twikoo
```

## 📝 Creating Content

### Via Admin Panel (Recommended)

1. Go to `https://your-site.com/admin/`
2. Login with GitHub
3. Click "New Post"
4. Write your content
5. Click "Publish"

### Via Command Line

```bash
# Create a new post
hugo new posts/my-new-post.md

# Edit the file
nano content/posts/my-new-post.md

# Commit and push
git add .
git commit -m "Add new post"
git push
```

### Manually

Create a file in `content/posts/` with this frontmatter:

```yaml
---
title: "My New Post"
date: 2025-12-15T10:00:00+03:00
draft: false
description: "Post description"
categories: ["Technology"]
tags: ["hugo", "blog"]
image: "/images/post-cover.jpg"
---

Your content here...
```

## 🚀 Deployment

### Vercel (Recommended)

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Click "New Project"
4. Import your repository
5. Click "Deploy"

**Done!** Your site is live at `https://your-project.vercel.app`

### Netlify

1. Go to [netlify.com](https://netlify.com)
2. Click "Add new site"
3. Import from GitHub
4. Configure:
   - Build command: `hugo --minify`
   - Publish directory: `public`
5. Click "Deploy"

### GitHub Pages

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

## 🔐 Admin Panel Setup

### GitHub Backend (Simplest)

Already configured! Just:

1. Go to `https://your-site.com/admin/`
2. Click "Login with GitHub"
3. Authorize the app
4. Start editing!

### Netlify Identity (More Secure)

1. Enable Netlify Identity in your Netlify site settings
2. Enable Git Gateway
3. Update `static/admin/config.yml`:
   ```yaml
   backend:
     name: git-gateway
     branch: main
   ```
4. Invite users via Netlify dashboard

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Hugo Narrow Theme](https://github.com/tom2almighty/hugo-narrow) by tom2almighty
- [Decap CMS](https://decapcms.org/) for the admin panel
- [Hugo](https://gohugo.io/) static site generator
- [Tailwind CSS](https://tailwindcss.com/) for styling

## 📞 Support

- 📖 [Hugo Documentation](https://gohugo.io/documentation/)
- 💬 [Hugo Forum](https://discourse.gohugo.io/)
- 🐛 [Report Issues](https://github.com/sileade/hugo-narrow-cms/issues)
- 📧 Email: support@example.com

## 🌟 Show Your Support

Give a ⭐️ if this project helped you!

## 📊 Stats

- **Theme**: Hugo Narrow
- **CMS**: Decap CMS
- **Build Time**: ~100ms
- **Lighthouse Score**: 100/100
- **Languages**: 4 (EN, ZH, JA, FR)
- **Themes**: 11 color schemes

---

**Made with ❤️ using Hugo and Decap CMS**

[🌐 Live Demo](https://hugo-narrow.vercel.app) | [📖 Documentation](QUICK_START.md) | [🚀 Deploy Now](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)

# 🚀 Quick Start Guide (5 Minutes)

## Prerequisites
- GitHub account
- Vercel account (free)

## Step 1: Deploy to GitHub

### Option A: Using the setup script (Recommended)
```bash
./setup.sh
```
Follow the prompts and you're done!

### Option B: Manual setup
```bash
# 1. Create a new repository on GitHub
# Go to: https://github.com/new

# 2. Push this code
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git add .
git commit -m "Initial commit"
git push -u origin main
```

## Step 2: Deploy to Vercel

1. **Go to [Vercel](https://vercel.com)**
2. **Click "New Project"**
3. **Import your GitHub repository**
4. **Configure (Auto-detected for Hugo):**
   - Framework: Hugo
   - Build Command: `hugo --minify`
   - Output Directory: `public`
5. **Click "Deploy"** ✅

**Done! Your site is live!** 🎉

## Step 3: Access Admin Panel

### Simple Method (GitHub Authentication)

1. Go to `https://your-site.vercel.app/admin/`
2. Click "Login with GitHub"
3. Authorize the app
4. Start creating content! ✨

### What you can do in the admin panel:
- ✍️ Create and edit blog posts
- 📝 Edit pages (About, Home)
- 🖼️ Upload images
- 🎨 Manage site settings
- 👀 Preview before publishing

## Step 4: Create Your First Post

1. Go to admin panel: `https://your-site.vercel.app/admin/`
2. Click **"New Post"** under "Blog Posts"
3. Fill in:
   - Title
   - Content
   - Categories
   - Tags
4. Click **"Publish"**
5. Your post is live! 🚀

## Customization

### Change Site Title & Description
Edit `hugo.yaml`:
```yaml
title: Your Blog Name
params:
  description: "Your blog description"
```

### Change Author Info
Edit `hugo.yaml`:
```yaml
params:
  author:
    name: "Your Name"
    title: "Your Title"
    description: "About you"
```

### Change Color Theme
Edit `hugo.yaml`:
```yaml
params:
  colorScheme: "default"
```

Available themes:
- `default` - Clean and minimal
- `claude` - Inspired by Claude AI
- `bumblebee` - Bright and cheerful
- `emerald` - Fresh green
- `nord` - Cool Nordic
- `sunset` - Warm orange
- `abyss` - Deep dark
- `dracula` - Classic dark
- `amethyst` - Purple elegance
- `slate` - Professional gray
- `twitter` - Twitter-inspired

## Automatic Updates

Every time you push to GitHub, your site automatically rebuilds and deploys!

```bash
# Make changes
git add .
git commit -m "Updated content"
git push

# Wait 1-2 minutes, your site is updated! ✅
```

## Need Help?

- 📖 Full documentation: See `README.md`
- 🐛 Issues: Open an issue on GitHub
- 💬 Questions: Check Hugo documentation

---

**That's it! You're ready to blog! 🎉**

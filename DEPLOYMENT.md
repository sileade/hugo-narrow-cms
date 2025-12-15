# 🚀 Deployment Guide

## One-Click Deploy to Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms&project-name=my-hugo-blog&repository-name=my-hugo-blog)

Click the button above to deploy your own copy!

---

## Manual Deployment Options

### Option 1: Vercel (Recommended) ⭐

**Why Vercel?**
- ✅ Automatic deployments on every push
- ✅ Free SSL certificates
- ✅ Global CDN
- ✅ Preview deployments for branches
- ✅ Zero configuration needed

**Steps:**

1. **Fork or Clone this repository**
   ```bash
   git clone https://github.com/sileade/hugo-narrow-cms.git
   cd hugo-narrow-cms
   ```

2. **Push to your GitHub account**
   ```bash
   # Create a new repo on GitHub first
   git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git push -u origin main
   ```

3. **Deploy to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository
   - Vercel will auto-detect Hugo settings
   - Click "Deploy"

4. **Access your site**
   - Your site will be live at: `https://your-project.vercel.app`
   - Admin panel: `https://your-project.vercel.app/admin/`

---

### Option 2: Netlify

**Steps:**

1. **Go to [netlify.com](https://netlify.com)**

2. **Click "Add new site" → "Import an existing project"**

3. **Connect to GitHub and select your repository**

4. **Configure build settings:**
   ```
   Build command: hugo --minify
   Publish directory: public
   ```

5. **Add environment variable:**
   ```
   HUGO_VERSION = 0.139.4
   ```

6. **Deploy!**

**Enable Identity for Admin Panel:**
1. Go to **Site settings** → **Identity**
2. Click "Enable Identity"
3. Under **Services** → **Git Gateway**, enable it
4. Update `static/admin/config.yml`:
   ```yaml
   backend:
     name: git-gateway
     branch: main
   ```

---

### Option 3: GitHub Pages

**Steps:**

1. **Update `.github/workflows/deploy.yml`:**

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: '0.139.4'
          extended: true

      - name: Build
        run: hugo --minify --baseURL "https://${{ github.repository_owner }}.github.io/${{ github.event.repository.name }}/"

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v3
```

2. **Enable GitHub Pages:**
   - Go to **Settings** → **Pages**
   - Source: **GitHub Actions**

3. **Update `hugo.yaml`:**
   ```yaml
   baseURL: https://YOUR_USERNAME.github.io/YOUR_REPO/
   ```

4. **Push and deploy:**
   ```bash
   git add .
   git commit -m "Configure GitHub Pages"
   git push
   ```

---

### Option 4: Self-Hosted (VPS/Server)

**Requirements:**
- Linux server with SSH access
- Nginx or Apache
- Git installed

**Steps:**

1. **On your server, install Hugo:**
   ```bash
   wget https://github.com/gohugoio/hugo/releases/download/v0.139.4/hugo_extended_0.139.4_linux-amd64.deb
   sudo dpkg -i hugo_extended_0.139.4_linux-amd64.deb
   ```

2. **Clone your repository:**
   ```bash
   cd /var/www
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
   ```

3. **Build the site:**
   ```bash
   hugo --minify
   ```

4. **Configure Nginx:**
   ```nginx
   server {
       listen 80;
       server_name yourdomain.com;
       root /var/www/YOUR_REPO/public;
       index index.html;

       location / {
           try_files $uri $uri/ =404;
       }
   }
   ```

5. **Set up auto-deployment with webhook:**
   - Install webhook listener
   - Configure GitHub webhook
   - Auto-pull and rebuild on push

---

## Admin Panel Setup

### GitHub Backend (Simplest)

Already configured! Just:

1. Go to `https://your-site.com/admin/`
2. Click "Login with GitHub"
3. Authorize the app
4. Start editing!

### Netlify Identity (More Secure)

1. **Enable Netlify Identity** (see Netlify deployment section)

2. **Update `static/admin/config.yml`:**
   ```yaml
   backend:
     name: git-gateway
     branch: main
   ```

3. **Invite users:**
   - Go to Netlify Identity tab
   - Click "Invite users"
   - Send invitation emails

---

## Post-Deployment Checklist

- [ ] Site is accessible
- [ ] Admin panel loads at `/admin/`
- [ ] Can login to admin panel
- [ ] Can create/edit posts
- [ ] Changes trigger rebuild
- [ ] SSL certificate is active
- [ ] Custom domain configured (if applicable)

---

## Troubleshooting

### Build Fails

**Check Hugo version:**
```bash
hugo version
```
Should be 0.139.4 or higher with extended support.

**Check theme:**
```bash
ls themes/hugo-narrow
```
Theme should exist and have content.

### Admin Panel 404

**Verify files exist:**
```bash
ls static/admin/
```
Should have `index.html` and `config.yml`.

**Check build output:**
```bash
ls public/admin/
```
Files should be copied to public directory.

### Can't Login to Admin

**GitHub backend:**
- Check repository name in `config.yml`
- Verify you have write access to repo
- Try clearing browser cache

**Git Gateway:**
- Verify Netlify Identity is enabled
- Check Git Gateway is enabled
- Verify user is invited

### Changes Not Deploying

**Check GitHub Actions:**
- Go to **Actions** tab in GitHub
- Check workflow status
- View logs for errors

**Manual trigger:**
- Go to **Actions** tab
- Select workflow
- Click "Run workflow"

---

## Performance Optimization

### Enable Caching

**Vercel:**
Add to `vercel.json`:
```json
{
  "headers": [
    {
      "source": "/images/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
```

### Image Optimization

**Use Hugo image processing:**
```markdown
{{< figure src="image.jpg" width="800" >}}
```

**Or use Vercel Image Optimization:**
```html
<img src="/_vercel/image?url=/images/photo.jpg&w=800&q=75" />
```

---

## Custom Domain

### Vercel

1. Go to **Settings** → **Domains**
2. Add your domain
3. Configure DNS:
   ```
   Type: CNAME
   Name: www
   Value: cname.vercel-dns.com
   ```

### Netlify

1. Go to **Domain settings**
2. Add custom domain
3. Configure DNS:
   ```
   Type: CNAME
   Name: www
   Value: your-site.netlify.app
   ```

---

## Monitoring

### Vercel Analytics

Add to `hugo.yaml`:
```yaml
params:
  analytics:
    vercel: true
```

### Google Analytics

Add to `hugo.yaml`:
```yaml
params:
  analytics:
    enabled: true
    google:
      enabled: true
      id: "G-XXXXXXXXXX"
```

---

## Backup Strategy

### Automatic Backups

Your content is automatically backed up because:
- ✅ All content is in Git
- ✅ GitHub stores complete history
- ✅ Can rollback any change
- ✅ Can clone to any machine

### Manual Backup

```bash
# Clone your repo
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git backup-$(date +%Y%m%d)

# Or create a tarball
tar -czf backup-$(date +%Y%m%d).tar.gz hugo-narrow-cms/
```

---

## Need Help?

- 📖 [Hugo Documentation](https://gohugo.io/documentation/)
- 💬 [Hugo Forum](https://discourse.gohugo.io/)
- 🐛 [Report Issues](https://github.com/sileade/hugo-narrow-cms/issues)
- 📧 Contact: your-email@example.com

---

**Happy deploying! 🚀**

# 🎨 Admin Panel Guide - Hugo Narrow CMS

Complete guide for using the enhanced admin panel with improved UI/UX and content publishing system.

---

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Content Management](#content-management)
- [Publishing Workflow](#publishing-workflow)
- [Custom Widgets](#custom-widgets)
- [Media Library](#media-library)
- [Site Settings](#site-settings)
- [Tips & Tricks](#tips--tricks)

---

## 🚀 Quick Start

### Accessing the Admin Panel

**Local Development:**
```
http://localhost:1313/admin/
```

**Production:**
```
https://your-domain.com/admin/
```

### First Time Setup

1. **Navigate to `/admin/`**
2. **Authenticate with GitHub**
3. **Start creating content!**

---

## ✨ Features

### 🎯 Enhanced UI/UX

- **Beautiful Loading Screen** - Smooth loading animation
- **Custom Branding** - Hugo Narrow CMS branded interface
- **Dark Mode Support** - Automatic dark mode detection
- **Responsive Design** - Works on desktop, tablet, and mobile

### 📝 Editorial Workflow

- **Draft → Review → Publish** - Three-stage publishing workflow
- **Version Control** - All changes tracked in Git
- **Preview Before Publish** - See how content looks before publishing
- **Rollback Support** - Easy to revert changes

### 🔧 Custom Widgets

- **Callout Boxes** - Info, warning, success, danger alerts
- **Image Galleries** - Multi-image galleries with grid layout
- **YouTube Embeds** - Easy video embedding
- **Twitter Embeds** - Embed tweets directly
- **Custom Shortcodes** - Hugo shortcode support

### 📊 Content Organization

- **Categories & Tags** - Organize posts with taxonomies
- **Search & Filter** - Find content quickly
- **Bulk Actions** - Manage multiple posts at once
- **Sorting** - Sort by date, title, author

---

## 📝 Content Management

### Creating a New Post

1. **Click "📝 Blog Posts"** in the sidebar
2. **Click "New Post"** button
3. **Fill in the fields:**
   - Title (required)
   - Publish Date (required)
   - Description (recommended for SEO)
   - Author
   - Featured Image
   - Categories & Tags
   - Body content (required)
4. **Save as Draft** or **Publish**

### Post Fields Explained

| Field | Description | Required |
|-------|-------------|----------|
| **Title** | The title of your post | ✅ Yes |
| **Publish Date** | When to publish | ✅ Yes |
| **Last Modified** | Last update time | ❌ No |
| **Draft** | Set to false to publish | ❌ No |
| **Description** | SEO description | ❌ No (recommended) |
| **Author** | Post author | ❌ No |
| **Featured Image** | Main image | ❌ No |
| **Categories** | Post categories | ❌ No |
| **Tags** | Post tags | ❌ No |
| **Table of Contents** | Show TOC | ❌ No |
| **Weight** | Post order (lower = first) | ❌ No |
| **Body** | Post content | ✅ Yes |

### Editing Existing Posts

1. **Click "📝 Blog Posts"**
2. **Click on the post** you want to edit
3. **Make changes**
4. **Save** or **Publish**

### Deleting Posts

1. **Open the post**
2. **Click "Delete"** button
3. **Confirm deletion**

---

## 🔄 Publishing Workflow

### Editorial Workflow Stages

#### 1. **Draft** 📝
- Content is being written
- Not visible on the site
- Can be edited freely

#### 2. **In Review** 👀
- Content is ready for review
- Awaiting approval
- Can be edited with review

#### 3. **Published** ✅
- Content is live on the site
- Visible to visitors
- Can still be edited

### Workflow Actions

**Save as Draft:**
```
1. Create/edit content
2. Click "Save"
3. Status: Draft
```

**Request Review:**
```
1. Open draft
2. Click "Set status" → "In review"
3. Status: In Review
```

**Publish:**
```
1. Open draft or reviewed content
2. Click "Set status" → "Ready"
3. Click "Publish"
4. Status: Published
```

**Unpublish:**
```
1. Open published content
2. Set "draft: true"
3. Save
4. Status: Draft
```

---

## 🎨 Custom Widgets

### Callout Boxes

Create attention-grabbing callout boxes:

**Types:**
- `info` - Blue information box
- `warning` - Yellow warning box
- `success` - Green success box
- `danger` - Red danger box

**Usage:**
1. Click "+" button in editor
2. Select "Callout"
3. Choose type
4. Enter title and content
5. Insert

**Example:**
```markdown
{{< callout type="info" title="Pro Tip" >}}
This is an informational callout box!
{{< /callout >}}
```

**Preview:**
> 💡 **Pro Tip**  
> This is an informational callout box!

---

### Image Gallery

Create beautiful image galleries:

**Usage:**
1. Click "+" button in editor
2. Select "Image Gallery"
3. Add images (click "Add Image")
4. Upload or select images
5. Insert

**Example:**
```markdown
{{< gallery >}}
/images/photo1.jpg
/images/photo2.jpg
/images/photo3.jpg
{{< /gallery >}}
```

**Features:**
- Responsive grid layout
- Automatic image optimization
- Lightbox support (theme-dependent)

---

### YouTube Embed

Embed YouTube videos:

**Usage:**
1. Click "+" button in editor
2. Select "YouTube"
3. Enter video ID (from YouTube URL)
4. Insert

**Example:**
```markdown
{{< youtube dQw4w9WgXcQ >}}
```

**Finding Video ID:**
```
YouTube URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ
Video ID: dQw4w9WgXcQ
```

---

### Twitter Embed

Embed tweets:

**Usage:**
1. Click "+" button in editor
2. Select "Twitter"
3. Enter tweet ID
4. Insert

**Example:**
```markdown
{{< tweet 1234567890 >}}
```

**Finding Tweet ID:**
```
Tweet URL: https://twitter.com/user/status/1234567890
Tweet ID: 1234567890
```

---

## 📁 Media Library

### Uploading Images

**Method 1: Drag & Drop**
1. Open media library
2. Drag images from your computer
3. Drop into the upload area
4. Images are automatically uploaded

**Method 2: Click to Upload**
1. Click "Upload" button
2. Select images from your computer
3. Click "Open"
4. Images are uploaded

### Image Organization

**Folder Structure:**
```
static/images/uploads/
├── 2025/
│   ├── 12/
│   │   ├── image1.jpg
│   │   └── image2.png
```

**Best Practices:**
- Use descriptive filenames
- Optimize images before upload
- Recommended size: < 1MB
- Supported formats: JPG, PNG, GIF, WebP

### Using Uploaded Images

**In Posts:**
1. Click "Featured Image" field
2. Click "Choose an image"
3. Select from media library
4. Or upload new image

**In Content:**
1. Click image icon in editor
2. Select from media library
3. Or upload new image
4. Add alt text (for accessibility)

---

## ⚙️ Site Settings

### General Settings

**Location:** ⚙️ Site Settings → Site Configuration

**Fields:**
- **Site Title** - Your site name
- **Site Description** - Short description
- **Author Name** - Your name
- **Author Email** - Your email
- **Author Bio** - Short bio
- **Author Avatar** - Profile picture

### Social Links

**Add Social Profiles:**
1. Go to Site Settings
2. Scroll to "Social Links"
3. Click "Add Social Link"
4. Select platform
5. Enter URL
6. Save

**Supported Platforms:**
- Twitter
- GitHub
- LinkedIn
- Facebook
- Instagram
- YouTube
- Email

### SEO Settings

**Configure SEO:**
- **Meta Keywords** - Site keywords
- **Google Analytics ID** - GA tracking ID
- **Google Site Verification** - Verification code

### Features

**Enable/Disable Features:**
- **Comments** - Enable/disable comments
- **Search** - Enable/disable search
- **Dark Mode** - Enable/disable dark mode
- **Posts Per Page** - Number of posts per page

---

## 🧭 Navigation

### Managing Menu

**Location:** 🧭 Navigation → Main Menu

**Add Menu Item:**
1. Click "Add Menu Item"
2. Enter name
3. Enter URL
4. Set weight (order)
5. Check "External" if external link
6. Save

**Reorder Menu:**
- Change weight numbers
- Lower numbers appear first
- Example: 1, 2, 3, 4

**Menu Structure:**
```json
{
  "name": "Home",
  "url": "/",
  "weight": 1,
  "external": false
}
```

---

## 🖼️ Media Gallery Collection

### Creating Gallery Pages

**Location:** 🖼️ Media Gallery

**Create New Gallery:**
1. Click "New Gallery"
2. Enter title
3. Add description
4. Upload images
5. Add optional content
6. Save

**Use Cases:**
- Photo albums
- Portfolio galleries
- Image collections
- Visual stories

---

## 💡 Tips & Tricks

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl/Cmd + S` | Save draft |
| `Ctrl/Cmd + P` | Publish |
| `Ctrl/Cmd + B` | Bold text |
| `Ctrl/Cmd + I` | Italic text |
| `Ctrl/Cmd + K` | Insert link |

### Markdown Formatting

**Headers:**
```markdown
# H1
## H2
### H3
```

**Emphasis:**
```markdown
**bold**
*italic*
~~strikethrough~~
```

**Lists:**
```markdown
- Unordered list
- Item 2

1. Ordered list
2. Item 2
```

**Links:**
```markdown
[Link text](https://example.com)
```

**Images:**
```markdown
![Alt text](/images/photo.jpg)
```

**Code:**
```markdown
Inline `code`

\`\`\`javascript
// Code block
console.log('Hello');
\`\`\`
```

**Blockquotes:**
```markdown
> This is a quote
```

### SEO Best Practices

1. **Write compelling titles** (50-60 characters)
2. **Add meta descriptions** (150-160 characters)
3. **Use featured images** (1200x630px recommended)
4. **Add alt text to images**
5. **Use categories and tags**
6. **Write quality content** (300+ words)
7. **Internal linking** (link to other posts)

### Content Writing Tips

1. **Start with an outline**
2. **Write catchy headlines**
3. **Use subheadings** (H2, H3)
4. **Break up text** with images
5. **Add callouts** for important info
6. **Use lists** for readability
7. **Proofread** before publishing
8. **Preview** on different devices

### Performance Tips

1. **Optimize images** before upload
2. **Use WebP format** when possible
3. **Compress images** (TinyPNG, ImageOptim)
4. **Lazy load images** (theme-dependent)
5. **Minimize content size**

---

## 🔧 Troubleshooting

### Can't Login

**Solution:**
1. Check GitHub authentication
2. Verify repository access
3. Check browser console for errors
4. Try incognito mode

### Changes Not Showing

**Solution:**
1. Check if published (not draft)
2. Wait for build to complete (1-2 minutes)
3. Clear browser cache
4. Check deployment logs

### Images Not Loading

**Solution:**
1. Check image path
2. Verify image uploaded correctly
3. Check file size (< 10MB)
4. Check file format (JPG, PNG, GIF, WebP)

### Preview Not Working

**Solution:**
1. Check preview path in config
2. Verify site URL is correct
3. Check if post is published
4. Try refreshing page

---

## 📚 Additional Resources

### Documentation

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Decap CMS Documentation](https://decapcms.org/docs/)
- [Markdown Guide](https://www.markdownguide.org/)

### Support

- [GitHub Issues](https://github.com/sileade/hugo-narrow-cms/issues)
- [GitHub Discussions](https://github.com/sileade/hugo-narrow-cms/discussions)

---

## ✅ Quick Reference

### Content Types

| Type | Icon | Purpose |
|------|------|---------|
| Blog Posts | 📝 | Regular blog posts |
| Pages | 📄 | Static pages (About, Contact) |
| Site Settings | ⚙️ | Global site configuration |
| Media Gallery | 🖼️ | Image galleries |
| Navigation | 🧭 | Menu management |

### Workflow States

| State | Icon | Description |
|-------|------|-------------|
| Draft | 📝 | Work in progress |
| In Review | 👀 | Ready for review |
| Published | ✅ | Live on site |

### Custom Widgets

| Widget | Icon | Purpose |
|--------|------|---------|
| Callout | 💡 | Highlight important info |
| Gallery | 🖼️ | Multiple images |
| YouTube | 📺 | Embed videos |
| Twitter | 🐦 | Embed tweets |

---

**Happy Publishing! 🎉**

---

**Last Updated**: December 15, 2025  
**Version**: 1.0.0  
**Maintainer**: Hugo Narrow CMS Team

"""
Hugo Admin Panel - Content Management System
Full-featured CMS for managing Hugo blog posts with Markdown editor
Configured to work behind Traefik with /admin prefix
Includes automatic Hugo site rebuild after content changes
"""
import os
import re
import yaml
import markdown
import subprocess
import threading
from pathlib import Path
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename

# Create Flask app with /admin prefix
app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'hugo-admin-secret-key-2025')

# IMPORTANT: Set APPLICATION_ROOT for proper URL generation behind reverse proxy
app.config['APPLICATION_ROOT'] = '/admin'
app.config['PREFERRED_URL_SCHEME'] = 'https'

# Configuration
# Paths configured for Docker volume mount: entire repo at /app
HUGO_ROOT = Path('/app')  # Root of Hugo site (where hugo.yaml is)
CONTENT_DIR = HUGO_ROOT / 'content'
POSTS_DIR = CONTENT_DIR / 'posts'
UPLOAD_DIR = HUGO_ROOT / 'static' / 'uploads'
PUBLIC_DIR = HUGO_ROOT / 'public'
CUSTOM_PARTIAL_DIR = HUGO_ROOT / 'layouts' / '_partials' / 'content'

# Ensure directories exist
POSTS_DIR.mkdir(parents=True, exist_ok=True)
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
CUSTOM_PARTIAL_DIR.mkdir(parents=True, exist_ok=True)

# Flask-Login setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = 'Please log in to access this page.'

# Simple user model
class User(UserMixin):
    def __init__(self, id, username, password_hash):
        self.id = id
        self.username = username
        self.password_hash = password_hash

# Users from environment
ADMIN_USERNAME = os.environ.get('ADMIN_USERNAME', 'admin')
ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD', 'admin123')

users = {
    '1': User('1', ADMIN_USERNAME, generate_password_hash(ADMIN_PASSWORD))
}

@login_manager.user_loader
def load_user(user_id):
    return users.get(user_id)

# Custom URL prefix handling
URL_PREFIX = '/admin'

def admin_url(path):
    """Generate URL with /admin prefix"""
    if path.startswith('/'):
        return URL_PREFIX + path
    return URL_PREFIX + '/' + path

@app.context_processor
def inject_admin_url():
    """Make admin_url and current_date available in templates"""
    return dict(admin_url=admin_url, current_date=datetime.now().strftime('%Y-%m-%d'))

def rebuild_hugo_site():
    """Rebuild Hugo site after content changes"""
    try:
        print(f"[Hugo] Starting site rebuild...")
        os.chdir(HUGO_ROOT)
        
        # Run Hugo to rebuild the site
        result = subprocess.run(
            ['hugo', '--minify', '--gc'],
            capture_output=True,
            text=True,
            timeout=120
        )
        
        if result.returncode == 0:
            print(f"[Hugo] Site rebuilt successfully!")
            print(f"[Hugo] Output: {result.stdout}")
            return True, "Site rebuilt successfully"
        else:
            print(f"[Hugo] Build failed: {result.stderr}")
            return False, result.stderr
    except subprocess.TimeoutExpired:
        print("[Hugo] Build timeout")
        return False, "Build timeout"
    except FileNotFoundError:
        print("[Hugo] Hugo not found, skipping rebuild")
        return False, "Hugo not installed"
    except Exception as e:
        print(f"[Hugo] Rebuild error: {e}")
        return False, str(e)

def rebuild_hugo_async():
    """Rebuild Hugo site in background thread"""
    thread = threading.Thread(target=rebuild_hugo_site)
    thread.daemon = True
    thread.start()

def git_commit(message):
    """Commit changes to git"""
    try:
        os.chdir(HUGO_ROOT)
        subprocess.run(['git', 'add', '.'], check=True, capture_output=True)
        subprocess.run(['git', 'commit', '-m', message], check=True, capture_output=True)
        return True
    except Exception as e:
        print(f"Git commit failed: {e}")
        return False

def parse_frontmatter(content):
    """Parse YAML frontmatter from markdown file"""
    if content.startswith('---'):
        parts = content.split('---', 2)
        if len(parts) >= 3:
            try:
                frontmatter = yaml.safe_load(parts[1])
                body = parts[2].strip()
                return frontmatter, body
            except yaml.YAMLError:
                pass
    return {}, content

def create_frontmatter(data):
    """Create YAML frontmatter string"""
    frontmatter = {
        'title': data.get('title', 'Untitled'),
        'date': data.get('date', datetime.now()).strftime('%Y-%m-%dT%H:%M:%S+03:00') if hasattr(data.get('date', datetime.now()), 'strftime') else str(data.get('date', '')),
        'draft': data.get('draft', False),
    }
    
    if data.get('description'):
        frontmatter['description'] = data['description']
    if data.get('tags'):
        tags = [t.strip() for t in data['tags'].split(',') if t.strip()]
        if tags:
            frontmatter['tags'] = tags
    if data.get('categories'):
        cats = [c.strip() for c in data['categories'].split(',') if c.strip()]
        if cats:
            frontmatter['categories'] = cats
    if data.get('image'):
        frontmatter['image'] = data['image']
    
    return '---\n' + yaml.dump(frontmatter, allow_unicode=True, default_flow_style=False) + '---\n\n'

def get_posts():
    """Get all posts from content directory"""
    posts = []
    if POSTS_DIR.exists():
        for file in sorted(POSTS_DIR.glob('*.md'), key=lambda x: x.stat().st_mtime, reverse=True):
            try:
                content = file.read_text(encoding='utf-8')
                frontmatter, body = parse_frontmatter(content)
                date_val = frontmatter.get('date', '')
                if hasattr(date_val, 'strftime'):
                    date_str = date_val.strftime('%Y-%m-%d')
                elif date_val:
                    date_str = str(date_val)[:10]
                else:
                    date_str = ''
                posts.append({
                    'filename': file.name,
                    'title': frontmatter.get('title', file.stem),
                    'date': date_str,
                    'draft': frontmatter.get('draft', False),
                    'description': frontmatter.get('description', ''),
                    'tags': frontmatter.get('tags', []),
                    'categories': frontmatter.get('categories', []),
                    'content': body,
                    'word_count': len(body.split()),
                })
            except Exception as e:
                print(f"Error reading {file}: {e}")
    return posts

def get_post(filename):
    """Get single post by filename"""
    file_path = POSTS_DIR / filename
    if file_path.exists():
        try:
            content = file_path.read_text(encoding='utf-8')
            frontmatter, body = parse_frontmatter(content)
            date_val = frontmatter.get('date', '')
            if hasattr(date_val, 'strftime'):
                date_str = date_val.strftime('%Y-%m-%d')
            elif date_val:
                date_str = str(date_val)[:10]
            else:
                date_str = ''
            return {
                'filename': filename,
                'title': frontmatter.get('title', file_path.stem),
                'date': date_str,
                'draft': frontmatter.get('draft', False),
                'description': frontmatter.get('description', ''),
                'tags': ', '.join(frontmatter.get('tags', [])) if isinstance(frontmatter.get('tags'), list) else frontmatter.get('tags', ''),
                'categories': ', '.join(frontmatter.get('categories', [])) if isinstance(frontmatter.get('categories'), list) else frontmatter.get('categories', ''),
                'image': frontmatter.get('image', ''),
                'content': body,
            }
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    return None

def save_post(filename, data):
    """Save post to file"""
    try:
        file_path = POSTS_DIR / filename
        frontmatter = create_frontmatter(data)
        content = frontmatter + data.get('content', '')
        file_path.write_text(content, encoding='utf-8')
        return True
    except Exception as e:
        print(f"Error saving {filename}: {e}")
        return False

# Routes - all use explicit /admin prefix in redirects
@app.route('/')
@login_required
def index():
    """Dashboard"""
    posts = get_posts()
    stats = {
        'total_posts': len(posts),
        'published': len([p for p in posts if not p['draft']]),
        'drafts': len([p for p in posts if p['draft']]),
        'total_words': sum(p['word_count'] for p in posts),
    }
    return render_template('index.html', stats=stats, recent_posts=posts[:5])

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if current_user.is_authenticated:
        return redirect(admin_url('/'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = next((u for u in users.values() if u.username == username), None)
        
        if user and check_password_hash(user.password_hash, password):
            login_user(user, remember=True)
            flash('Logged in successfully!', 'success')
            return redirect(admin_url('/'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    """Logout"""
    logout_user()
    flash('Logged out successfully!', 'success')
    return redirect(admin_url('/login'))

@app.route('/posts')
@login_required
def posts():
    """List all posts"""
    all_posts = get_posts()
    return render_template('posts.html', posts=all_posts)

@app.route('/posts/new', methods=['GET', 'POST'])
@login_required
def new_post():
    """Create new post"""
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        if not title:
            flash('Title is required', 'error')
            return render_template('edit_post.html', post=None)
        
        slug = request.form.get('slug', '').strip()
        if not slug:
            slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
        
        filename = f"{slug}.md"
        
        if (POSTS_DIR / filename).exists():
            flash(f'A post with slug "{slug}" already exists', 'error')
            return render_template('edit_post.html', post=None)
        
        data = {
            'title': title,
            'content': request.form.get('content', ''),
            'draft': request.form.get('draft') == 'on',
            'tags': request.form.get('tags', ''),
            'categories': request.form.get('categories', ''),
            'description': request.form.get('description', ''),
            'image': request.form.get('image', ''),
            'date': datetime.now()
        }
        
        if save_post(filename, data):
            git_commit(f"Add new post: {title}")
            # Rebuild Hugo site after creating post
            rebuild_hugo_async()
            flash(f'Post "{title}" created successfully! Site is rebuilding...', 'success')
            return redirect(admin_url('/posts'))
        else:
            flash('Error creating post', 'error')
    
    return render_template('edit_post.html', post=None)

@app.route('/posts/edit/<filename>', methods=['GET', 'POST'])
@login_required
def edit_post(filename):
    """Edit existing post"""
    if request.method == 'POST':
        data = {
            'title': request.form.get('title', '').strip(),
            'content': request.form.get('content', ''),
            'draft': request.form.get('draft') == 'on',
            'tags': request.form.get('tags', ''),
            'categories': request.form.get('categories', ''),
            'description': request.form.get('description', ''),
            'image': request.form.get('image', ''),
        }
        
        if not data['title']:
            flash('Title is required', 'error')
            post = get_post(filename)
            return render_template('edit_post.html', post=post)
        
        if save_post(filename, data):
            git_commit(f"Update post: {data['title']}")
            # Rebuild Hugo site after editing post
            rebuild_hugo_async()
            flash(f'Post "{data["title"]}" updated successfully! Site is rebuilding...', 'success')
            return redirect(admin_url('/posts'))
        else:
            flash('Error updating post', 'error')
    
    post = get_post(filename)
    if not post:
        flash('Post not found', 'error')
        return redirect(admin_url('/posts'))
    
    return render_template('edit_post.html', post=post)

@app.route('/posts/delete/<filename>', methods=['POST'])
@login_required
def delete_post(filename):
    """Delete post"""
    file_path = POSTS_DIR / filename
    if file_path.exists():
        post = get_post(filename)
        file_path.unlink()
        git_commit(f"Delete post: {post['title'] if post else filename}")
        # Rebuild Hugo site after deleting post
        rebuild_hugo_async()
        flash('Post deleted successfully! Site is rebuilding...', 'success')
    else:
        flash('Post not found', 'error')
    
    return redirect(admin_url('/posts'))

# Allowed image extensions
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'ico'}

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_images():
    """Get all uploaded images"""
    images = []
    if UPLOAD_DIR.exists():
        for ext in ALLOWED_EXTENSIONS:
            for file in UPLOAD_DIR.glob(f'*.{ext}'):
                try:
                    stat = file.stat()
                    images.append({
                        'filename': file.name,
                        'url': f'/uploads/{file.name}',
                        'size': stat.st_size,
                        'size_human': format_size(stat.st_size),
                        'modified': datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M'),
                    })
                except Exception as e:
                    print(f"Error reading {file}: {e}")
    # Sort by modification time, newest first
    images.sort(key=lambda x: x['modified'], reverse=True)
    return images

def format_size(size):
    """Format file size to human readable"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size < 1024:
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TB"

@app.route('/images')
@login_required
def images():
    """Image gallery/manager"""
    all_images = get_images()
    return render_template('images.html', images=all_images)

@app.route('/upload', methods=['POST'])
@login_required
def upload_file():
    """Upload file (image, etc.)"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': f'File type not allowed. Allowed: {ALLOWED_EXTENSIONS}'}), 400
    
    if file:
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"{timestamp}_{filename}"
        file_path = UPLOAD_DIR / filename
        file.save(file_path)
        
        url = f"/uploads/{filename}"
        return jsonify({'url': url, 'filename': filename, 'success': True})
    
    return jsonify({'error': 'Upload failed'}), 500

@app.route('/images/delete/<filename>', methods=['POST'])
@login_required
def delete_image(filename):
    """Delete an uploaded image"""
    file_path = UPLOAD_DIR / secure_filename(filename)
    if file_path.exists():
        try:
            file_path.unlink()
            if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                return jsonify({'success': True, 'message': 'Image deleted'})
            flash('Image deleted successfully!', 'success')
        except Exception as e:
            if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                return jsonify({'error': str(e)}), 500
            flash(f'Error deleting image: {e}', 'error')
    else:
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return jsonify({'error': 'Image not found'}), 404
        flash('Image not found', 'error')
    
    return redirect(admin_url('/images'))

@app.route('/preview', methods=['POST'])
@login_required
def preview():
    """Preview markdown content"""
    content = request.json.get('content', '')
    html = markdown.markdown(content, extensions=['extra', 'codehilite', 'tables', 'toc'])
    return jsonify({'html': html})

@app.route('/rebuild', methods=['POST'])
@login_required
def rebuild():
    """Manually trigger Hugo site rebuild"""
    success, message = rebuild_hugo_site()
    if success:
        flash('Site rebuilt successfully!', 'success')
    else:
        flash(f'Rebuild failed: {message}', 'error')
    return redirect(admin_url('/'))

@app.route('/api/images')
@login_required
def api_images():
    """API endpoint to get list of images"""
    all_images = get_images()
    return jsonify({'images': all_images})

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

# Announcement/Notice Management
ANNOUNCEMENT_FILE = CUSTOM_PARTIAL_DIR / 'custom_1.html'

def get_announcement():
    """Get current announcement content"""
    if ANNOUNCEMENT_FILE.exists():
        try:
            content = ANNOUNCEMENT_FILE.read_text(encoding='utf-8')
            # Parse the announcement content
            import re
            title_match = re.search(r'<h3[^>]*>([^<]+)</h3>', content)
            text_match = re.search(r'<p class="text-foreground/80[^>]*>([^<]+)</p>', content)
            icon_match = re.search(r'<div class="text-primary text-2xl[^>]*>\s*([^<\s]+)', content)
            
            return {
                'title': title_match.group(1) if title_match else '网站公告',
                'text': text_match.group(1).strip() if text_match else '',
                'icon': icon_match.group(1).strip() if icon_match else '📢',
                'enabled': True
            }
        except Exception as e:
            print(f"Error reading announcement: {e}")
    return {'title': '网站公告', 'text': '', 'icon': '📢', 'enabled': False}

def save_announcement(title, text, icon='📢'):
    """Save announcement to custom partial"""
    template = '''<div class="bg-primary/10 border-primary/30 rounded-xl border p-6 shadow-sm mb-6">
  <div class="flex items-start gap-3">
    <div class="text-primary text-2xl flex-shrink-0">
      {icon}
    </div>
    <div class="flex-1">
      <h3 class="text-foreground font-semibold mb-2">{title}</h3>
      <p class="text-foreground/80 text-sm leading-relaxed">
        {text}
      </p>
      <p class="text-muted-foreground text-xs mt-3">
        {{{{ now.Format "2006-01-02" }}}}
      </p>
    </div>
  </div>
</div>
'''
    try:
        content = template.format(title=title, text=text, icon=icon)
        ANNOUNCEMENT_FILE.write_text(content, encoding='utf-8')
        return True
    except Exception as e:
        print(f"Error saving announcement: {e}")
        return False

@app.route('/announcement', methods=['GET', 'POST'])
@login_required
def announcement():
    """Manage site announcement/notice"""
    if request.method == 'POST':
        title = request.form.get('title', '网站公告').strip()
        text = request.form.get('text', '').strip()
        icon = request.form.get('icon', '📢').strip()
        
        if not text:
            flash('Announcement text is required', 'error')
        elif save_announcement(title, text, icon):
            git_commit(f"Update announcement: {title}")
            rebuild_hugo_async()
            flash('Announcement updated successfully! Site is rebuilding...', 'success')
            return redirect(admin_url('/announcement'))
        else:
            flash('Error saving announcement', 'error')
    
    current = get_announcement()
    return render_template('announcement.html', announcement=current)

# Override Flask-Login unauthorized handler to use admin prefix
@login_manager.unauthorized_handler
def unauthorized():
    flash('Please log in to access this page.', 'message')
    return redirect(admin_url('/login'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=os.environ.get('DEBUG', 'False') == 'True')

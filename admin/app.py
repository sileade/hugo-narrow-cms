#!/usr/bin/env python3
"""
Hugo Narrow CMS - Simple Admin Panel
Self-hosted admin interface for managing Hugo content
"""

import os
import subprocess
from datetime import datetime
from pathlib import Path
from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import frontmatter
import markdown

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')

# Configuration
CONTENT_DIR = Path(os.environ.get('GIT_REPO_PATH', '/app/content'))
STATIC_DIR = Path(os.environ.get('STATIC_DIR', '/app/static'))
POSTS_DIR = CONTENT_DIR / 'posts'
PAGES_DIR = CONTENT_DIR / 'pages'
UPLOAD_DIR = STATIC_DIR / 'uploads'

# Ensure directories exist
POSTS_DIR.mkdir(parents=True, exist_ok=True)
PAGES_DIR.mkdir(parents=True, exist_ok=True)
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Git configuration
GIT_USER_NAME = os.environ.get('GIT_USER_NAME', 'Admin')
GIT_USER_EMAIL = os.environ.get('GIT_USER_EMAIL', 'admin@localhost')

# Flask-Login setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

class User(UserMixin):
    def __init__(self, id, username, password_hash):
        self.id = id
        self.username = username
        self.password_hash = password_hash

# Simple user storage (in production, use database)
ADMIN_USERNAME = os.environ.get('ADMIN_USERNAME', 'admin')
ADMIN_PASSWORD_HASH = generate_password_hash(os.environ.get('ADMIN_PASSWORD', 'admin'))
users = {
    '1': User('1', ADMIN_USERNAME, ADMIN_PASSWORD_HASH)
}

@login_manager.user_loader
def load_user(user_id):
    return users.get(user_id)

def git_commit(message):
    """Commit changes to git"""
    try:
        subprocess.run(['git', 'config', 'user.name', GIT_USER_NAME], cwd=CONTENT_DIR, check=True)
        subprocess.run(['git', 'config', 'user.email', GIT_USER_EMAIL], cwd=CONTENT_DIR, check=True)
        subprocess.run(['git', 'add', '.'], cwd=CONTENT_DIR, check=True)
        subprocess.run(['git', 'commit', '-m', message], cwd=CONTENT_DIR, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Git commit failed: {e}")
        return False

def get_posts():
    """Get all posts from content directory"""
    posts = []
    if POSTS_DIR.exists():
        for file_path in POSTS_DIR.glob('*.md'):
            try:
                post = frontmatter.load(file_path)
                posts.append({
                    'filename': file_path.name,
                    'title': post.get('title', 'Untitled'),
                    'date': post.get('date', datetime.now()),
                    'draft': post.get('draft', False),
                    'tags': post.get('tags', []),
                    'content': post.content
                })
            except Exception as e:
                print(f"Error loading {file_path}: {e}")
    return sorted(posts, key=lambda x: x['date'], reverse=True)

def get_post(filename):
    """Get a single post"""
    file_path = POSTS_DIR / filename
    if file_path.exists():
        post = frontmatter.load(file_path)
        return {
            'filename': filename,
            'title': post.get('title', ''),
            'date': post.get('date', datetime.now()),
            'draft': post.get('draft', False),
            'tags': post.get('tags', []),
            'categories': post.get('categories', []),
            'description': post.get('description', ''),
            'content': post.content
        }
    return None

def save_post(filename, data):
    """Save post to file"""
    file_path = POSTS_DIR / filename
    
    # Create frontmatter
    post = frontmatter.Post(data['content'])
    post['title'] = data['title']
    post['date'] = data.get('date', datetime.now())
    post['draft'] = data.get('draft', False)
    
    if data.get('tags'):
        post['tags'] = [tag.strip() for tag in data['tags'].split(',') if tag.strip()]
    
    if data.get('categories'):
        post['categories'] = [cat.strip() for cat in data['categories'].split(',') if cat.strip()]
    
    if data.get('description'):
        post['description'] = data['description']
    
    # Write to file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(frontmatter.dumps(post))
    
    return True

@app.route('/')
@login_required
def index():
    """Dashboard"""
    posts = get_posts()
    stats = {
        'total_posts': len(posts),
        'published': len([p for p in posts if not p['draft']]),
        'drafts': len([p for p in posts if p['draft']]),
    }
    return render_template('index.html', stats=stats, recent_posts=posts[:5])

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = next((u for u in users.values() if u.username == username), None)
        
        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            next_page = request.args.get('next')
            return redirect(next_page or url_for('index'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    """Logout"""
    logout_user()
    return redirect(url_for('login'))

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
        title = request.form.get('title')
        slug = request.form.get('slug') or title.lower().replace(' ', '-')
        filename = f"{slug}.md"
        
        data = {
            'title': title,
            'content': request.form.get('content', ''),
            'draft': request.form.get('draft') == 'on',
            'tags': request.form.get('tags', ''),
            'categories': request.form.get('categories', ''),
            'description': request.form.get('description', ''),
            'date': datetime.now()
        }
        
        if save_post(filename, data):
            git_commit(f"Add new post: {title}")
            flash(f'Post "{title}" created successfully!', 'success')
            return redirect(url_for('posts'))
        else:
            flash('Error creating post', 'error')
    
    return render_template('edit_post.html', post=None)

@app.route('/posts/edit/<filename>', methods=['GET', 'POST'])
@login_required
def edit_post(filename):
    """Edit existing post"""
    if request.method == 'POST':
        data = {
            'title': request.form.get('title'),
            'content': request.form.get('content', ''),
            'draft': request.form.get('draft') == 'on',
            'tags': request.form.get('tags', ''),
            'categories': request.form.get('categories', ''),
            'description': request.form.get('description', ''),
        }
        
        if save_post(filename, data):
            git_commit(f"Update post: {data['title']}")
            flash(f'Post "{data["title"]}" updated successfully!', 'success')
            return redirect(url_for('posts'))
        else:
            flash('Error updating post', 'error')
    
    post = get_post(filename)
    if not post:
        flash('Post not found', 'error')
        return redirect(url_for('posts'))
    
    return render_template('edit_post.html', post=post)

@app.route('/posts/delete/<filename>', methods=['POST'])
@login_required
def delete_post(filename):
    """Delete post"""
    file_path = POSTS_DIR / filename
    if file_path.exists():
        post = get_post(filename)
        file_path.unlink()
        git_commit(f"Delete post: {post['title']}")
        flash('Post deleted successfully!', 'success')
    else:
        flash('Post not found', 'error')
    
    return redirect(url_for('posts'))

@app.route('/upload', methods=['POST'])
@login_required
def upload_file():
    """Upload file (image, etc.)"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if file:
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"{timestamp}_{filename}"
        file_path = UPLOAD_DIR / filename
        file.save(file_path)
        
        # Return URL path
        url = f"/uploads/{filename}"
        return jsonify({'url': url, 'filename': filename})
    
    return jsonify({'error': 'Upload failed'}), 500

@app.route('/preview', methods=['POST'])
@login_required
def preview():
    """Preview markdown content"""
    content = request.json.get('content', '')
    html = markdown.markdown(content, extensions=['extra', 'codehilite'])
    return jsonify({'html': html})

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=os.environ.get('DEBUG', 'False') == 'True')

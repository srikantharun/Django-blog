#!/bin/bash

# Define colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Print section header
print_header() {
    echo -e "\n${BLUE}==== $1 ====${NC}"
}

# Check directories exist
check_directories() {
    if [ ! -d "static" ]; then
        echo -e "${YELLOW}Creating 'static' directory...${NC}"
        mkdir -p static/css static/js static/images
    fi
    
    if [ ! -d "templates" ]; then
        echo -e "${YELLOW}Creating 'templates' directory...${NC}"
        mkdir -p templates/includes templates/accounts templates/blog
    fi
    
    if [ ! -d "apps/accounts/templates/accounts" ]; then
        echo -e "${YELLOW}Creating app template directories...${NC}"
        mkdir -p apps/accounts/templates/accounts
        mkdir -p apps/blog/templates/blog
    fi
}

# Create file utility function
create_file() {
    local filepath=$1
    local description=$2
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$filepath")"
    
    shift 2
    cat > "$filepath" << EOF
$*
EOF
    
    echo -e "${GREEN}Created:${NC} $filepath ${YELLOW}($description)${NC}"
}

# Start script
print_header "Setting up templates and static files for Django Blog"
check_directories


# Password reset templates
create_file "templates/accounts/password_reset.html" "Password reset request" '{% extends "base.html" %}
{% load crispy_forms_tags %}

{% block title %}Reset Password{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-6 offset-md-3">
        <div class="card shadow-sm">
            <div class="card-body">
                <h2 class="text-center mb-4">Reset Password</h2>
                <p class="text-muted mb-4">Enter your email address below, and we'\''ll email instructions for setting a new password.</p>
                <form method="POST">
                    {% csrf_token %}
                    {{ form|crispy }}
                    <button class="btn btn-primary btn-block w-100 mt-4" type="submit">Send Password Reset Email</button>
                </form>
                <div class="border-top pt-3 mt-4 text-center">
                    <small class="text-muted">
                        <a href="{% url "login" %}">Back to Login</a>
                    </small>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}'

create_file "templates/accounts/password_reset_done.html" "Password reset email sent" '{% extends "base.html" %}

{% block title %}Password Reset Email Sent{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-6 offset-md-3 text-center">
        <div class="card shadow-sm">
            <div class="card-body">
                <h2 class="mb-4">Email Sent</h2>
                <div class="alert alert-info" role="alert">
                    <p>We'\''ve emailed you instructions for setting your password.</p>
                    <p>You should receive the email shortly!</p>
                </div>
                <p class="mt-3">If you don'\''t receive an email, please make sure you'\''ve entered the address you registered with, and check your spam folder.</p>
                <a href="{% url "login" %}" class="btn btn-outline-primary mt-3">Return to Login</a>
            </div>
        </div>
    </div>
</div>
{% endblock %}'

create_file "templates/accounts/password_reset_confirm.html" "Password reset confirmation" '{% extends "base.html" %}
{% load crispy_forms_tags %}

{% block title %}Set New Password{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-6 offset-md-3">
        <div class="card shadow-sm">
            <div class="card-body">
                <h2 class="text-center mb-4">Set New Password</h2>
                {% if validlink %}
                    <form method="POST">
                        {% csrf_token %}
                        {{ form|crispy }}
                        <button class="btn btn-primary btn-block w-100 mt-4" type="submit">Set New Password</button>
                    </form>
                {% else %}
                    <div class="alert alert-danger">
                        <p>The password reset link was invalid, possibly because it has already been used.</p>
                        <p>Please request a new password reset.</p>
                    </div>
                    <a href="{% url "password_reset" %}" class="btn btn-outline-primary mt-3">Request New Reset Link</a>
                {% endif %}
            </div>
        </div>
    </div>
</div>
{% endblock %}'

create_file "templates/accounts/password_reset_complete.html" "Password reset complete" '{% extends "base.html" %}

{% block title %}Password Reset Complete{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-6 offset-md-3 text-center">
        <div class="card shadow-sm">
            <div class="card-body">
                <h2 class="mb-4">Password Reset Complete</h2>
                <div class="alert alert-success" role="alert">
                    <p>Your password has been set.</p>
                </div>
                <p>You may now log in with your new password.</p>
                <a href="{% url "login" %}" class="btn btn-primary mt-3">Login</a>
            </div>
        </div>
    </div>
</div>
{% endblock %}'

# =================
# BLOG TEMPLATES
# =================
print_header "Creating blog templates"

# Post list template
create_file "templates/blog/post_list.html" "Blog post list page" '{% extends "base.html" %}

{% block title %}Home - Django Blog{% endblock %}

{% block content %}
<div class="row">
    <!-- Main Content -->
    <div class="col-lg-8">
        <h1 class="mb-4">Latest Posts</h1>
        
        {% if posts %}
            {% for post in posts %}
                <div class="post-card mb-4">
                    {% if post.featured_image %}
                        <img class="post-image" src="{{ post.featured_image.url }}" alt="{{ post.title }}">
                    {% endif %}
                    <div class="post-content">
                        <div class="post-meta d-flex justify-content-between">
                            <span><i class="far fa-user me-1"></i> {{ post.author.username }}</span>
                            <span><i class="far fa-calendar me-1"></i> {{ post.publish|date:"F d, Y" }}</span>
                        </div>
                        <h2 class="post-title">
                            <a href="{{ post.get_absolute_url }}" class="text-decoration-none">{{ post.title }}</a>
                        </h2>
                        <div class="mb-2">
                            {% for category in post.categories.all %}
                                <a href="{% url "blog:category_posts" category.slug %}" class="category-tag">
                                    {{ category.name }}
                                </a>
                            {% endfor %}
                        </div>
                        <p class="post-excerpt">{{ post.body|truncatewords:50 }}</p>
                        <a href="{{ post.get_absolute_url }}" class="btn btn-primary btn-sm">Read More</a>
                    </div>
                </div>
            {% endfor %}
            
            <!-- Pagination -->
            {% if is_paginated %}
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        {% if page_obj.has_previous %}
                            <li class="page-item">
                                <a class="page-link" href="?page=1">First</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.previous_page_number }}">Previous</a>
                            </li>
                        {% endif %}
                        
                        {% for num in page_obj.paginator.page_range %}
                            {% if page_obj.number == num %}
                                <li class="page-item active">
                                    <span class="page-link">{{ num }}</span>
                                </li>
                            {% elif num > page_obj.number|add:"-3" and num < page_obj.number|add:"3" %}
                                <li class="page-item">
                                    <a class="page-link" href="?page={{ num }}">{{ num }}</a>
                                </li>
                            {% endif %}
                        {% endfor %}
                        
                        {% if page_obj.has_next %}
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.next_page_number }}">Next</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.paginator.num_pages }}">Last</a>
                            </li>
                        {% endif %}
                    </ul>
                </nav>
            {% endif %}
        {% else %}
            <div class="alert alert-info" role="alert">
                No posts found. Be the first to <a href="{% url "blog:post_create" %}">create a post</a>!
            </div>
        {% endif %}
    </div>
    
    <!-- Sidebar -->
    <div class="col-lg-4">
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Categories</h5>
            </div>
            <div class="card-body">
                {% if categories %}
                    <div class="d-flex flex-wrap">
                        {% for category in categories %}
                            <a href="{% url "blog:category_posts" category.slug %}" class="category-tag">
                                {{ category.name }}
                            </a>
                        {% endfor %}
                    </div>
                {% else %}
                    <p class="mb-0">No categories available.</p>
                {% endif %}
            </div>
        </div>
        
        {% if user.is_authenticated %}
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <a href="{% url "blog:post_create" %}" class="btn btn-primary btn-sm mb-2 w-100">
                        <i class="fas fa-plus-circle me-1"></i> Create New Post
                    </a>
                    <a href="{% url "blog:category_create" %}" class="btn btn-outline-primary btn-sm w-100">
                        <i class="fas fa-tag me-1"></i> Create New Category
                    </a>
                </div>
            </div>
        {% endif %}
    </div>
</div>
{% endblock %}'

# Post detail template
create_file "templates/blog/post_detail.html" "Blog post detail page" '{% extends "base.html" %}

{% block title %}{{ object.title }} - Django Blog{% endblock %}

{% block content %}
<div class="row">
    <div class="col-lg-8">
        <!-- Post Content -->
        <article>
            <h1 class="mt-4">{{ object.title }}</h1>
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="text-muted">
                    <i class="far fa-user me-1"></i> 
                    <a href="{% url "blog:user_posts" object.author.username %}" class="text-decoration-none">
                        {{ object.author.username }}
                    </a>
                    <span class="mx-2">|</span>
                    <i class="far fa-calendar me-1"></i> {{ object.publish|date:"F d, Y" }}
                </div>
                {% if object.author == user %}
                    <div>
                        <a href="{% url "blog:post_update" object.publish.year object.publish.month object.publish.day object.slug %}" class="btn btn-sm btn-outline-primary">
                            <i class="fas fa-edit me-1"></i> Edit
                        </a>
                        <a href="{% url "blog:post_delete" object.publish.year object.publish.month object.publish.day object.slug %}" class="btn btn-sm btn-outline-danger delete-confirm">
                            <i class="fas fa-trash me-1"></i> Delete
                        </a>
                    </div>
                {% endif %}
            </div>
            
            <div class="mb-3">
                {% for category in object.categories.all %}
                    <a href="{% url "blog:category_posts" category.slug %}" class="category-tag">
                        {{ category.name }}
                    </a>
                {% endfor %}
            </div>
            
            {% if object.featured_image %}
                <img class="img-fluid rounded mb-4" src="{{ object.featured_image.url }}" alt="{{ object.title }}">
            {% endif %}
            
            <div class="post-body mb-4">
                {{ object.body|linebreaks }}
            </div>
        </article>
        
        <!-- Comments Section -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Comments ({{ comments.count }})</h5>
            </div>
            <div class="card-body">
                {% if user.is_authenticated %}
                    <div class="mb-4">
                        <h5>Leave a Comment</h5>
                        <form method="POST" action="{% url "blog:add_comment" object.publish.year object.publish.month object.publish.day object.slug %}">
                            {% csrf_token %}
                            {{ comment_form.body }}
                            <button type="submit" class="btn btn-primary mt-3">Submit Comment</button>
                        </form>
                    </div>
                {% else %}
                    <div class="alert alert-info mb-4">
                        Please <a href="{% url "login" %}?next={{ request.path }}">login</a> to leave a comment.
                    </div>
                {% endif %}
                
                {% if comments %}
                    <div class="comments-container">
                        {% for comment in comments %}
                            <div class="comment mb-3">
                                <div class="comment-header">
                                    <div class="comment-author">
                                        <i class="far fa-user me-1"></i> {{ comment.author.username }}
                                    </div>
                                    <div class="comment-date">
                                        <i class="far fa-clock me-1"></i> {{ comment.created|date:"F d, Y H:i" }}
                                        
                                        {% if comment.author == user %}
                                            <a href="{% url "blog:delete_comment" comment.id %}" class="ms-2 text-danger delete-confirm" title="Delete comment">
                                                <i class="fas fa-trash-alt"></i>
                                            </a>
                                        {% endif %}
                                    </div>
                                </div>
                                <div class="comment-content">
                                    {{ comment.body|linebreaks }}
                                </div>
                            </div>
                        {% endfor %}
                    </div>
                {% else %}
                    <div class="text-center py-4">
                        <p class="text-muted mb-0">No comments yet. Be the first to comment!</p>
                    </div>
                {% endif %}
            </div>
        </div>
    </div>
    
    <!-- Sidebar -->
    <div class="col-lg-4">
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">About the Author</h5>
            </div>
            <div class="card-body text-center">
                <img class="rounded-circle mb-3" src="{{ object.author.profile.avatar.url }}" alt="{{ object.author.username }}" style="width: 100px; height: 100px; object-fit: cover;">
                <h5>{{ object.author.username }}</h5>
                <p class="text-muted mb-2">
                    {% if object.author.profile.bio %}
                        {{ object.author.profile.bio|truncatechars:100 }}
                    {% else %}
                        No bio available.
                    {% endif %}
                </p>
                <a href="{% url "blog:user_posts" object.author.username %}" class="btn btn-outline-primary btn-sm">
                    View All Posts by {{ object.author.username }}
                </a>
            </div>
        </div>
    </div>
</div>
{% endblock %}'

# Post form template
create_file "templates/blog/post_form.html" "Blog post form" '{% extends "base.html" %}
{% load crispy_forms_tags %}

{% block title %}{% if form.instance.pk %}Edit Post{% else %}Create Post{% endif %} - Django Blog{% endblock %}

{% block content %}
<div class="row">
    <div class="col-lg-8 mx-auto">
        <div class="card shadow-sm">
            <div class="card-body">
                <h2 class="mb-4">{% if form.instance.pk %}Edit Post{% else %}Create New Post{% endif %}</h2>
                <form method="POST" enctype="multipart/form-data">
                    {% csrf_token %}
                    {{ form|crispy }}
                    <div class="mt-4">
                        <button type="submit" class="btn btn-primary">
                            {% if form.instance.pk %}Update Post{% else %}Create Post{% endif %}
                        </button>
                        <a href="{% url "blog:post_list" %}" class="btn btn-outline-secondary ms-2">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}'

# Post delete template
create_file "templates/blog/post_confirm_delete.html" "Blog post delete confirmation" '{% extends "base.html" %}

{% block title %}Delete Post - Django Blog{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-6 offset-md-3">
        <div class="card shadow-sm">
            <div class="card-body text-center">
                <h2 class="mb-4 text-danger">Delete Post</h2>
                <div class="alert alert-warning" role="alert">
                    <i class="fas fa-exclamation-triangle me-2"></i> Are you sure you want to delete "{{ object.title }}"?
                </div>
                <p class="mb-4">This action cannot be undone.</p>
                
                <form method="POST">
                    {% csrf_token %}
                    <button type="submit" class="btn btn-danger">Delete</button>
                    <a href="{{ object.get_absolute_url }}" class="btn btn-outline-secondary ms-2">Cancel</a>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}'

# Category form template
create_file "templates/blog/category_form.html" "Category form" '{% extends "base.html" %}
{% load crispy_forms_tags %}

{% block title %}Create Category - Django Blog{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-6 offset-md-3">
        <div class="card shadow-sm">
            <div class="card-body">
                <h2 class="mb-4">Create New Category</h2>
                <form method="POST">
                    {% csrf_token %}
                    {{ form|crispy }}
                    <div class="mt-4">
                        <button type="submit" class="btn btn-primary">Create Category</button>
                        <a href="{% url "blog:post_list" %}" class="btn btn-outline-secondary ms-2">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}'

# Category posts template
create_file "templates/blog/category_posts.html" "Category posts list" '{% extends "base.html" %}

{% block title %}{{ category.name }} - Django Blog{% endblock %}

{% block content %}
<div class="row">
    <div class="col-lg-8">
        <div class="mb-4">
            <h1 class="mb-2">Category: {{ category.name }}</h1>
            {% if category.description %}
                <p class="text-muted">{{ category.description }}</p>
            {% endif %}
        </div>
        
        {% if posts %}
            {% for post in posts %}
                <div class="post-card mb-4">
                    {% if post.featured_image %}
                        <img class="post-image" src="{{ post.featured_image.url }}" alt="{{ post.title }}">
                    {% endif %}
                    <div class="post-content">
                        <div class="post-meta d-flex justify-content-between">
                            <span><i class="far fa-user me-1"></i> {{ post.author.username }}</span>
                            <span><i class="far fa-calendar me-1"></i> {{ post.publish|date:"F d, Y" }}</span>
                        </div>
                        <h2 class="post-title">
                            <a href="{{ post.get_absolute_url }}" class="text-decoration-none">{{ post.title }}</a>
                        </h2>
                        <div class="mb-2">
                            {% for category in post.categories.all %}
                                <a href="{% url "blog:category_posts" category.slug %}" class="category-tag">
                                    {{ category.name }}
                                </a>
                            {% endfor %}
                        </div>
                        <p class="post-excerpt">{{ post.body|truncatewords:50 }}</p>
                        <a href="{{ post.get_absolute_url }}" class="btn btn-primary btn-sm">Read More</a>
                    </div>
                </div>
            {% endfor %}
            
            <!-- Pagination -->
            {% if is_paginated %}
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        {% if page_obj.has_previous %}
                            <li class="page-item">
                                <a class="page-link" href="?page=1">First</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.previous_page_number }}">Previous</a>
                            </li>
                        {% endif %}
                        
                        {% for num in page_obj.paginator.page_range %}
                            {% if page_obj.number == num %}
                                <li class="page-item active">
                                    <span class="page-link">{{ num }}</span>
                                </li>
                            {% elif num > page_obj.number|add:"-3" and num < page_obj.number|add:"3" %}
                                <li class="page-item">
                                    <a class="page-link" href="?page={{ num }}">{{ num }}</a>
                                </li>
                            {% endif %}
                        {% endfor %}
                        
                        {% if page_obj.has_next %}
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.next_page_number }}">Next</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.paginator.num_pages }}">Last</a>
                            </li>
                        {% endif %}
                    </ul>
                </nav>
            {% endif %}
        {% else %}
            <div class="alert alert-info" role="alert">
                No posts found in this category.
            </div>
        {% endif %}
    </div>
    
    <!-- Sidebar -->
    <div class="col-lg-4">
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">All Categories</h5>
            </div>
            <div class="card-body">
                <div class="d-flex flex-wrap">
                    {% for cat in categories %}
                        <a href="{% url "blog:category_posts" cat.slug %}" 
                           class="category-tag {% if cat == category %}bg-primary{% endif %}">
                            {{ cat.name }}
                        </a>
                    {% endfor %}
                </div>
            </div>
        </div>
        
        {% if user.is_authenticated %}
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <a href="{% url "blog:post_create" %}" class="btn btn-primary btn-sm mb-2 w-100">
                        <i class="fas fa-plus-circle me-1"></i> Create New Post
                    </a>
                    <a href="{% url "blog:category_create" %}" class="btn btn-outline-primary btn-sm w-100">
                        <i class="fas fa-tag me-1"></i> Create New Category
                    </a>
                </div>
            </div>
        {% endif %}
    </div>
</div>
{% endblock %}'

# User posts template
create_file "templates/blog/user_posts.html" "User posts page" '{% extends "base.html" %}

{% block title %}Posts by {{ view.kwargs.username }} - Django Blog{% endblock %}

{% block content %}
<div class="row">
    <div class="col-lg-8">
        <div class="mb-4">
            <h1 class="mb-2">Posts by {{ view.kwargs.username }}</h1>
        </div>
        
        {% if posts %}
            {% for post in posts %}
                <div class="post-card mb-4">
                    {% if post.featured_image %}
                        <img class="post-image" src="{{ post.featured_image.url }}" alt="{{ post.title }}">
                    {% endif %}
                    <div class="post-content">
                        <div class="post-meta d-flex justify-content-between">
                            <span><i class="far fa-calendar me-1"></i> {{ post.publish|date:"F d, Y" }}</span>
                            <span>{% if post.status == "draft" %}<span class="badge bg-warning">Draft</span>{% endif %}</span>
                        </div>
                        <h2 class="post-title">
                            <a href="{{ post.get_absolute_url }}" class="text-decoration-none">{{ post.title }}</a>
                        </h2>
                        <div class="mb-2">
                            {% for category in post.categories.all %}
                                <a href="{% url "blog:category_posts" category.slug %}" class="category-tag">
                                    {{ category.name }}
                                </a>
                            {% endfor %}
                        </div>
                        <p class="post-excerpt">{{ post.body|truncatewords:50 }}</p>
                        <div class="d-flex">
                            <a href="{{ post.get_absolute_url }}" class="btn btn-primary btn-sm me-2">Read More</a>
                            {% if post.author == user %}
                                <a href="{% url "blog:post_update" post.publish.year post.publish.month post.publish.day post.slug %}" class="btn btn-outline-primary btn-sm me-2">
                                    <i class="fas fa-edit"></i> Edit
                                </a>
                                <a href="{% url "blog:post_delete" post.publish.year post.publish.month post.publish.day post.slug %}" class="btn btn-outline-danger btn-sm delete-confirm">
                                    <i class="fas fa-trash"></i> Delete
                                </a>
                            {% endif %}
                        </div>
                    </div>
                </div>
            {% endfor %}
            
            <!-- Pagination -->
            {% if is_paginated %}
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        {% if page_obj.has_previous %}
                            <li class="page-item">
                                <a class="page-link" href="?page=1">First</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.previous_page_number }}">Previous</a>
                            </li>
                        {% endif %}
                        
                        {% for num in page_obj.paginator.page_range %}
                            {% if page_obj.number == num %}
                                <li class="page-item active">
                                    <span class="page-link">{{ num }}</span>
                                </li>
                            {% elif num > page_obj.number|add:"-3" and num < page_obj.number|add:"3" %}
                                <li class="page-item">
                                    <a class="page-link" href="?page={{ num }}">{{ num }}</a>
                                </li>
                            {% endif %}
                        {% endfor %}
                        
                        {% if page_obj.has_next %}
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.next_page_number }}">Next</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="?page={{ page_obj.paginator.num_pages }}">Last</a>
                            </li>
                        {% endif %}
                    </ul>
                </nav>
            {% endif %}
        {% else %}
            <div class="alert alert-info" role="alert">
                No posts found by this user.
            </div>
        {% endif %}
    </div>
    
    <!-- Sidebar -->
    <div class="col-lg-4">
        {% if user.is_authenticated and user.username == view.kwargs.username %}
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Manage Your Content</h5>
                </div>
                <div class="card-body">
                    <a href="{% url "blog:post_create" %}" class="btn btn-primary btn-sm mb-2 w-100">
                        <i class="fas fa-plus-circle me-1"></i> Create New Post
                    </a>
                    <a href="{% url "blog:category_create" %}" class="btn btn-outline-primary btn-sm w-100">
                        <i class="fas fa-tag me-1"></i> Create New Category
                    </a>
                </div>
            </div>
        {% endif %}
    </div>
</div>
{% endblock %}'

# =================
# APP-SPECIFIC TEMPLATES
# =================
print_header "Creating app-specific templates"

# Symbolic links from project templates to app templates
for file in templates/accounts/*.html; do
    filename=$(basename "$file")
    ln -sf "../../../templates/accounts/$filename" "apps/accounts/templates/accounts/"
    echo -e "${GREEN}Linked:${NC} apps/accounts/templates/accounts/$filename"
done

for file in templates/blog/*.html; do
    filename=$(basename "$file")
    ln -sf "../../../templates/blog/$filename" "apps/blog/templates/blog/"
    echo -e "${GREEN}Linked:${NC} apps/blog/templates/blog/$filename"
done

print_header "Done!"
echo -e "${GREEN}All template and static files for your Django blog project have been created.${NC}"
echo -e "Next steps:"
echo "1. Install required packages: pip install django Pillow crispy-forms crispy-bootstrap5"
echo "2. Run migrations: python manage.py makemigrations && python manage.py migrate"
echo "3. Create a superuser: python manage.py createsuperuser"
echo "4. Start your development server: python manage.py runserver"
echo "5. Visit http://127.0.0.1:8000/ to see your blog in action!"

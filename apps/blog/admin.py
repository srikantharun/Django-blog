from django.contrib import admin
from .models import Post, Comment, Category


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """Admin configuration for the Category model."""
    list_display = ["name", "slug", "created_at"]
    prepopulated_fields = {"slug": ("name",)}
    search_fields = ["name", "description"]


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    """Admin configuration for the Post model."""
    list_display = ["title", "slug", "author", "publish", "status"]
    list_filter = ["status", "created", "publish", "author"]
    search_fields = ["title", "body"]
    prepopulated_fields = {"slug": ("title",)}
    raw_id_fields = ["author"]
    date_hierarchy = "publish"
    list_editable = ["status"]


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    """Admin configuration for the Comment model."""
    list_display = ["author", "post", "created", "active"]
    list_filter = ["active", "created", "updated"]
    search_fields = ["author__username", "body", "post__title"]
    actions = ["approve_comments", "disapprove_comments"]
    
    def approve_comments(self, request, queryset):
        """Mark selected comments as active."""
        queryset.update(active=True)
    
    def disapprove_comments(self, request, queryset):
        """Mark selected comments as inactive."""
        queryset.update(active=False)

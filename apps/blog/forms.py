from django import forms
from .models import Post, Comment, Category


class PostForm(forms.ModelForm):
    """Form for creating and editing blog posts."""
    
    class Meta:
        model = Post
        fields = ["title", "body", "featured_image", "status", "categories"]
        widgets = {
            "title": forms.TextInput(attrs={"class": "form-control"}),
            "body": forms.Textarea(attrs={"class": "form-control"}),
            "status": forms.Select(attrs={"class": "form-select"}),
            "categories": forms.SelectMultiple(attrs={"class": "form-select"}),
        }


class CommentForm(forms.ModelForm):
    """Form for adding comments to posts."""
    
    class Meta:
        model = Comment
        fields = ["body"]
        widgets = {
            "body": forms.Textarea(attrs={"class": "form-control", "rows": 5, 
                                          "placeholder": "Add your comment here..."}),
        }
        labels = {
            "body": "Comment",
        }


class CategoryForm(forms.ModelForm):
    """Form for creating and editing categories."""
    
    class Meta:
        model = Category
        fields = ["name", "description"]
        widgets = {
            "name": forms.TextInput(attrs={"class": "form-control"}),
            "description": forms.Textarea(attrs={"class": "form-control", "rows": 3}),
        }

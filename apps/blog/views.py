from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.contrib import messages
from django.views.generic import (
    ListView, DetailView, CreateView, UpdateView, DeleteView
)
from django.urls import reverse_lazy
from .models import Post, Comment, Category
from .forms import PostForm, CommentForm, CategoryForm


class PostListView(ListView):
    """Display a list of published blog posts."""
    model = Post
    template_name = "blog/post_list.html"
    context_object_name = "posts"
    paginate_by = 5
    
    def get_queryset(self):
        return Post.objects.filter(status="published")
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["categories"] = Category.objects.all()
        return context


class UserPostListView(ListView):
    """Display posts by a specific user."""
    model = Post
    template_name = "blog/user_posts.html"
    context_object_name = "posts"
    paginate_by = 5
    
    def get_queryset(self):
        user = get_object_or_404(User, username=self.kwargs.get("username"))
        return Post.objects.filter(author=user).order_by("-publish")


class CategoryPostListView(ListView):
    """Display posts in a specific category."""
    model = Post
    template_name = "blog/category_posts.html"
    context_object_name = "posts"
    paginate_by = 5
    
    def get_queryset(self):
        self.category = get_object_or_404(Category, slug=self.kwargs.get("slug"))
        return Post.objects.filter(categories=self.category, status="published")
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["category"] = self.category
        return context


class PostDetailView(DetailView):
    """Display a single blog post with comments."""
    model = Post
    template_name = "blog/post_detail.html"
    
    def get_object(self):
        return get_object_or_404(
            Post,
            slug=self.kwargs["slug"],
            publish__year=self.kwargs["year"],
            publish__month=self.kwargs["month"],
            publish__day=self.kwargs["day"],
        )
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["comments"] = self.object.comments.filter(active=True)
        context["comment_form"] = CommentForm()
        return context


class PostCreateView(LoginRequiredMixin, CreateView):
    """Create a new blog post."""
    model = Post
    form_class = PostForm
    template_name = "blog/post_form.html"
    
    def form_valid(self, form):
        form.instance.author = self.request.user
        messages.success(self.request, "Your post has been created!")
        return super().form_valid(form)


class PostUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    """Update an existing blog post."""
    model = Post
    form_class = PostForm
    template_name = "blog/post_form.html"
    
    def form_valid(self, form):
        messages.success(self.request, "Your post has been updated!")
        return super().form_valid(form)
    
    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author


class PostDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    """Delete a blog post."""
    model = Post
    template_name = "blog/post_confirm_delete.html"
    success_url = reverse_lazy("blog:post_list")
    
    def test_func(self):
        post = self.get_object()
        return self.request.user == post.author
    
    def delete(self, request, *args, **kwargs):
        messages.success(self.request, "Your post has been deleted!")
        return super().delete(request, *args, **kwargs)


@login_required
def add_comment(request, year, month, day, slug):
    """Add a comment to a blog post."""
    post = get_object_or_404(
        Post,
        slug=slug,
        publish__year=year,
        publish__month=month,
        publish__day=day,
    )
    
    if request.method == "POST":
        form = CommentForm(request.POST)
        if form.is_valid():
            comment = form.save(commit=False)
            comment.post = post
            comment.author = request.user
            comment.save()
            messages.success(request, "Your comment has been added successfully!")
            return redirect(post.get_absolute_url())
    
    return redirect(post.get_absolute_url())


@login_required
def delete_comment(request, comment_id):
    """Delete a comment."""
    comment = get_object_or_404(Comment, id=comment_id)
    
    # Ensure the user is the comment author
    if request.user != comment.author:
        messages.error(request, "You cannot delete this comment!")
        return redirect(comment.post.get_absolute_url())
    
    post_url = comment.post.get_absolute_url()
    comment.delete()
    messages.success(request, "Your comment has been deleted successfully!")
    return redirect(post_url)


class CategoryCreateView(LoginRequiredMixin, CreateView):
    """Create a new category."""
    model = Category
    form_class = CategoryForm
    template_name = "blog/category_form.html"
    success_url = reverse_lazy("blog:post_list")

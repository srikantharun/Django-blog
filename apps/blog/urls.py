from django.urls import path
from . import views

app_name = "blog"

urlpatterns = [
    path("", views.PostListView.as_view(), name="post_list"),
    path("user/<str:username>/", views.UserPostListView.as_view(), name="user_posts"),
    path("category/<slug:slug>/", views.CategoryPostListView.as_view(), name="category_posts"),
    path("post/new/", views.PostCreateView.as_view(), name="post_create"),
    path("post/<int:year>/<int:month>/<int:day>/<slug:slug>/", 
        views.PostDetailView.as_view(), name="post_detail"),
    path("post/<int:year>/<int:month>/<int:day>/<slug:slug>/update/", 
        views.PostUpdateView.as_view(), name="post_update"),
    path("post/<int:year>/<int:month>/<int:day>/<slug:slug>/delete/", 
        views.PostDeleteView.as_view(), name="post_delete"),
    path("post/<int:year>/<int:month>/<int:day>/<slug:slug>/comment/", 
        views.add_comment, name="add_comment"),
    path("comment/<int:comment_id>/delete/", 
        views.delete_comment, name="delete_comment"),
    path("category/new/", 
        views.CategoryCreateView.as_view(), name="category_create"),
]

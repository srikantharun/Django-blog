from django.test import TestCase
from django.contrib.auth.models import User
from django.urls import reverse
from .models import Post, Category, Comment


class BlogModelTests(TestCase):
    def setUp(self):
        # Create test user
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123"
        )
        
        # Create test category
        self.category = Category.objects.create(
            name="Test Category",
            description="A test category"
        )
        
        # Create test post
        self.post = Post.objects.create(
            title="Test Post",
            slug="test-post",
            author=self.user,
            body="Content of the test post",
            status="published"
        )
        self.post.categories.add(self.category)
        
        # Create test comment
        self.comment = Comment.objects.create(
            post=self.post,
            author=self.user,
            body="This is a test comment"
        )
    
    def test_post_creation(self):
        """Test that the post is created with the correct data."""
        self.assertEqual(self.post.title, "Test Post")
        self.assertEqual(self.post.author, self.user)
        self.assertEqual(self.post.status, "published")
        
    def test_category_creation(self):
        """Test that the category is created with the correct data."""
        self.assertEqual(self.category.name, "Test Category")
        self.assertEqual(self.category.slug, "test-category")
        
    def test_comment_creation(self):
        """Test that the comment is created with the correct data."""
        self.assertEqual(self.comment.body, "This is a test comment")
        self.assertEqual(self.comment.author, self.user)
        self.assertEqual(self.comment.post, self.post)
        
    def test_post_str_representation(self):
        """Test the string representation of the Post model."""
        self.assertEqual(str(self.post), "Test Post")
        
    def test_category_str_representation(self):
        """Test the string representation of the Category model."""
        self.assertEqual(str(self.category), "Test Category")
        
    def test_post_get_absolute_url(self):
        """Test the get_absolute_url method of the Post model."""
        url = self.post.get_absolute_url()
        year = self.post.publish.year
        month = self.post.publish.month
        day = self.post.publish.day
        self.assertEqual(
            url, 
            reverse("blog:post_detail", args=[year, month, day, self.post.slug])
        )


class BlogViewsTests(TestCase):
    def setUp(self):
        # Create test user
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123"
        )
        
        # Create test post
        self.post = Post.objects.create(
            title="Test Post",
            slug="test-post",
            author=self.user,
            body="Content of the test post",
            status="published"
        )
    
    def test_post_list_view(self):
        """Test that the post list view returns a 200 status code."""
        response = self.client.get(reverse("blog:post_list"))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Test Post")
        
    def test_post_detail_view(self):
        """Test that the post detail view returns a 200 status code."""
        year = self.post.publish.year
        month = self.post.publish.month
        day = self.post.publish.day
        response = self.client.get(
            reverse("blog:post_detail", args=[year, month, day, self.post.slug])
        )
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Test Post")
        self.assertContains(response, "Content of the test post")

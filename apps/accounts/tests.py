from django.test import TestCase
from django.contrib.auth.models import User
from .models import Profile
from django.urls import reverse


class ProfileModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123"
        )
    
    def test_profile_creation(self):
        """Test that a Profile is automatically created when a User is created."""
        self.assertTrue(Profile.objects.filter(user=self.user).exists())
        
    def test_profile_str_representation(self):
        """Test the string representation of the Profile model."""
        profile = Profile.objects.get(user=self.user)
        self.assertEqual(str(profile), "testuser Profile")


class RegisterViewTests(TestCase):
    def test_register_page_status_code(self):
        """Test that the register page returns a 200 status code."""
        response = self.client.get(reverse("register"))
        self.assertEqual(response.status_code, 200)
        
    def test_register_form_valid(self):
        """Test user registration with valid form data."""
        response = self.client.post(reverse("register"), {
            "username": "newuser",
            "email": "newuser@example.com",
            "password1": "complex_password_123",
            "password2": "complex_password_123"
        })
        self.assertEqual(User.objects.count(), 1)
        self.assertRedirects(response, reverse("login"))

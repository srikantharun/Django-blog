from django.contrib import admin
from .models import Profile


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    """Admin configuration for the Profile model."""
    list_display = ["user", "location", "date_joined"]
    search_fields = ["user__username", "user__email", "location"]
    list_filter = ["date_joined"]

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

class CustomUserAdmin(UserAdmin):
    model = User
    list_display = ('username', 'role')

    # Fields shown when editing an existing user
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('role',)}),
    )

    # Fields shown when adding a new user
    add_fieldsets = (
        ('Admin Registration', {
            'classes': ('wide',),
            'fields': ('username', 'role', 'password1','password2'),
        }),
    )

admin.site.register(User, CustomUserAdmin)

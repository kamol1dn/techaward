from django.contrib import admin
from .models import Users

class UsersAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'email','birthday','password''male','female')


admin.site.register(Users, UsersAdmin)

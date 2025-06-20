from django.contrib import admin
from .models import EmergencyRequest

class Emergency(admin.ModelAdmin):
    list_display = ('type','help_for')


admin.site.register(EmergencyRequest,Emergency)
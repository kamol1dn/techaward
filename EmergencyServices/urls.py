from django.urls import path
from .views import Emergency
urlpatterns=[
    path('service',Emergency.as_view(),name='emergency'),


]
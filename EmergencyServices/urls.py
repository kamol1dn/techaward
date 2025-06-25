from django.urls import path
from .views import Emergency
urlpatterns=[
    path('request',Emergency.as_view(),name='emergency'),


]

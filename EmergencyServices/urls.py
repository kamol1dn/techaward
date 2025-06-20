from django.urls import path
from .views import Emergency,EmergencyRequestList
from rest_framework_simplejwt.views import TokenRefreshView
urlpatterns=[
    path('service',Emergency.as_view(),name='emergency'),
    path('get',EmergencyRequestList.as_view(),name='emergency'),


]
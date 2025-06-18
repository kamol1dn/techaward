from django.urls import path
from .views import MyTokenObtainPair
from rest_framework_simplejwt.views import TokenObtainPairView

urlpatterns =[
    path('login',MyTokenObtainPair.as_view(),name='login'),
]
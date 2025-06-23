from django.urls import path
from .views import MyTokenObtainPair, LogoutView
from rest_framework_simplejwt.views import TokenObtainPairView

urlpatterns =[
    path('login',MyTokenObtainPair.as_view(),name='login'),
    path("logout", LogoutView.as_view(), name="logout"),
]
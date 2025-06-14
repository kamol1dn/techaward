from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from accounts.views import RegisterAPIView

urlpatterns = [
    path('register/', view=RegisterAPIView.as_view(), name='register'),
    path('login/', view=TokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]

from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import MyToken

class MyTokenObtainPair(TokenObtainPairView):
    serializer_class = MyToken
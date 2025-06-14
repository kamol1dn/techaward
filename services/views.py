from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework_simplejwt.authentication import JWTAuthentication


class HelloWorldView(APIView):
    def get(self, request):
        return Response({"message": "Hello, it is working fine!"})

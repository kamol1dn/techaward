from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework_simplejwt.authentication import JWTAuthentication

from accounts.models import University
from services.serializers import UniversitySerializer


class HelloWorldView(APIView):
    def get(self, request):
        return Response({"message": "Hello, it is working fine!"})


class UniversityViewSet(ModelViewSet):
    queryset = University.objects.all().order_by('id')
    serializer_class = UniversitySerializer
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

from rest_framework import generics
from .serializers import EmergencySerializer,EmergencyGetSerializer
from .models import EmergencyRequest

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

class Emergency(generics.CreateAPIView):
    query=EmergencyRequest.objects.all()
    serializer_class = EmergencySerializer

class EmergencyRequestList(APIView):
    def get(self, request):
        emergencies = EmergencyRequest.objects.all().order_by('-date_created')
        serializer = EmergencyGetSerializer(emergencies, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
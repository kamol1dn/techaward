from rest_framework import generics
from .serializers import EmergencySerializer
from .models import EmergencyRequest

class Emergency(generics.CreateAPIView):
    query=EmergencyRequest.objects.all()
    serializer_class = EmergencySerializer


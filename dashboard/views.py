from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from EmergencyServices.models import EmergencyRequest
from .serilazers import EmergencyGetSerializer

class EmergencyRequestList(APIView):
    def get(self, request):
        emergencies = EmergencyRequest.objects.all().order_by('-date_created')
        serializer = EmergencyGetSerializer(emergencies, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
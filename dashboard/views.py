from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from EmergencyServices.models import EmergencyRequest
from .serializers import EmergencyGetSerializer
from rest_framework.generics import get_object_or_404
class EmergencyRequestList(APIView):
    serializer_class=EmergencyGetSerializer

    def get(self, request):
        emergencies = EmergencyRequest.objects.all()
        serializer = EmergencyGetSerializer(emergencies, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


# views.py
class AssignDoctorView(APIView):
    def patch(self, request, pk):
        emergency = get_object_or_404(EmergencyRequest, pk=pk)
        serializer = EmergencyGetSerializer(emergency, data=request.data, partial=True)

        if serializer.is_valid():
            if request.data.get('assigned_to'):
                serializer.save(status='in progress')  # Automatically set status
            else:
                serializer.save()  # In case only status is changed
            return Response({'message': 'Doctor assigned successfully', 'data': serializer.data}, status=200)
        return Response(serializer.errors, status=400)
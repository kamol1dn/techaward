from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.generics import get_object_or_404
from EmergencyServices.models import EmergencyRequest
from .serializers import EmergencyGetSerializer
class EmergencyRequestList(APIView):
    serializer_class=EmergencyGetSerializer

    def get(self, request):
        emergencies = EmergencyRequest.objects.all()
        user_data=request.session.get("user_data")
        if emergencies.exists():
            serializer = EmergencyGetSerializer(emergencies, many=True)
            info={'request': serializer.data, 'user_data': user_data}
            return Response(info, status=status.HTTP_200_OK)
        else:
            return Response(data={'message': 'Failed, user data and request not found'},status=status.HTTP_400_BAD_REQUEST)



class AssignDoctorView(APIView):
    def patch(self, request, pk):
        try:
            instance = get_object_or_404(EmergencyRequest, pk=pk)
        except EmergencyRequest.DoesNotExist:
            return Response({'message': 'Emergency not fount'}, status=status.HTTP_404_NOT_FOUND)

        serializer=EmergencyGetSerializer(instance,data=request.data,partial=True)
        if serializer.is_valid():
            if request.data.get("assigned_to"):
                serializer.save(status='in progress')
                updated=serializer.save()
                if updated.status=="resolved":
                    request.session.pop("user_data",None)

            return Response(serializer.data)

        return Response(data={'message':'Failed to modify info'},status=status.HTTP_400_BAD_REQUEST)



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
                return Response({'message': 'Emergency not found'}, status=status.HTTP_404_NOT_FOUND)

            assigned_to = request.data.get("assigned_to")
            new_status = request.data.get("status")

            print(f"PATCH request for emergency {pk}")
            print(f"Received data: {dict(request.data)}")



            if new_status is not None:
                instance.status = new_status
                updated = True

            if assigned_to is not None:
                instance.assigned_to = assigned_to
                updated = True

            if updated:
                instance.save()
                if instance.status == "resolved":
                    request.session.pop("user_data", None)

                serializer = EmergencyGetSerializer(instance)
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response({'message': 'No valid fields to update'}, status=status.HTTP_400_BAD_REQUEST)




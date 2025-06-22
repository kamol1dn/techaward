from rest_framework import status
from rest_framework.decorators import APIView
from .serializers import EmergencySerializer
from .models import EmergencyRequest
from rest_framework.response import Response

class Emergency(APIView):
    serializer_class=EmergencySerializer
    def post(self,request):
        user_data = request.data.get("user_data")
        if user_data:
            request.session['user_data']=user_data
        if request.method=='POST':
            serializer=self.serializer_class(data=request.data)
            if serializer.is_valid():
                instance=serializer.save()
                m={
                    'success': True,
                    'request_id': instance.id,
                    'message': 'Emergency request received and being processed'
                }
                return Response(m,status=status.HTTP_201_CREATED)

            return Response(data={'success': False, 'message': 'Emergency request was not valid or not processed', 'error':serializer.errors},
                            status=status.HTTP_400_BAD_REQUEST)

        return Response(data={'success': False, 'message': 'Emergency request was not valid or not processed'},
                        status=status.HTTP_400_BAD_REQUEST)



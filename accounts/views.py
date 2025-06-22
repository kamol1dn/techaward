from rest_framework import status, generics
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from accounts.serializers import RegisterSerializer, CustomLoginSerializer, FlatProfileUpdateSerializer
from django.db import transaction


class CustomLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = CustomLoginSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class RegisterAPIView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.save()

        return Response({
            "success": True,
            "token": f"user_token_{user.id}_{user.email}",
            "message": "User registered successfully."
        }, status=status.HTTP_201_CREATED)


class UpdateProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request):
        user = request.user
        serializer = FlatProfileUpdateSerializer(user, data=request.data)

        if not serializer.is_valid():
            errors = []
            for field, messages in serializer.errors.items():
                errors.extend(messages if isinstance(messages, list) else [messages])
            return Response({
                'success': False,
                'message': f"Validation failed: {', '.join(errors)}"
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                user = serializer.save()
        except Exception as e:
            return Response({
                'success': False,
                'message': f"Update failed: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Build updated user data
        medical_record = getattr(user, 'medical_record', None)

        response_data = {
            'success': True,
            'message': 'Profile updated successfully',
            'user_data': {
                "name": user.first_name,
                "surname": user.last_name,
                "phone": user.phone,
                "email": user.email,
                "age": user.age,
                "gender": user.gender,
                "passport": user.passport_series,
                "blood_type": medical_record.blood_type if medical_record else "",
                "allergies": medical_record.allergies if medical_record else "",
                "illness": medical_record.ongoing_illness if medical_record else "",
                "additional_info": medical_record.additional_info if medical_record else "",
            }
        }

        return Response(response_data)
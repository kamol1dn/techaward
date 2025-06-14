from rest_framework import status, generics
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from accounts.serializers import RegisterSerializer


class RegisterAPIView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.save()

        return Response({
            "id": user.id,
            "email": user.email,
            "message": "User registered successfully."},
            status=status.HTTP_201_CREATED)

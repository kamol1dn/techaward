# ==========================================
# VIEWS.PY
# ==========================================

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.views import TokenRefreshView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError, InvalidToken
from django.contrib.auth import get_user_model
from .serializers import (
    CustomLoginSerializer,
    RegisterSerializer,
    FlatProfileUpdateSerializer
)

User = get_user_model()


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            serializer = RegisterSerializer(data=request.data)
            if serializer.is_valid():
                result = serializer.save()

                # Build user data for response
                user = result['user']
                user_data = {
                    "id": user.id,
                    "name": user.first_name,
                    "surname": user.last_name,
                    "email": user.email,
                    "phone": user.phone,
                    "age": user.age,
                    "gender": user.gender,
                    "passport": user.passport_series,
                }

                # Add medical data if exists
                try:
                    medical = user.medical_record
                    user_data.update({
                        "blood_type": medical.blood_type,
                        "allergies": medical.allergies,
                        "illness": medical.ongoing_illness,
                        "additional_info": medical.additional_info,
                    })
                except:
                    user_data.update({
                        "blood_type": "",
                        "allergies": "",
                        "illness": "",
                        "additional_info": "",
                    })

                return Response({
                    'success': True,
                    'message': 'Registration successful',
                    'access_token': result['access_token'],
                    'refresh_token': result['refresh_token'],
                    'user_data': user_data
                }, status=status.HTTP_201_CREATED)

            return Response({
                'success': False,
                'message': 'Registration failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                'success': False,
                'message': 'Server error during registration',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            serializer = CustomLoginSerializer(data=request.data, context={'request': request})
            if serializer.is_valid():
                return Response(serializer.validated_data, status=status.HTTP_200_OK)

            return Response({
                'success': False,
                'message': 'Invalid credentials',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                'success': False,
                'message': 'Server error during login',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """Get current user profile"""
        try:
            user = request.user
            user_data = {
                "id": user.id,
                "name": user.first_name,
                "surname": user.last_name,
                "phone": user.phone,
                "email": user.email,
                "age": user.age,
                "gender": user.gender,
                "passport": user.passport_series,
            }

            # Add medical data
            try:
                medical = user.medical_record
                user_data.update({
                    "blood_type": medical.blood_type,
                    "allergies": medical.allergies,
                    "illness": medical.ongoing_illness,
                    "additional_info": medical.additional_info,
                })
            except:
                user_data.update({
                    "blood_type": "",
                    "allergies": "",
                    "illness": "",
                    "additional_info": "",
                })

            return Response({
                'success': True,
                'user_data': user_data
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({
                'success': False,
                'message': 'Error fetching profile',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def put(self, request):
        """Update user profile"""
        try:
            serializer = FlatProfileUpdateSerializer(
                request.user,
                data=request.data,
                partial=True
            )

            if serializer.is_valid():
                updated_user = serializer.save()

                # Build response data
                user_data = {
                    "id": updated_user.id,
                    "name": updated_user.first_name,
                    "surname": updated_user.last_name,
                    "phone": updated_user.phone,
                    "email": updated_user.email,
                    "age": updated_user.age,
                    "gender": updated_user.gender,
                    "passport": updated_user.passport_series,
                }

                # Add medical data
                try:
                    medical = updated_user.medical_record
                    user_data.update({
                        "blood_type": medical.blood_type,
                        "allergies": medical.allergies,
                        "illness": medical.ongoing_illness,
                        "additional_info": medical.additional_info,
                    })
                except:
                    user_data.update({
                        "blood_type": "",
                        "allergies": "",
                        "illness": "",
                        "additional_info": "",
                    })

                return Response({
                    'success': True,
                    'message': 'Profile updated successfully',
                    'user_data': user_data
                }, status=status.HTTP_200_OK)

            return Response({
                'success': False,
                'message': 'Update failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                'success': False,
                'message': 'Server error during update',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get("refresh_token")
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()

            return Response({
                'success': True,
                'message': 'Successfully logged out'
            }, status=status.HTTP_200_OK)

        except TokenError:
            return Response({
                'success': False,
                'message': 'Invalid token'
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Logout failed',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CustomTokenRefreshView(TokenRefreshView):
    def post(self, request, *args, **kwargs):
        try:
            response = super().post(request, *args, **kwargs)
            return Response({
                'success': True,
                'access_token': response.data['access'],
                'message': 'Token refreshed successfully'
            }, status=status.HTTP_200_OK)
        except InvalidToken:
            return Response({
                'success': False,
                'message': 'Refresh token is invalid or expired'
            }, status=status.HTTP_401_UNAUTHORIZED)
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Token refresh failed',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


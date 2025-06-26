# ==========================================
# VIEWS.PY (Updated with logging)
# ==========================================

import logging
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
import logging
# Configure logger
logger = logging.getLogger(__name__)

User = get_user_model()


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        logger.info("Registration attempt started")
        try:
            serializer = RegisterSerializer(data=request.data)
            if serializer.is_valid():
                logger.info("Registration data validation successful")
                result = serializer.save()

                # Build user data for response
                user = result['user']
                logger.info(f"User created successfully with ID: {user.id}, email: {user.email}")
                
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
                    logger.info(f"Medical record found and added for user {user.id}")
                except:
                    user_data.update({
                        "blood_type": "",
                        "allergies": "",
                        "illness": "",
                        "additional_info": "",
                    })
                    logger.info(f"No medical record found for user {user.id}, using empty values")

                logger.info(f"Registration completed successfully for user {user.id}")
                return Response({
                    'success': True,
                    'message': 'Registration successful',
                    'access_token': result['access_token'],
                    'refresh_token': result['refresh_token'],
                    'user_data': user_data
                }, status=status.HTTP_201_CREATED)

            logger.warning(f"Registration validation failed: {serializer.errors}")
            return Response({
                'success': False,
                'message': 'Registration failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            logger.error(f"Server error during registration: {str(e)}", exc_info=True)
            return Response({
                'success': False,
                'message': 'Server error during registration',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        logger.info("Login attempt started")
        try:
            serializer = CustomLoginSerializer(data=request.data, context={'request': request})
            if serializer.is_valid():
                logger.info("Login successful")
                return Response(serializer.validated_data, status=status.HTTP_200_OK)

            logger.warning(f"Login validation failed: {serializer.errors}")
            return Response({
                'success': False,
                'message': 'Invalid credentials',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            logger.error(f"Server error during login: {str(e)}", exc_info=True)
            return Response({
                'success': False,
                'message': 'Server error during login',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """Get current user profile"""
        logger.info(f"Profile fetch requested for user {request.user.id}")
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
                logger.info(f"Medical record found and included for user {user.id}")
            except:
                user_data.update({
                    "blood_type": "",
                    "allergies": "",
                    "illness": "",
                    "additional_info": "",
                })
                logger.info(f"No medical record found for user {user.id}, using empty values")

            logger.info(f"Profile fetched successfully for user {user.id}")
            return Response({
                'success': True,
                'user_data': user_data
            }, status=status.HTTP_200_OK)

        except Exception as e:
            logger.error(f"Error fetching profile for user {request.user.id}: {str(e)}", exc_info=True)
            return Response({
                'success': False,
                'message': 'Error fetching profile',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def put(self, request):
        """Update user profile"""
        logger.info(f"Profile update requested for user {request.user.id}")
        try:
            serializer = FlatProfileUpdateSerializer(
                request.user,
                data=request.data,
                partial=True
            )

            if serializer.is_valid():
                logger.info(f"Profile update validation successful for user {request.user.id}")
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
                    logger.info(f"Medical record found and included for updated user {updated_user.id}")
                except:
                    user_data.update({
                        "blood_type": "",
                        "allergies": "",
                        "illness": "",
                        "additional_info": "",
                    })
                    logger.info(f"No medical record found for updated user {updated_user.id}, using empty values")

                logger.info(f"Profile updated successfully for user {updated_user.id}")
                return Response({
                    'success': True,
                    'message': 'Profile updated successfully',
                    'user_data': user_data
                }, status=status.HTTP_200_OK)

            logger.warning(f"Profile update validation failed for user {request.user.id}: {serializer.errors}")
            return Response({
                'success': False,
                'message': 'Update failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            logger.error(f"Server error during profile update for user {request.user.id}: {str(e)}", exc_info=True)
            return Response({
                'success': False,
                'message': 'Server error during update',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        logger.info(f"Logout requested for user {request.user.id}")
        try:
            refresh_token = request.data.get("refresh_token")
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
                logger.info(f"Refresh token blacklisted for user {request.user.id}")
            else:
                logger.warning(f"No refresh token provided for logout by user {request.user.id}")

            logger.info(f"User {request.user.id} logged out successfully")
            return Response({
                'success': True,
                'message': 'Successfully logged out'
            }, status=status.HTTP_200_OK)

        except TokenError as e:
            logger.warning(f"Invalid token during logout for user {request.user.id}: {str(e)}")
            return Response({
                'success': False,
                'message': 'Invalid token'
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f"Logout failed for user {request.user.id}: {str(e)}", exc_info=True)
            return Response({
                'success': False,
                'message': 'Logout failed',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CustomTokenRefreshView(TokenRefreshView):
    def post(self, request, *args, **kwargs):
        logger.info("Token refresh requested")
        try:
            response = super().post(request, *args, **kwargs)
            logger.info("Token refreshed successfully")
            return Response({
                'success': True,
                'access_token': response.data['access'],
                'message': 'Token refreshed successfully'
            }, status=status.HTTP_200_OK)
        except InvalidToken as e:
            logger.warning(f"Invalid token during refresh: {str(e)}")
            return Response({
                'success': False,
                'message': 'Refresh token is invalid or expired'
            }, status=status.HTTP_401_UNAUTHORIZED)
        except Exception as e:
            logger.error(f"Token refresh failed: {str(e)}", exc_info=True)
            return Response({
                'success': False,
                'message': 'Token refresh failed',
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

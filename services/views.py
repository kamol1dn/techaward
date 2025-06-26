
# ==========================================
# OTP VIEWS (Updated with logging)
# ==========================================

import random
from rest_framework import status
from django.core.mail import send_mail
from services.serializers import OTPVerifySerializer,OTPRequestSerializer
from services.models import EmailOTP
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework_simplejwt.authentication import JWTAuthentication
from django.conf import settings
import logging
# Configure logger for OTP views
otp_logger = logging.getLogger('otp_views')

class HelloWorldView(APIView):
    def get(self, request):
        otp_logger.info("Hello World endpoint accessed")
        return Response({"message": "Hello, it is working fine!"})


class OTPRequestView(APIView):
    def post(self, request):
        otp_logger.info("OTP request started")
        serializer = OTPRequestSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            otp_logger.info(f"OTP request validation successful for email: {email}")
            
            code = str(random.randint(100000, 999999))
            otp_logger.info(f"Generated OTP code for email: {email}")
            
            # Delete existing OTP entries for this email
            deleted_count = EmailOTP.objects.filter(email=email).delete()[0]
            if deleted_count > 0:
                otp_logger.info(f"Deleted {deleted_count} existing OTP entries for email: {email}")
            
            # Create new OTP entry
            EmailOTP.objects.create(email=email, code=code)
            otp_logger.info(f"Created new OTP entry for email: {email}")
            
            try:
                send_mail(
                    'Your OTP Code',
                    f'Your OTP code is: {code}',
                    settings.DEFAULT_FROM_EMAIL,
                    [email],
                    fail_silently=False,
                )
                otp_logger.info(f"OTP email sent successfully to: {email}")
            except Exception as e:
                otp_logger.error(f"Failed to send OTP email to {email}: {str(e)}", exc_info=True)
                return Response({
                    'success': False,
                    'message': 'Failed to send OTP email'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            return Response({
                'success': True,
                'message': 'OTP sent successfully'
            }, status=status.HTTP_200_OK)
        
        otp_logger.warning(f"OTP request validation failed: {serializer.errors}")
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OTPVerifyView(APIView):
    def post(self, request):
        otp_logger.info("OTP verification started")
        serializer = OTPVerifySerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            code = serializer.validated_data['code']
            otp_logger.info(f"OTP verification validation successful for email: {email}")
            
            try:
                otp_entry = EmailOTP.objects.get(email=email, code=code)
                otp_logger.info(f"OTP entry found for email: {email}")
                
                if otp_entry.is_expired():
                    otp_logger.warning(f"OTP expired for email: {email}")
                    otp_entry.delete()
                    return Response({
                        'success': False,
                        'message': 'OTP expired'
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                # Generate registration token
                registration_token = f'reg_token_{otp_entry.created_at.strftime("%Y%m%d%H%M%S")}_{otp_entry.email}'
                otp_logger.info(f"Generated registration token for email: {email}")
                
                otp_entry.delete()  # One-time use
                otp_logger.info(f"OTP entry deleted after successful verification for email: {email}")
                
                return Response({
                    'success': True,
                    'registration_token': registration_token
                }, status=status.HTTP_200_OK)
                
            except EmailOTP.DoesNotExist:
                otp_logger.warning(f"Invalid OTP provided for email: {email}")
                return Response({
                    'success': False,
                    'message': 'Invalid OTP'
                }, status=status.HTTP_400_BAD_REQUEST)
        
        otp_logger.warning(f"OTP verification validation failed: {serializer.errors}")
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
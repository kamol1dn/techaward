# ==========================================
# SERIALIZERS.PY
# ==========================================

from rest_framework import serializers
from django.contrib.auth import authenticate
from django.db import models
from rest_framework_simplejwt.tokens import RefreshToken
from accounts.models import CustomUser, MedicalRecord, GENDER_CHOICES, BLOOD_TYPE_CHOICES


class PersonalDataSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    name = serializers.CharField()
    surname = serializers.CharField()
    phone = serializers.CharField()
    age = serializers.IntegerField()
    gender = serializers.ChoiceField(choices=GENDER_CHOICES)
    passport = serializers.CharField()


class MedicalDataSerializer(serializers.Serializer):
    blood_type = serializers.ChoiceField(choices=BLOOD_TYPE_CHOICES)
    allergies = serializers.CharField()
    illness = serializers.CharField()
    additional_info = serializers.CharField(required=False, allow_blank=True)


class CustomLoginSerializer(serializers.Serializer):
    identifier = serializers.CharField()  # can be email or passport
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        identifier = data.get("identifier")
        password = data.get("password")

        try:
            user_obj = CustomUser.objects.get(
                models.Q(email=identifier) | models.Q(passport_series=identifier)
            )
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("User not found")

        # Check if user is active
        if not user_obj.is_active:
            raise serializers.ValidationError("User account is disabled")

        user = authenticate(
            request=self.context.get('request'),
            username=user_obj.email,
            password=password
        )

        if not user:
            raise serializers.ValidationError("Invalid password")

        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        refresh_token = str(refresh)

        # Build user_data
        user_data = {
            "id": user.id,
            "name": user.first_name,
            "surname": user.last_name,
            "phone": getattr(user, "phone", ""),
            "email": user.email,
            "age": user.age,
            "gender": user.gender,
            "passport": user.passport_series,
        }

        try:
            medical = user.medical_record
            user_data.update({
                "blood_type": medical.blood_type,
                "allergies": medical.allergies,
                "illness": medical.ongoing_illness,
                "additional_info": medical.additional_info,
            })
        except MedicalRecord.DoesNotExist:
            # Set empty values if no medical record exists
            user_data.update({
                "blood_type": "",
                "allergies": "",
                "illness": "",
                "additional_info": "",
            })

        return {
            "success": True,
            "access_token": access_token,
            "refresh_token": refresh_token,
            "message": "Login successful",
            "user_data": user_data,
        }


class RegisterSerializer(serializers.Serializer):
    personal = PersonalDataSerializer()
    medical = MedicalDataSerializer()

    def validate(self, data):
        # Check if email already exists
        email = data['personal']['email']
        if CustomUser.objects.filter(email=email).exists():
            raise serializers.ValidationError({"personal": {"email": "User with this email already exists."}})

        # Check if passport already exists
        passport = data['personal']['passport']
        if CustomUser.objects.filter(passport_series=passport).exists():
            raise serializers.ValidationError({"personal": {"passport": "User with this passport already exists."}})

        return data

    def create(self, validated_data):
        personal = validated_data['personal']
        medical = validated_data['medical']

        password = personal.pop('password')

        # Create user
        user = CustomUser.objects.create_user(
            email=personal['email'],
            first_name=personal['name'],
            last_name=personal['surname'],
            phone=personal['phone'],
            age=personal['age'],
            gender=personal['gender'],
            passport_series=personal['passport'],
            password=password
        )

        # Create medical record
        MedicalRecord.objects.create(
            user=user,
            blood_type=medical['blood_type'],
            allergies=medical['allergies'],
            ongoing_illness=medical['illness'],
            additional_info=medical.get('additional_info', '')
        )

        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        refresh_token = str(refresh)

        return {
            "user": user,
            "access_token": access_token,
            "refresh_token": refresh_token
        }


class FlatProfileUpdateSerializer(serializers.ModelSerializer):
    # Personal fields
    name = serializers.CharField(source='first_name', required=True)
    surname = serializers.CharField(source='last_name', required=True)
    passport = serializers.CharField(source='passport_series', required=True)
    email = serializers.EmailField(read_only=True)

    # Medical fields
    blood_type = serializers.ChoiceField(
        source='medical_record.blood_type',
        choices=BLOOD_TYPE_CHOICES,
        required=False
    )
    allergies = serializers.CharField(
        source='medical_record.allergies',
        required=False,
        allow_blank=True
    )
    illness = serializers.CharField(
        source='medical_record.ongoing_illness',
        required=False,
        allow_blank=True
    )
    additional_info = serializers.CharField(
        source='medical_record.additional_info',
        required=False,
        allow_blank=True
    )

    class Meta:
        model = CustomUser
        fields = [
            'name', 'surname', 'phone', 'age', 'gender', 'passport', 'email',
            'blood_type', 'allergies', 'illness', 'additional_info'
        ]
        read_only_fields = ['email']

    def validate_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Name is required")
        return value

    def validate_surname(self, value):
        if not value.strip():
            raise serializers.ValidationError("Surname is required")
        return value

    def validate_phone(self, value):
        if not value.strip():
            raise serializers.ValidationError("Phone is required")
        return value

    def validate_age(self, value):
        if value < 1 or value > 120:
            raise serializers.ValidationError("Invalid age (1-120)")
        return value

    def validate_passport(self, value):
        if not value.strip():
            raise serializers.ValidationError("Passport is required")

        # Check if passport already exists for another user
        if CustomUser.objects.exclude(id=self.instance.id).filter(passport_series=value).exists():
            raise serializers.ValidationError("User with this passport already exists.")

        return value

    def update(self, instance, validated_data):
        # Extract medical data
        medical_data = validated_data.pop('medical_record', {})

        # Update user instance
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Update or create medical record
        medical_record, created = MedicalRecord.objects.get_or_create(user=instance)
        for attr, value in medical_data.items():
            setattr(medical_record, attr, value)
        medical_record.save()

        return instance

from rest_framework import serializers

from accounts.models import CustomUser, MedicalRecord, GENDER_CHOICES, BLOOD_TYPE_CHOICES


class RegisterSerializer(serializers.Serializer):
    # Personal fields
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    age = serializers.IntegerField()
    gender = serializers.ChoiceField(choices=GENDER_CHOICES)
    passport_series = serializers.CharField()
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    # Medical fields
    blood_type = serializers.ChoiceField(choices=BLOOD_TYPE_CHOICES)
    allergies = serializers.CharField()
    ongoing_illness = serializers.CharField()
    additional_info = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords do not match.")
        return data

    def create(self, validated_data):
        password = validated_data.pop('password')
        validated_data.pop('confirm_password')

        # Split medical data from user data
        medical_data = {
            'blood_type': validated_data.pop('blood_type'),
            'allergies': validated_data.pop('allergies'),
            'ongoing_illness': validated_data.pop('ongoing_illness'),
            'additional_info': validated_data.pop('additional_info', ''),
        }

        # Create the user
        user = CustomUser.objects.create_user(password=password, **validated_data)

        # Create the related medical record
        MedicalRecord.objects.create(user=user, **medical_data)

        return user

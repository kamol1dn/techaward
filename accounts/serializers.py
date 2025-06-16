from rest_framework import serializers

from accounts.models import CustomUser, MedicalRecord, GENDER_CHOICES, BLOOD_TYPE_CHOICES

class PersonalDataSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    name = serializers.CharField()
    surname = serializers.CharField()
    age = serializers.IntegerField()
    gender = serializers.ChoiceField(choices=GENDER_CHOICES)
    passport = serializers.CharField()



class MedicalDataSerializer(serializers.Serializer):
    blood_type = serializers.ChoiceField(choices=BLOOD_TYPE_CHOICES)
    allergies = serializers.CharField()
    illness = serializers.CharField()
    additional_info = serializers.CharField(required=False, allow_blank=True)



class RegisterSerializer(serializers.Serializer):
    personal = PersonalDataSerializer()
    medical = MedicalDataSerializer()

    def create(self, validated_data):
        personal = validated_data['personal']
        medical = validated_data['medical']

        password = personal.pop('password')

        user = CustomUser.objects.create_user(
            email=personal['email'],
            first_name=personal['name'],
            last_name=personal['surname'],
            age=personal['age'],
            gender=personal['gender'],
            passport_series=personal['passport'],
            password=password
        )

        MedicalRecord.objects.create(
            user=user,
            blood_type=medical['blood_type'],
            allergies=medical['allergies'],
            ongoing_illness=medical['illness'],
            additional_info=medical.get('additional_info', '')
        )

        return user

from rest_framework.serializers import ModelSerializer

from accounts.models import University


class UniversitySerializer(ModelSerializer):
    class Meta:
        model = University
        fields = ['id', 'name', 'abbreviation']
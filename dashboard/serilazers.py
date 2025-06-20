from rest_framework import serializers
from EmergencyServices.models import EmergencyRequest

class EmergencyGetSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyRequest
        fields = ['type','location', 'extra_info','date_created']
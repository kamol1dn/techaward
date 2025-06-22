from rest_framework import serializers
from .models import EmergencyRequest,HELP_CHOICES
class EmergencySerializer(serializers.ModelSerializer):
    class Meta:
        model=EmergencyRequest
        fields=['type','help_for','location_info','latitude','longitude','extra_info','date_created']
        read_only_fields=['date_created']
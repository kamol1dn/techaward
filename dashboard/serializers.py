from rest_framework import serializers
from EmergencyServices.models import EmergencyRequest

class EmergencyGetSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyRequest
        fields = ['id','type','status','date_created','assigned_to','location','extra_info']
        read_only_fields = ['id','type','date_created','location','extra_info']
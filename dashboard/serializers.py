from rest_framework import serializers
from EmergencyServices.models import EmergencyRequest

class EmergencyGetSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyRequest
        fields = ['id','type','status','date_created','assigned_to','location_info','latitude','longitude','extra_info']
        write_only_fields =['assigned_to','status']
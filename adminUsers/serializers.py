from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User

class MyToken(TokenObtainPairSerializer,serializers.ModelSerializer):
    class Meta:
        model = User
        fields=['role']
    def validate(self, attrs):
        role = attrs.get('role')
        username =attrs.get('username')
        password=attrs.get('password')

        user=authenticate(username=username,password=password)
        if user is None:
            raise serializers.ValidationError('Invalid username or password.')
        if user.role !=role:
            raise serializers.ValidationError('Invalid role for this user.')



        data=super().validate(attrs)
        return data
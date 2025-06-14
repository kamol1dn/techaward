from django.contrib.auth.models import AbstractUser
from django.db import models


class University(models.Model):
    name = models.CharField(max_length=150)
    abbreviation = models.CharField(max_length=20, blank=True, null=True)

    class Meta:
        db_table = 'university'

    def __str__(self):
        return f'{self.name}'


class CustomUser(AbstractUser):
    phone_number = models.CharField(max_length=15, unique=True)
    profile_photo = models.ImageField(upload_to="accounts/", blank=True, null=True)
    email = models.EmailField(unique=True)

    def __str__(self):
        return f'{self.username}'

    class Meta:
        db_table = 'customuser'

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

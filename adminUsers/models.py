from django.db import models
from django.contrib.auth.models import AbstractUser

Role_CHOICES = [
      ('dispatcher', 'Dispatcher'),
      ('responder', 'Responder'),
]

class User(AbstractUser):
    role = models.CharField(choices=Role_CHOICES, null=True, blank=True)

    def __str__(self):
        return f'{self.role}'
    class Meta:
        db_table = 'AdminUser'
from django.db import models

class University(models.Model):
    uni=models.CharField(max_length=150)




class Users(models.Model):
    Gender=[
        (True,'Male'),
        (False,'Female'),
    ]
    full_name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    birthday= models.DateField()
    gender = models.CharField(default=False, choices=Gender)
    password = models.CharField(max_length=30)
    university = models.OneToOneField(University, on_delete=models.CASCADE)

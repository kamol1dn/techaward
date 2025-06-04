from django.db import models

#class University(models.Model):
    #uni=models.CharField(max_length=150)


class University(models.TextChoices):
    inha = 'inha', "Inha University in Tashkent",
    cau = 'cau', "Central Asian University",
    west = 'west', "Westminster International University in Tashkent",
    wuit = 'wuit', "Webster University in Tashkent",
    uzswlu = 'uzswlu', "Uzbekistan State World Languages University",
    turin = 'turin', "Turin Polytechnic University",
    amity = 'amity', "Amity University Tashkent",

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
    university = models.CharField(choices=University,blank=True,null=True)

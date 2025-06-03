from django.db import models

class Gender(models.TextChoices):
    male='male',"Male"
    female='female',"Female"
    not_specified='prefer not to say',"Prefer not to say"

class University(models.TextChoices):
      inha = 'inha',"Inha University in Tashkent",
      cau = 'cau', "Central Asian University",
      west = 'west', "Westminster International University in Tashkent",
      wut = 'wut', "Webster University in Tashkent",
      uzwlu = 'uzswlu', "Uzbekistan State World Languages University",
      turin = 'turin', "Turin Polytechnic University",
      amity = 'amity', "Amity University Tashkent",

class Users(models.Model):
    full_name = models.CharField(max_length=120)
    email = models.EmailField(unique=True)
    birthday= models.DateField()
    gender = models.BooleanField(default=False)
    password = models.CharField(max_length=120)
    university = models.CharField(choices=University.choices)

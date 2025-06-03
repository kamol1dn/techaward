from django.db import models

#University list Qogan Qilishim kere

class Users(models.Model):

    full_name = models.CharField(max_length=120)
    email = models.EmailField(unique=True)
    birthday= models.DateField()
    male = models.BooleanField(default=False, verbose_name="Male")
    female = models.BooleanField(default=False, verbose_name="Female")
    password = models.CharField(max_length=120)

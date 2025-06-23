from django.db import models

HELP_CHOICES = [
    (True, 'Me'),
    (False, 'Other Person'),
]

STATUS_CHOICES=[
    ('pending','Pending'),
    ('in_progress', 'In Progress'),
    ('resolved', 'Resolved')
]
class EmergencyRequest(models.Model):
    type=models.CharField(max_length=25)
    help_for = models.BooleanField(choices=HELP_CHOICES, default=True)
    location_info = models.CharField(max_length=255,blank=True,null=True)
    latitude=models.FloatField(default=0.0)
    longitude=models.FloatField(default=0.0)
    image=models.ImageField(upload_to='images/',null=True)
    date_created = models.DateTimeField(auto_now_add=True)
    extra_info=models.TextField(blank=True,null=True)
    status=models.CharField(max_length=20,choices=STATUS_CHOICES,default='pending')
    assigned_to=models.CharField(max_length=50)

    def __str__(self):
        return f"{self.help_for}"
    class Meta:
        db_table='EmergencyRequest'


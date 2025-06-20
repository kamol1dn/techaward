from django.db import models

HELP_CHOICES = [
    ('me', 'Me'),
    ('other', 'Other Person'),
    ('family', 'Family Member'),
]

STATUS_CHOICES=[
    ('pending','Pending'),
    ('in progress', 'In Progress'),
    ('resolved', 'resolved')
]
class EmergencyRequest(models.Model):
    type=models.CharField(max_length=25)
    help_for = models.CharField(max_length=10, choices=HELP_CHOICES)
    location = models.CharField(max_length=255)
    date_created = models.DateTimeField(auto_now_add=True)
    extra_info=models.TextField(blank=True,null=True)
    status=models.CharField(max_length=20,choices=STATUS_CHOICES,default='pending')
    assigned_to=models.CharField(max_length=50)

    def __str__(self):
        return f"{self.help_for}"
    class Meta:
        db_table='EmergencyRequest'


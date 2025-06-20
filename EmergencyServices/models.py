from django.db import models

HELP_CHOICES = [
    ('me', 'Me'),
    ('other', 'Other Person'),
    ('family', 'Family Member'),
]

class EmergencyRequest(models.Model):
    type=models.CharField(max_length=25,null=True)
    help_for = models.CharField(max_length=10, choices=HELP_CHOICES)
    location = models.CharField(max_length=255)
    date_created = models.DateTimeField(auto_now_add=True)
    extra_info=models.TextField(blank=True,null=True)

    def __str__(self):
        return f"{self.help_for}"

    class Meta:
        db_table='EmergencyRequest'


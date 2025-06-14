from django.urls import path
from services.views import HelloWorldView

urlpatterns = [
    path('hello/', view=HelloWorldView.as_view(), name='hello'),
]

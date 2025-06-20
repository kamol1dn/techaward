from django.urls import path
from .views import EmergencyRequestList
urlpatterns=[
    path('emergency',EmergencyRequestList.as_view(),name='emergency'),

]
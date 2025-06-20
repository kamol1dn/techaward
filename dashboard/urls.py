from django.urls import path
from .views import EmergencyRequestList,AssignDoctorView
urlpatterns=[
    path('emergency',EmergencyRequestList.as_view(),name='emergency'),
    path('assign/<int:pk>/', AssignDoctorView.as_view(), name='assign-doctor'),

]
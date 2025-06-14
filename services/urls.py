from django.urls import path
from rest_framework.routers import DefaultRouter

from services.views import HelloWorldView, UniversityViewSet

router = DefaultRouter()
router.register('universities', UniversityViewSet, 'universities')

urlpatterns = [
                  path('hello/', view=HelloWorldView.as_view(), name='hello'),
              ] + router.urls

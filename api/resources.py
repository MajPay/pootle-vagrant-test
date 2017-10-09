
from tastypie.resources import ModelResource
from pootle_language.models import Language

class LanguageResource(ModelResource):
    class Meta:
        queryset = Language.objects.all()
        resource_name = 'language'
        allowed_methods = ['get']
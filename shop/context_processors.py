from django.utils.translation import get_language
from django.conf import settings
def cart(request): return {"cart": request.session.get("cart", {})}
def languages(request): return {"current_language": get_language()}
def media_base(request): return {"PRODUCT_IMAGE_BASE_URL": getattr(settings,"PRODUCT_IMAGE_BASE_URL","")}
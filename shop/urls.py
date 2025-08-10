from django.urls import path
from . import views
app_name="shop"
urlpatterns = [
  path("", views.home, name="home"),
  path("catalogue/", views.product_list, name="product_list"),
  path("produit/<str:sku>/", views.product_detail, name="product_detail"),
  path("panier/", views.cart_view, name="cart"),
  path("panier/ajouter/<str:sku>/", views.cart_add, name="cart_add"),
  path("panier/supprimer/<str:sku>/", views.cart_remove, name="cart_remove"),
  path("checkout/", views.checkout, name="checkout"),
  path("commande/succes/<int:order_id>/", views.order_success, name="order_success"),
]
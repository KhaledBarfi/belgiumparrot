# bootstrap_belgiumparrot.ps1
# Génère et lance le site Django "Belgium Parrot" (FR/NL) avec SQLite et admin prêt.
# Compatible Windows PowerShell 5+ et Python 3.13.

$ErrorActionPreference = "Stop"

# Toujours travailler depuis le dossier où se trouve ce script
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $ScriptRoot

function W {
  param([string]$Path,[string]$Content)
  $full = Join-Path $ScriptRoot $Path
  $dir  = Split-Path $full
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($full, $Content, $utf8)
}

# -------------------------------
# 1) Fichiers Python / Django
# -------------------------------
W "requirements.txt" @'
Django
'@

W "manage.py" @'
#!/usr/bin/env python
import os, sys
def main():
    os.environ.setdefault("DJANGO_SETTINGS_MODULE","belgiumparrot.settings")
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)
if __name__=="__main__": main()
'@

New-Item -ItemType Directory (Join-Path $ScriptRoot "belgiumparrot") -Force | Out-Null
W "belgiumparrot/__init__.py" ''

W "belgiumparrot/settings.py" @'
from pathlib import Path
import os
BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = "dev-key"
DEBUG = True
ALLOWED_HOSTS = ["*"]

INSTALLED_APPS = [
  "django.contrib.admin","django.contrib.auth","django.contrib.contenttypes",
  "django.contrib.sessions","django.contrib.messages","django.contrib.staticfiles",
  "shop",
]

MIDDLEWARE = [
  "django.middleware.security.SecurityMiddleware",
  "django.contrib.sessions.middleware.SessionMiddleware",
  "django.middleware.locale.LocaleMiddleware",
  "django.middleware.common.CommonMiddleware",
  "django.middleware.csrf.CsrfViewMiddleware",
  "django.contrib.auth.middleware.AuthenticationMiddleware",
  "django.contrib.messages.middleware.MessageMiddleware",
  "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "belgiumparrot.urls"
TEMPLATES = [{
  "BACKEND":"django.template.backends.django.DjangoTemplates",
  "DIRS":[BASE_DIR/"templates"],
  "APP_DIRS":True,
  "OPTIONS":{"context_processors":[
    "django.template.context_processors.debug",
    "django.template.context_processors.request",
    "django.contrib.auth.context_processors.auth",
    "django.contrib.messages.context_processors.messages",
    "shop.context_processors.cart",
    "shop.context_processors.languages",
    "shop.context_processors.media_base",
  ]},
}]
WSGI_APPLICATION = "belgiumparrot.wsgi.application"

DATABASES = {"default": {"ENGINE":"django.db.backends.sqlite3","NAME":BASE_DIR/"db.sqlite3"}}

LANGUAGE_CODE = "fr"
LANGUAGES = [("fr","Français"), ("nl","Nederlands")]
TIME_ZONE = "Europe/Brussels"
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATICFILES_DIRS = [BASE_DIR/"static"]
STATIC_ROOT = BASE_DIR/"staticfiles"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"
DEFAULT_FROM_EMAIL = "no-reply@belgiumparrot.local"
ORDER_NOTIFICATION_EMAIL = "belgiumparrot@gmail.com"

PRODUCT_IMAGE_BASE_URL = os.environ.get("PRODUCT_IMAGE_BASE_URL","https://example.com/products/")
'@

W "belgiumparrot/urls.py" @'
from django.contrib import admin
from django.urls import path, include
from django.conf.urls.i18n import i18n_patterns
from django.views.i18n import set_language

urlpatterns = [path("i18n/setlang/", set_language, name="set_language")]
urlpatterns += i18n_patterns(
    path("admin/", admin.site.urls),
    path("", include("shop.urls")),
)
'@

W "belgiumparrot/wsgi.py" @'
import os
from django.core.wsgi import get_wsgi_application
os.environ.setdefault("DJANGO_SETTINGS_MODULE","belgiumparrot.settings")
application = get_wsgi_application()
'@

# -------------------------------
# 2) App shop
# -------------------------------
New-Item -ItemType Directory (Join-Path $ScriptRoot "shop") -Force | Out-Null
W "shop/__init__.py" ''

W "shop/apps.py" @'
from django.apps import AppConfig
class ShopConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "shop"
    verbose_name = "Belgium Parrot Shop"
'@

W "shop/models.py" @'
from django.db import models
from django.utils.translation import gettext_lazy as _

class Product(models.Model):
    sku = models.CharField(max_length=50, unique=True)
    name_fr = models.CharField(max_length=200)
    name_nl = models.CharField(max_length=200)
    name_en = models.CharField(max_length=200, blank=True, default="")
    description_fr = models.TextField(blank=True, default="")
    description_nl = models.TextField(blank=True, default="")
    price_eur_per_unit = models.DecimalField(max_digits=8, decimal_places=2)
    unit_label_fr = models.CharField(max_length=50, default="kg")
    unit_label_nl = models.CharField(max_length=50, default="kg")
    unit_weight_kg = models.DecimalField(max_digits=6, decimal_places=2, help_text=_("Poids par unité (kg)"))
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta: ordering = ["name_fr"]
    def __str__(self): return self.name_fr

class Order(models.Model):
    class Country(models.TextChoices):
        BE="BE","Belgique"; NL="NL","Pays-Bas"; FR="FR","France"; DE="DE","Allemagne"; OTHER="OTHER","Autre"
    created_at=models.DateTimeField(auto_now_add=True)
    updated_at=models.DateTimeField(auto_now=True)
    email=models.EmailField()
    full_name=models.CharField(max_length=200)
    address=models.CharField(max_length=300)
    postal_code=models.CharField(max_length=20)
    city=models.CharField(max_length=100)
    country=models.CharField(max_length=10, choices=Country.choices, default=Country.BE)
    phone=models.CharField(max_length=50, blank=True, default="")
    note=models.TextField(blank=True, default="")
    shipping_cost=models.DecimalField(max_digits=8, decimal_places=2, default=0)
    items_total=models.DecimalField(max_digits=10, decimal_places=2, default=0)
    grand_total=models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status=models.CharField(max_length=20, default="pending")
    def __str__(self): return f"Order #{self.id} - {self.full_name}"

class OrderItem(models.Model):
    order=models.ForeignKey(Order, related_name="items", on_delete=models.CASCADE)
    product=models.ForeignKey(Product, on_delete=models.PROTECT)
    quantity_units=models.PositiveIntegerField(default=1)
    unit_price_eur=models.DecimalField(max_digits=8, decimal_places=2)
    line_total=models.DecimalField(max_digits=10, decimal_places=2)
    def __str__(self): return f"{self.product} x {self.quantity_units}"

class ShippingRate(models.Model):
    country_code=models.CharField(max_length=10)
    min_weight=models.DecimalField(max_digits=6, decimal_places=2)
    max_weight=models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    price_eur=models.DecimalField(max_digits=6, decimal_places=2)
    note=models.CharField(max_length=200, blank=True, default="")
    class Meta: ordering = ["country_code","min_weight"]
    def __str__(self): return f"{self.country_code}: {self.min_weight}-{self.max_weight}kg = {self.price_eur}€"
'@

W "shop/admin.py" @'
from django.contrib import admin
from .models import Product, Order, OrderItem, ShippingRate

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display=("sku","name_fr","name_nl","price_eur_per_unit","unit_label_fr","unit_weight_kg","is_active")
    search_fields=("sku","name_fr","name_nl")

class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields=("product","quantity_units","unit_price_eur","line_total")

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display=("id","full_name","country","items_total","shipping_cost","grand_total","status","created_at")
    inlines=[OrderItemInline]

@admin.register(ShippingRate)
class ShippingRateAdmin(admin.ModelAdmin):
    list_display=("country_code","min_weight","max_weight","price_eur","note")
    list_filter=("country_code",)
'@

W "shop/forms.py" @'
from django import forms
from django.utils.translation import gettext_lazy as _
from .models import Order

class CheckoutForm(forms.ModelForm):
    class Meta:
        model=Order
        fields=["email","full_name","address","postal_code","city","country","phone","note"]
        labels={"email":_("Email"),"full_name":_("Nom complet"),"address":_("Adresse"),
                "postal_code":_("Code postal"),"city":_("Ville"),"country":_("Pays"),
                "phone":_("Téléphone"),"note":_("Note")}
'@

W "shop/context_processors.py" @'
from django.utils.translation import get_language
from django.conf import settings
def cart(request): return {"cart": request.session.get("cart", {})}
def languages(request): return {"current_language": get_language()}
def media_base(request): return {"PRODUCT_IMAGE_BASE_URL": getattr(settings,"PRODUCT_IMAGE_BASE_URL","")}
'@

W "shop/urls.py" @'
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
'@

W "shop/utils.py" @'
from decimal import Decimal
from .models import Product, ShippingRate

def cart_totals(cart):
    items_total=Decimal("0"); total_weight=Decimal("0"); lines=[]
    for sku, qty in cart.items():
        p=Product.objects.get(sku=sku); qty=int(qty)
        line_total=p.price_eur_per_unit*qty
        items_total+=line_total; total_weight+=p.unit_weight_kg*qty
        lines.append((p, qty, line_total))
    return items_total, total_weight, lines

def shipping_cost_for(country_code, weight):
    weight=Decimal(weight)
    rates=ShippingRate.objects.filter(country_code=country_code).order_by("min_weight")
    for r in rates:
        maxw=r.max_weight if r.max_weight is not None else Decimal("999999")
        if weight>=r.min_weight and weight<=maxw: return r.price_eur, r.note
    rates=ShippingRate.objects.filter(country_code="OTHER").order_by("min_weight")
    for r in rates:
        maxw=r.max_weight if r.max_weight is not None else Decimal("999999")
        if weight>=r.min_weight and weight<=maxw: return r.price_eur, r.note
    return Decimal("0"), "on request"
'@

W "shop/views.py" @'
from django.shortcuts import render, redirect, get_object_or_404
from .models import Product, Order, OrderItem
from .forms import CheckoutForm
from .utils import cart_totals, shipping_cost_for

def home(request): return render(request,"shop/home.html")

def product_list(request):
    prods=Product.objects.filter(is_active=True)
    return render(request,"shop/product_list.html",{"products":prods})

def product_detail(request, sku):
    p=get_object_or_404(Product, sku=sku, is_active=True)
    return render(request,"shop/product_detail.html",{"p":p})

def cart_view(request):
    cart=request.session.get("cart",{})
    items_total, total_weight, lines = cart_totals(cart)
    return render(request,"shop/cart.html",{"lines":lines,"items_total":items_total,"total_weight":total_weight})

def cart_add(request, sku):
    cart=request.session.get("cart",{})
    qty=int(request.POST.get("qty","1")); cart[sku]=cart.get(sku,0)+qty
    request.session["cart"]=cart; return redirect("shop:cart")

def cart_remove(request, sku):
    cart=request.session.get("cart",{}); cart.pop(sku,None)
    request.session["cart"]=cart; return redirect("shop:cart")

def checkout(request):
    cart=request.session.get("cart",{})
    if not cart: return redirect("shop:product_list")
    if request.method=="POST":
        form=CheckoutForm(request.POST)
        if form.is_valid():
            order=form.save()
            items_total, total_weight, lines = cart_totals(cart)
            ship_cost, note = shipping_cost_for(order.country, total_weight)
            order.items_total=items_total; order.shipping_cost=ship_cost; order.grand_total=items_total+ship_cost; order.save()
            for p,qty,line_total in lines:
                OrderItem.objects.create(order=order, product=p, quantity_units=qty, unit_price_eur=p.price_eur_per_unit, line_total=line_total)
            request.session["cart"]={}
            return redirect("shop:order_success", order_id=order.id)
    else:
        form=CheckoutForm()
    return render(request,"shop/checkout.html",{"form":form})

def order_success(request, order_id):
    return render(request,"shop/order_success.html",{"order_id":order_id})
'@

# Commande de création d'admin
New-Item -ItemType Directory (Join-Path $ScriptRoot "shop\management\commands") -Force | Out-Null
W "shop/management/__init__.py" ''
W "shop/management/commands/__init__.py" ''
W "shop/management/commands/createsu.py" @'
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
class Command(BaseCommand):
    help = "Create default admin user if not exists: admin / Admin123!"
    def handle(self, *args, **kwargs):
        User = get_user_model()
        user, created = User.objects.get_or_create(username="admin", defaults={
            "is_staff": True, "is_superuser": True, "email": "admin@example.com"
        })
        if created:
            user.set_password("Admin123!")
            user.save()
            self.stdout.write(self.style.SUCCESS("Admin created: admin / Admin123!"))
        else:
            self.stdout.write("Admin already exists (username: admin)")
'@

# -------------------------------
# 3) Templates
# -------------------------------
New-Item -ItemType Directory (Join-Path $ScriptRoot "templates\shop") -Force | Out-Null

W "templates/base.html" @'
{% load i18n %}{% load static %}
<!DOCTYPE html><html lang="{{ current_language }}"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Belgium Parrot</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="icon" href="{% static 'favicon.png' %}">
</head><body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand d-flex align-items-center gap-2" href="{% url 'shop:home' %}">
      <img src="{% static 'img/logo-placeholder.svg' %}" alt="Logo" style="height:36px"><span>Belgium Parrot</span>
    </a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" href="{% url 'shop:product_list' %}">{% trans "Catalogue" %}</a></li>
        <li class="nav-item"><a class="nav-link" href="{% url 'shop:cart' %}">{% trans "Panier" %}</a></li>
      </ul>
      <form action="/i18n/setlang/" method="post" class="d-flex ms-auto">{% csrf_token %}
        <input type="hidden" name="next" value="{{ request.path }}">
        <select name="language" class="form-select" onchange="this.form.submit()">
          <option value="fr" {% if current_language=='fr' %}selected{% endif %}>FR</option>
          <option value="nl" {% if current_language=='nl' %}selected{% endif %}>NL</option>
        </select>
      </form>
    </div>
  </div>
</nav>
<main class="container py-4">{% block content %}{% endblock %}</main>
<footer class="text-center py-4"><div>Email: belgiumparrot@gmail.com</div></footer>
</body></html>
'@

W "templates/shop/home.html" @'
{% extends 'base.html' %}{% load i18n %}
{% block content %}
<div class="p-5 mb-4 bg-white rounded-3 shadow-sm">
  <div class="container-fluid py-5">
    <h1 class="display-5 fw-bold">Belgium Parrot</h1>
    <p class="col-md-8 fs-5">{% trans "Noix et produits sélectionnés, livraison BE/NL/FR/DE." %}</p>
    <a href="{% url 'shop:product_list' %}" class="btn btn-primary btn-lg">{% trans "Voir le catalogue" %}</a>
  </div>
</div>
{% endblock %}
'@

W "templates/shop/product_list.html" @'
{% extends 'base.html' %}{% load i18n %}{% load static %}
{% block content %}
<h2 class="mb-3">{% trans "Catalogue" %}</h2>
<div class="row g-3">
{% for p in products %}
  <div class="col-md-4">
    <div class="card h-100">
      <img class="card-img-top p-3" src="{{ PRODUCT_IMAGE_BASE_URL }}{{ p.sku|lower }}.jpg"
           onerror="this.onerror=null;this.src='{% static 'img/placeholder.svg' %}';"
           alt="{{ p.name_fr }}" style="object-fit:contain; height:200px;">
      <div class="card-body">
        <h5 class="card-title">{% if current_language=='nl' %}{{ p.name_nl }}{% else %}{{ p.name_fr }}{% endif %}</h5>
        <p class="card-text">{{ p.price_eur_per_unit }} € / {% if current_language=='nl' %}{{ p.unit_label_nl }}{% else %}{{ p.unit_label_fr }}{% endif %}</p>
        <a href="{% url 'shop:product_detail' p.sku %}" class="btn btn-outline-primary">{% trans "Détails" %}</a>
      </div>
    </div>
  </div>
{% empty %}<p>{% trans "Aucun produit." %}</p>{% endfor %}
</div>
{% endblock %}
'@

W "templates/shop/product_detail.html" @'
{% extends 'base.html' %}{% load i18n %}{% load static %}
{% block content %}
<div class="row"><div class="col-md-8">
  <img class="img-fluid mb-3" src="{{ PRODUCT_IMAGE_BASE_URL }}{{ p.sku|lower }}.jpg"
       onerror="this.onerror=null;this.src='{% static 'img/placeholder.svg' %}';"
       alt="{{ p.name_fr }}" style="max-height:420px; object-fit:contain;">
  <h3>{% if current_language=='nl' %}{{ p.name_nl }}{% else %}{{ p.name_fr }}{% endif %}</h3>
  <p class="lead">{{ p.price_eur_per_unit }} € / {% if current_language=='nl' %}{{ p.unit_label_nl }}{% else %}{{ p.unit_label_fr }}{% endif %}</p>
  <form method="post" action="{% url 'shop:cart_add' p.sku %}">{% csrf_token %}
    <div class="input-group mb-3" style="max-width:280px;">
      <span class="input-group-text">{% trans "Quantité" %}</span>
      <input type="number" class="form-control" name="qty" value="1" min="1">
      <button class="btn btn-success" type="submit">{% trans "Ajouter au panier" %}</button>
    </div>
  </form>
  <p>{% if current_language=='nl' %}{{ p.description_nl|default:"" }}{% else %}{{ p.description_fr|default:"" }}{% endif %}</p>
</div></div>
{% endblock %}
'@

W "templates/shop/cart.html" @'
{% extends 'base.html' %}{% load i18n %}
{% block content %}
<h2>{% trans "Panier" %}</h2>
{% if lines %}
<table class="table"><thead><tr>
<th>{% trans "Produit" %}</th><th>{% trans "Quantité" %}</th><th>{% trans "Total" %}</th><th></th>
</tr></thead><tbody>
{% for p, qty, line_total in lines %}
<tr>
<td>{% if current_language=='nl' %}{{ p.name_nl }}{% else %}{{ p.name_fr }}{% endif %}</td>
<td>{{ qty }}</td><td>{{ line_total }} €</td>
<td><a class="btn btn-sm btn-outline-danger" href="{% url 'shop:cart_remove' p.sku %}">{% trans "Supprimer" %}</a></td>
</tr>
{% endfor %}</tbody></table>
<div class="text-end">
  <p class="fs-5">{% trans "Sous-total" %}: <strong>{{ items_total }} €</strong></p>
  <a class="btn btn-primary" href="{% url 'shop:checkout' %}">{% trans "Passer au paiement" %}</a>
</div>
{% else %}<p>{% trans "Votre panier est vide." %}</p>{% endif %}
{% endblock %}
'@

W "templates/shop/checkout.html" @'
{% extends 'base.html' %}{% load i18n %}
{% block content %}
<h2>{% trans "Validation de la commande" %}</h2>
<form method="post" class="row g-3">{% csrf_token %}
  {{ form.non_field_errors }}
  {% for field in form %}
  <div class="col-md-6"><label class="form-label">{{ field.label_tag }}</label>{{ field }}<div class="form-text text-danger">{{ field.errors }}</div></div>
  {% endfor %}
  <div class="col-12 text-end"><button class="btn btn-success">{% trans "Confirmer la commande" %}</button></div>
</form>
<p class="mt-3"><em>{% trans "Le paiement en ligne sera ajouté ultérieurement. Vous recevrez une confirmation par email." %}</em></p>
{% endblock %}
'@

W "templates/shop/order_success.html" @'
{% extends 'base.html' %}{% load i18n %}
{% block content %}
<div class="alert alert-success">{% blocktrans %}Merci ! Votre commande n° {{ order_id }} a été enregistrée.{% endblocktrans %}</div>
<a href="{% url 'shop:product_list' %}" class="btn btn-primary">{% trans "Retour au catalogue" %}</a>
{% endblock %}
'@

# -------------------------------
# 4) Fixtures produits & tarifs
# -------------------------------
New-Item -ItemType Directory (Join-Path $ScriptRoot "shop\fixtures") -Force | Out-Null
W "shop/fixtures/initial_data.json" @'
[
  {"model":"shop.product","pk":1,"fields":{"sku":"WALNUTS","name_fr":"Noix de Grenoble","name_nl":"Walnoten","name_en":"Walnuts","description_fr":"","description_nl":"","price_eur_per_unit":"15.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":2,"fields":{"sku":"PARANUTS","name_fr":"Noix du Brésil","name_nl":"Paranoten","name_en":"Paranuts","description_fr":"","description_nl":"","price_eur_per_unit":"18.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":3,"fields":{"sku":"PECAN","name_fr":"Noix de pécan","name_nl":"Pecannoten","name_en":"Pecan nuts","description_fr":"","description_nl":"","price_eur_per_unit":"18.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":4,"fields":{"sku":"HAZEL","name_fr":"Noisettes","name_nl":"Hazelnoten","name_en":"Hazelnuts","description_fr":"","description_nl":"","price_eur_per_unit":"14.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":5,"fields":{"sku":"ALMOND","name_fr":"Amandes","name_nl":"Amandelen","name_en":"Almonds","description_fr":"","description_nl":"","price_eur_per_unit":"13.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":6,"fields":{"sku":"MACA","name_fr":"Noix de macadamia","name_nl":"Macadamia noten","name_en":"Macadamia nuts","description_fr":"","description_nl":"","price_eur_per_unit":"32.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":7,"fields":{"sku":"CASHEW","name_fr":"Noix de cajou","name_nl":"Kashew noten","name_en":"Cashews","description_fr":"","description_nl":"","price_eur_per_unit":"14.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":8,"fields":{"sku":"PALM","name_fr":"Noix de palme","name_nl":"Palmnoten","name_en":"Palm nuts","description_fr":"","description_nl":"","price_eur_per_unit":"16.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":9,"fields":{"sku":"CEDAR","name_fr":"Noix de cèdre","name_nl":"Cedernoten","name_en":"Cedar nuts","description_fr":"","description_nl":"","price_eur_per_unit":"15.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":10,"fields":{"sku":"MIX_FR","name_fr":"Mix noix (grenoble, amandes, noisette, pécan)","name_nl":"Mix noten (amandelen, walnoten, pecannoten en hazelnoten)","name_en":"Mix nuts","description_fr":"","description_nl":"","price_eur_per_unit":"11.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":11,"fields":{"sku":"MACA18","name_fr":"Macadamia (sélection)","name_nl":"Macadamia (selectie)","name_en":"Macadamia (selection)","description_fr":"","description_nl":"","price_eur_per_unit":"18.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":12,"fields":{"sku":"SUGARCANE","name_fr":"Bâtons de sucre de canne","name_nl":"Suikerriet","name_en":"Sugarcane","description_fr":"","description_nl":"","price_eur_per_unit":"13.00","unit_label_fr":"kg","unit_label_nl":"kg","unit_weight_kg":"1.00","is_active":true}},
  {"model":"shop.product","pk":13,"fields":{"sku":"PALMOIL","name_fr":"Huile de palme (750ml)","name_nl":"Palmolie (750ml)","name_en":"Palm oil (750ml)","description_fr":"","description_nl":"","price_eur_per_unit":"10.00","unit_label_fr":"750ml","unit_label_nl":"750ml","unit_weight_kg":"0.75","is_active":true}},

  {"model":"shop.shippingrate","pk":1,"fields":{"country_code":"BE","min_weight":"0","max_weight":"5","price_eur":"7","note":""}},
  {"model":"shop.shippingrate","pk":2,"fields":{"country_code":"BE","min_weight":"5","max_weight":"10","price_eur":"6","note":""}},
  {"model":"shop.shippingrate","pk":3,"fields":{"country_code":"BE","min_weight":"10","max_weight":"30","price_eur":"5","note":""}},
  {"model":"shop.shippingrate","pk":4,"fields":{"country_code":"NL","min_weight":"0","max_weight":"3","price_eur":"9","note":""}},
  {"model":"shop.shippingrate","pk":5,"fields":{"country_code":"NL","min_weight":"4","max_weight":"10","price_eur":"7","note":""}},
  {"model":"shop.shippingrate","pk":6,"fields":{"country_code":"NL","min_weight":"10","max_weight":null,"price_eur":"0","note":"sur demande"}},
  {"model":"shop.shippingrate","pk":7,"fields":{"country_code":"FR","min_weight":"0","max_weight":"3","price_eur":"9","note":""}},
  {"model":"shop.shippingrate","pk":8,"fields":{"country_code":"FR","min_weight":"4","max_weight":"10","price_eur":"7","note":""}},
  {"model":"shop.shippingrate","pk":9,"fields":{"country_code":"FR","min_weight":"10","max_weight":null,"price_eur":"0","note":"sur demande"}},
  {"model":"shop.shippingrate","pk":10,"fields":{"country_code":"DE","min_weight":"0","max_weight":"3","price_eur":"9","note":""}},
  {"model":"shop.shippingrate","pk":11,"fields":{"country_code":"DE","min_weight":"4","max_weight":"10","price_eur":"7","note":""}},
  {"model":"shop.shippingrate","pk":12,"fields":{"country_code":"DE","min_weight":"10","max_weight":null,"price_eur":"0","note":"sur demande"}},
  {"model":"shop.shippingrate","pk":13,"fields":{"country_code":"OTHER","min_weight":"0","max_weight":null,"price_eur":"0","note":"sur demande"}}
]
'@

# -------------------------------
# 5) Static (logo placeholder & favicon)
# -------------------------------
New-Item -ItemType Directory (Join-Path $ScriptRoot "static\img") -Force | Out-Null
W "static/README.txt" 'Place ton logo réel ici : static/img/logo.png'

W "static/img/logo-placeholder.svg" @'
<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160"><circle cx="80" cy="80" r="78" fill="#0a7" /><text x="50%" y="54%" text-anchor="middle" font-size="18" fill="white">Belgium Parrot</text></svg>
'@

W "static/img/placeholder.svg" @'
<svg xmlns="http://www.w3.org/2000/svg" width="640" height="480"><rect width="640" height="480" fill="#f5f5f5"/><rect x="60" y="60" width="520" height="360" rx="24" fill="white" stroke="#ddd"/><text x="50%" y="50%" text-anchor="middle" font-size="20" fill="#666">Image à venir</text></svg>
'@

# favicon vide (remplace par un vrai .png si besoin)
$icoPath = Join-Path $ScriptRoot "static\favicon.png"
[IO.File]::WriteAllBytes($icoPath, [byte[]]@()) | Out-Null

# -------------------------------
# 6) README
# -------------------------------
W "README.md" @'
# Belgium Parrot (Django — FR/NL, SQLite)

## Démarrer (Windows PowerShell)
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
python manage.py loaddata shop/fixtures/initial_data.json
python manage.py createsu
# Admin : username "admin"  /  mot de passe "Admin123!"
python manage.py runserver

## Images produits via CDN (optionnel)
$env:PRODUCT_IMAGE_BASE_URL="https://cdn.tondomaine.com/products/"
'@

# -------------------------------
# 7) Environnement virtuel & lancement
# -------------------------------
Write-Host "Création de l'environnement virtuel..."
python -m venv .venv
$venvPy = Join-Path (Resolve-Path ".\.venv").Path "Scripts\python.exe"
$venvPip = Join-Path (Resolve-Path ".\.venv").Path "Scripts\pip.exe"

Write-Host "Installation de Django (compatible Python 3.13)..."
& $venvPip install --upgrade pip
& $venvPip install -r requirements.txt

Write-Host "Migrations + Fixtures + Admin..."
& $venvPy manage.py migrate
& $venvPy manage.py loaddata shop/fixtures/initial_data.json

# Commande de création admin (app shop)
New-Item -ItemType Directory (Join-Path $ScriptRoot "shop\management\commands") -Force | Out-Null
# (les fichiers de la commande ont déjà été écrits ci-dessus)

& $venvPy manage.py createsu

Write-Host "`n✅ Prêt. Admin: username=admin  password=Admin123!"
Write-Host "Démarrage du serveur (Ctrl+C pour arrêter)..."
& $venvPy manage.py runserver

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
    unit_weight_kg = models.DecimalField(max_digits=6, decimal_places=2, help_text=_("Poids par unitÃ© (kg)"))
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
    def __str__(self): return f"{self.country_code}: {self.min_weight}-{self.max_weight}kg = {self.price_eur}â‚¬"
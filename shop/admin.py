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
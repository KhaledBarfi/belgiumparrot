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
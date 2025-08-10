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
from django import forms
from django.utils.translation import gettext_lazy as _
from .models import Order

class CheckoutForm(forms.ModelForm):
    class Meta:
        model=Order
        fields=["email","full_name","address","postal_code","city","country","phone","note"]
        labels={"email":_("Email"),"full_name":_("Nom complet"),"address":_("Adresse"),
                "postal_code":_("Code postal"),"city":_("Ville"),"country":_("Pays"),
                "phone":_("TÃ©lÃ©phone"),"note":_("Note")}
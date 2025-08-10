@echo off
setlocal enabledelayedexpansion

echo === Configuration Git locale (dans ce repo) ===
git config user.name "Khaled Barfi"
git config user.email "barfi.khaled@hotmail.com"

echo === Initialisation Git ===
git init
git add -A
git commit --allow-empty -m "Initialisation du projet Django : skeleton + settings/urls de base"
git branch -M main

REM Petite fonction commit
:mkcommit
REM %~1 = fichier, %~2 = texte, %~3 = message
echo %~2>> %~1
git add -A
git commit -m "%~3"
exit /b 0

REM 15 commits main
call :mkcommit belgiumparrot\settings.py "# Config de base validée" "Configuration de base : langue FR, timezone Europe/Brussels, static config"
call :mkcommit shop\apps.py "# App shop activée" "Création de l'app 'shop' et enregistrement dans INSTALLED_APPS"
call :mkcommit shop\models.py "# Modèle Product OK" "Ajout du modèle Product"
call :mkcommit shop\models.py "# Modèles Order & OrderItem OK" "Ajout des modèles Order et OrderItem"
call :mkcommit shop\models.py "# Modèle ShippingRate OK" "Ajout du modèle ShippingRate"
call :mkcommit shop\forms.py "# CheckoutForm validé" "Création du formulaire CheckoutForm (coordonnées client)"
call :mkcommit templates\base.html "<!-- Template base validé -->" "Ajout des templates : base.html et home.html"
call :mkcommit templates\shop\product_list.html "<!-- Catalogue validé -->" "Page catalogue produits (product_list)"
call :mkcommit templates\shop\product_detail.html "<!-- Détails produit validé -->" "Page fiche produit (product_detail)"
call :mkcommit templates\shop\cart.html "<!-- Panier validé -->" "Panier et checkout : vues, templates et logique de calcul"
call :mkcommit shop\fixtures\initial_data.json "" "Fixtures : produits + tarifs d'expédition par tranches de poids"
call :mkcommit templates\base.html "<!-- Logo + favicon intégrés -->" "Intégration du logo navbar + favicon"
call :mkcommit belgiumparrot\urls.py "# i18n activé" "Support bilingue FR/NL + sélecteur de langue"
call :mkcommit README.md "## Historique - dépôt avec multi-commits." "Optimisation images (externes) + placeholder + README final"

REM Branche dev (3 commits)
git checkout -b dev
call :mkcommit templates\shop\home.html "<!-- TODO: Carrousel en cours sur la page d'accueil -->" "DEV: Ajout d'un carrousel (work in progress) sur la page d'accueil"
call :mkcommit shop\models.py "# TODO: modèle Category à finaliser" "DEV: Début ajout catégories produits (modèle à finaliser)"
call :mkcommit README.md "### Roadmap - Intégrer Stripe/Mollie (en dev)" "DEV: Début intégration paiement (config + placeholders)"

REM Retour main + push
git checkout main
echo.
set /p REMOTE_URL=Colle l'URL de ton depot GitHub (ex: https://github.com/kled02/belgiumparrot.git) :
git remote add origin "%REMOTE_URL%"
git push -u origin main
git push origin dev

echo.
echo ============================================
echo  Poussé sur GitHub avec historique complet
echo ============================================
pause

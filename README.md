# Belgium Parrot (Django ‚FR/NL, SQLite)

## Demarrer (Windows PowerShell)
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
python manage.py loaddata shop/fixtures/initial_data.json
python manage.py createsu
python manage.py runserver

## Images produits via CDN (optionnel)
$env:PRODUCT_IMAGE_BASE_URL="https://cdn.tondomaine.com/products/"
## Déploiement local (MAJ 2025-08-18)

1. Créer/activer l'environnement virtuel.
2. pip install -r requirements.txt
3. python manage.py migrate && python manage.py runserver
4. CSS additionnel chargé via static/css/custom.css.

## Scripts front (MAJ 19/08)
- static/js/app.js (bandeau)
- static/css/banner.css (style bandeau)

## Impression (MAJ 21/08/2025)
- static/css/print.css pour un rendu imprimable propre.

# Belgium Parrot (Django √¢‚Ç¨‚Äù FR/NL, SQLite)

## D√É¬©marrer (Windows PowerShell)
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
## DÈploiement local (MAJ 2025-08-18)

1. CrÈer/activer l'environnement virtuel.
2. pip install -r requirements.txt
3. python manage.py migrate && python manage.py runserver
4. CSS additionnel chargÈ via static/css/custom.css.

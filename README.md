# Belgium Parrot (Django â€” FR/NL, SQLite)

## DÃ©marrer (Windows PowerShell)
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
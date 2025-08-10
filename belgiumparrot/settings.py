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
LANGUAGES = [("fr","FranÃ§ais"), ("nl","Nederlands")]
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
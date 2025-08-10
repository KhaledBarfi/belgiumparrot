from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
class Command(BaseCommand):
    help = "Create default admin user if not exists: admin / Admin123!"
    def handle(self, *args, **kwargs):
        User = get_user_model()
        user, created = User.objects.get_or_create(username="admin", defaults={
            "is_staff": True, "is_superuser": True, "email": "admin@example.com"
        })
        if created:
            user.set_password("Admin123!")
            user.save()
            self.stdout.write(self.style.SUCCESS("Admin created: admin / Admin123!"))
        else:
            self.stdout.write("Admin already exists (username: admin)")
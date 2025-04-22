# Django Blog

A feature-rich blog application built with Django, featuring user authentication, post management with categories, comments, and modern Bootstrap UI.

## Features

- User authentication (login, logout, registration)
- Password reset functionality
- User profiles with avatars
- Blog posts with featured images
- Category management
- Comment system
- Responsive design using Bootstrap 5
- Rich text editing with CKEditor
- Clean, modern UI

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd django-blog
   ```

2. Create a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Run migrations:
   ```
   python manage.py makemigrations
   python manage.py migrate
   ```

5. Create a superuser:
   ```
   python manage.py createsuperuser
   ```

6. Start the development server:
   ```
   python manage.py runserver
   ```

7. Open your browser and navigate to `http://127.0.0.1:8000/`

## Project Structure

- `apps/` - Django applications
  - `accounts/` - User authentication and profile management
  - `blog/` - Blog functionality (posts, categories, comments)
- `config/` - Project configuration
- `static/` - Static files (CSS, JS, images)
- `templates/` - HTML templates
- `media/` - User uploaded content (not in repo)

## Development

Use the `setup.sh` script to set up templates and static files, its equivalent commands if in case setup.sh times out:

```
source django/bin/activate
pip install -r requirements.txt
python manage.py makemigrations accounts
python manage.py makemigrations blog
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput
python manage.py runserver
```

When the server starts, leave the session as is and open browser to view the example blog of http://localhost:8000/post/2025/4/22/using-florence2-model-to-create-sslv-geometry-representation/
## License

MIT License
EOF < /dev/null

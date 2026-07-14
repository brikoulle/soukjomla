# SoukJomla Backend

Django REST Framework API for B2B marketplace connecting buyers and sellers in Morocco.

## Project Structure

```
soukjomla_backend/
├── config/                  # Django project settings
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py              # Channels config with JWT WebSocket auth
│   └── storage_settings.py  # Cloud storage config
├── apps/
│   ├── chat/                # Real-time messaging
│   │   ├── models.py
│   │   ├── consumers.py     # WebSocket consumers
│   │   ├── views.py
│   │   └── urls.py
│   ├── products/            # Product management
│   │   ├── models.py        # Product & ProductImage
│   │   ├── views.py         # Image upload endpoint
│   │   ├── serializers.py
│   │   └── urls.py
│   ├── users/               # User management
│   ├── orders/              # Order management
│   └── ...
├── core/
│   └── middleware.py        # JWTAuthMiddleware for WebSocket
├── requirements.txt
├── manage.py
└── TASK_*.md                # Documentation for each task
```

## Setup

### 1. Install dependencies
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Environment configuration
```bash
cp .env.example .env
# Edit .env with your settings
```

### 3. Database migrations
```bash
python manage.py migrate
```

### 4. Create superuser
```bash
python manage.py createsuperuser
```

### 5. Run development server
```bash
python manage.py runserver
```

## API Endpoints

### Chat (Real-time WebSocket + REST)
- `GET /api/chats/` - List user's chats
- `POST /api/chats/` - Create chat
- `GET /api/chats/{id}/` - Get chat details with messages
- `POST /api/chats/create_or_get/` - Create or retrieve chat with user
- `POST /api/chats/{id}/send_message/` - Send message via REST
- `GET /api/chats/{id}/messages/` - Get paginated messages
- `WS /ws/chat/{chat_id}/?token=<jwt>` - WebSocket for real-time messages

### Products
- `GET /api/products/` - List products (paginated, filterable)
- `POST /api/products/` - Create product (auth required)
- `GET /api/products/{id}/` - Get product detail with images
- `PATCH /api/products/{id}/` - Update product (seller only)
- `DELETE /api/products/{id}/` - Delete product (seller only)
- `POST /api/products/{id}/upload_image/` - Upload product image (multipart)
- `DELETE /api/products/{id}/delete_image/?image_id={id}` - Delete image
- `POST /api/products/{id}/set_cover_image/` - Set cover image
- `GET /api/categories/` - List categories (excludes matériel de construction)

## Key Features

### Task 1: JWT WebSocket Authentication
- Custom `JWTAuthMiddleware` validates JWT from query parameters
- WebSocket URL: `ws://api/ws/chat/{chat_id}/?token=<jwt>`
- Real-time message broadcasting to participants
- Secure connection checks

### Task 2: Product Image Upload
- `POST /api/products/{id}/upload_image/` endpoint
- Multipart form data with file validation
- Max 4 images per product, 5MB each
- Automatic cover image management
- Cloud storage ready (S3, Azure via env vars)

## Environment Variables

```env
# Django
DEBUG=False
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=api.soukjomla.ma

# Database
DATABASE_URL=postgresql://user:pass@localhost/soukjomla
DB_POOL_SIZE=10

# JWT
JWT_SECRET=your-jwt-secret
JWT_ALGORITHM=HS256
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# CORS
CORS_ALLOWED_ORIGINS=https://soukjomla.ma,https://app.soukjomla.ma
CORS_ALLOW_CREDENTIALS=True

# Storage
STORAGE_BACKEND=local  # or 's3' or 'azure'
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_STORAGE_BUCKET_NAME=soukjomla-media
AWS_S3_REGION_NAME=eu-west-1

# Channels
CHANNEL_LAYERS_BACKEND=channels.layers.InMemoryChannelLayer
# For production use: channels_redis.core.RedisChannelLayer
```

## Running in Production

### Using Gunicorn + Daphne
```bash
# HTTP (gunicorn)
gunicorn config.wsgi:application --bind 0.0.0.0:8000

# WebSocket (daphne)
daphne -b 0.0.0.0 -p 8001 config.asgi:application
```

### Using Docker
```bash
docker build -t soukjomla-backend .
docker run -p 8000:8000 soukjomla-backend
```

## Testing

```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test apps.chat

# With coverage
coverage run --source='.' manage.py test
coverage report
```

## Documentation

See individual task documentation:
- `TASK_1_JWT_WEBSOCKET.md` - WebSocket authentication
- `TASK_2_PRODUCT_IMAGES.md` - Image upload system

## Security Checklist

- [ ] `DEBUG=False` in production
- [ ] `ALLOWED_HOSTS` configured
- [ ] CORS origins explicit (not `*`)
- [ ] JWT secrets strong and unique
- [ ] Database passwords not in code
- [ ] SSL/TLS enforced
- [ ] Rate limiting configured
- [ ] Input validation on all endpoints
- [ ] Error responses don't leak stack traces

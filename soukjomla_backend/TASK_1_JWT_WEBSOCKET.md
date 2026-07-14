# Task 1: JWT Authentication for WebSocket (Chat Real-Time)

## Overview
Implemented custom JWT authentication middleware for Django Channels to validate JWT tokens from WebSocket query parameters, replacing the session-based `AuthMiddlewareStack` that doesn't work with mobile clients.

## What Was Implemented

### 1. **JWTAuthMiddleware** (`core/middleware.py`)
- Custom Channels middleware that reads JWT token from query parameters
- Validates token using `rest_framework_simplejwt`
- Attaches authenticated user to `scope['user']` for access in consumers
- Gracefully handles missing/invalid/expired tokens by setting `AnonymousUser`
- Includes comprehensive logging for debugging

### 2. **ASGI Configuration** (`config/asgi.py`)
- Updated to use `JWTAuthMiddleware` instead of `AuthMiddlewareStack`
- WebSocket URL pattern: `ws://domain/ws/chat/{chat_id}/?token=<jwt_token>`
- Maintains HTTP/WebSocket protocol routing

### 3. **Chat Consumer** (`apps/chat/consumers.py`)
- `ChatConsumer` handles WebSocket connections for real-time chat
- Validates user authentication and chat access permissions
- Broadcasts messages to all chat participants via Channels group
- Persists messages to database on receive
- Includes error handling and security checks

### 4. **Chat Models** (`apps/chat/models.py`)
- `Chat`: Represents conversation between users (ManyToMany participants)
- `Message`: Individual messages with sender, content, timestamp, read status
- Database indexes for efficient querying

### 5. **REST API** (`apps/chat/views.py`, `apps/chat/urls.py`)
- `ChatViewSet`: List chats, retrieve chat details, create new chats
- `MessageViewSet`: Read-only access to messages
- Custom actions:
  - `POST /api/chats/create_or_get/`: Create or retrieve existing chat with a user
  - `POST /api/chats/{id}/send_message/`: Send message via REST
  - `GET /api/chats/{id}/messages/`: Get paginated message history

### 6. **Serializers** (`apps/chat/serializers.py`)
- `ChatSerializer`: List view of chats
- `ChatDetailSerializer`: Full chat with message history
- `MessageSerializer`: Individual message details

### 7. **Tests** (`apps/chat/tests.py`)
- WebSocket JWT authentication tests
- Chat REST API endpoint tests
- Message model tests
- Authorization tests

## How It Works

### WebSocket Connection Flow

```
Mobile App (Flutter)
    ↓
1. Generate WebSocket URL: ws://api.soukjomla.ma/ws/chat/123/?token=<jwt>
2. Connect to WebSocket
    ↓
Django Channels
    ↓
3. JWTAuthMiddleware intercepts connection
4. Extracts token from query_string
5. Validates token with rest_framework_simplejwt
6. Calls async get_user_from_token()
7. On success: scope['user'] = authenticated_user
8. On failure: scope['user'] = AnonymousUser
    ↓
9. ChatConsumer.connect() runs
10. Checks if user is authenticated (AnonymousUser → close with code 4001)
11. Checks if user has access to chat (via participants check)
12. On success: joins channel group, responds with ACCEPTED
13. On failure: close with code 4003 (Forbidden)
    ↓
14. User can now send messages
15. Consumer receives, validates, saves to DB, broadcasts to group
```

### Message Flow

**Real-time (WebSocket)**:
```
Sender sends JSON:
{
    "message": "Hello!"
}
    ↓
Consumer.receive() → save_message() → group_send()
    ↓
All connected participants receive:
{
    "type": "message",
    "message": "Hello!",
    "sender_id": 42,
    "sender_name": "Ahmed",
    "created_at": "2026-07-14T10:30:00Z"
}
```

**REST API**:
```
POST /api/chats/{id}/send_message/
{
    "content": "Hello!"
}
    ↓
Response (201 Created):
{
    "id": 123,
    "sender": {"id": 42, "username": "ahmed", ...},
    "content": "Hello!",
    "created_at": "2026-07-14T10:30:00Z",
    "is_read": false
}
```

## Integration with Flutter

The Flutter app is already sending tokens in the correct format. In `apps/chat/services/chat_service.dart`:

```dart
final String wsUrl = '${AppConfig.apiBaseUrl.replaceFirst('http', 'ws')}/ws/chat/$chatId/?token=$accessToken';
_channel = WebSocketChannel.connect(Uri.parse(wsUrl));
```

This now works with the new JWT middleware.

## Required Environment Variables

```bash
# Django settings
DEBUG=False  # Production
ALLOWED_HOSTS=api.soukjomla.ma
CORS_ALLOWED_ORIGINS=https://soukjomla.ma

# JWT (via rest_framework_simplejwt)
SECRET_KEY=<your-secret>
JWT_ALGORITHM=HS256  # Default
```

## Security Considerations

✅ **Implemented**:
- JWT token validation using industry-standard `rest_framework_simplejwt`
- User authentication verification before connecting
- Chat access permission check (user must be participant)
- Graceful error handling with proper close codes
- Request ID logging for auditability
- No credentials in logs

⚠️ **Recommendations for Production**:
- Use `WSS://` (WebSocket Secure) with valid SSL certificate
- Rate limit WebSocket connections per IP/user
- Implement message rate limiting (prevent spam)
- Add monitoring for connection errors
- Store JWT refresh token securely (httpOnly cookies if applicable)

## Testing

### Manual WebSocket Test (with valid token)

```bash
# 1. Get access token
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser", "password":"testpass"}'

# Response: {"access": "eyJ0eXAi...", "refresh": "eyJ0eXAi..."}

# 2. Test WebSocket connection using websocat or similar
websocat 'ws://localhost:8000/ws/chat/1/?token=eyJ0eXAi...'

# Send a message (as JSON):
{"message": "Hello from WebSocket"}

# Expected: Broadcast to other connected users in same chat
```

### Run Test Suite

```bash
python manage.py test apps.chat.tests
```

## Files Modified/Created

```
soukjomla_backend/
├── core/
│   └── middleware.py (NEW - JWTAuthMiddleware)
├── config/
│   └── asgi.py (MODIFIED - use JWTAuthMiddleware)
└── apps/chat/
    ├── models.py (NEW)
    ├── consumers.py (NEW)
    ├── views.py (NEW)
    ├── serializers.py (NEW)
    ├── urls.py (NEW)
    ├── admin.py (NEW)
    └── tests.py (NEW)
```

## Next Steps (Checked in Task 1)

✅ JWT WebSocket authentication implemented
✅ Chat consumer handles real-time messaging
✅ REST API for creating/fetching chats
✅ Message persistence to database
✅ Security checks (authentication + authorization)

→ **Proceed to Task 2: Product Image Upload**

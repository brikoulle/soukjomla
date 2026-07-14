"""
JWT Authentication middleware for Django Channels WebSocket connections.
Reads token from query parameters and validates against rest_framework_simplejwt.
"""

import logging
from typing import Callable, Any
from urllib.parse import parse_qs

from django.contrib.auth.models import AnonymousUser
from django.db import close_old_connections
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, AuthenticationFailed
from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware


logger = logging.getLogger(__name__)


@database_sync_to_async
def get_user_from_token(token: str):
    """
    Async function to validate JWT token and return authenticated user.
    Uses rest_framework_simplejwt's JWTAuthentication.
    """
    try:
        jwt_auth = JWTAuthentication()
        # Create a minimal request-like object for JWT validation
        from rest_framework.request import Request
        from django.http import HttpRequest
        
        http_request = HttpRequest()
        http_request.META['HTTP_AUTHORIZATION'] = f'Bearer {token}'
        request = Request(http_request)
        
        # Validate and get user
        validated_user, _ = jwt_auth.authenticate(request)
        return validated_user
    except (InvalidToken, AuthenticationFailed) as e:
        logger.warning(f"WebSocket JWT validation failed: {str(e)}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error during WebSocket JWT validation: {str(e)}")
        return None


class JWTAuthMiddleware(BaseMiddleware):
    """
    Middleware for authenticating WebSocket connections via JWT token in query params.
    
    Expected URL format: ws://domain/ws/chat/{chat_id}/?token=<jwt_token>
    
    Sets scope['user'] to authenticated user or AnonymousUser if token is invalid.
    """
    
    async def __call__(self, scope, receive, send):
        close_old_connections()
        
        # Extract token from query parameters
        query_string = scope.get('query_string', b'').decode()
        query_params = parse_qs(query_string)
        token = query_params.get('token', [None])[0]
        
        if token:
            # Validate token and get user
            user = await get_user_from_token(token)
            if user:
                scope['user'] = user
                logger.info(f"WebSocket authenticated for user {user.id}")
            else:
                scope['user'] = AnonymousUser()
                logger.warning("WebSocket authentication failed - token invalid or expired")
        else:
            scope['user'] = AnonymousUser()
            logger.debug("WebSocket connection without authentication token")
        
        await super().__call__(scope, receive, send)

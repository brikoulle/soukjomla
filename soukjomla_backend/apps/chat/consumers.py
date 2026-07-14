"""
WebSocket consumers for real-time chat functionality.
Authenticated via JWT token from URL query parameters.
"""

import json
import logging
from datetime import datetime
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth.models import AnonymousUser

from .models import Chat, Message


logger = logging.getLogger(__name__)


class ChatConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer for real-time chat.
    Expects JWT token in URL: ws://domain/ws/chat/{chat_id}/?token=<jwt>
    """
    
    async def connect(self):
        """Handle WebSocket connection."""
        self.chat_id = self.scope['url_route']['kwargs']['chat_id']
        self.user = self.scope.get('user')
        self.room_group_name = f'chat_{self.chat_id}'
        
        # Check if user is authenticated
        if isinstance(self.user, AnonymousUser):
            logger.warning(f"Unauthenticated WebSocket connection attempt to chat {self.chat_id}")
            await self.close(code=4001, reason='Unauthorized')
            return
        
        # Verify user has access to this chat
        has_access = await self.user_has_chat_access(self.user.id, self.chat_id)
        if not has_access:
            logger.warning(f"User {self.user.id} attempted unauthorized access to chat {self.chat_id}")
            await self.close(code=4003, reason='Forbidden')
            return
        
        # Join room group
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()
        logger.info(f"User {self.user.id} connected to chat {self.chat_id}")
    
    async def disconnect(self, close_code):
        """Handle WebSocket disconnection."""
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)
        logger.info(f"User {self.user.id} disconnected from chat {self.chat_id}")
    
    async def receive(self, text_data):
        """Receive message from WebSocket."""
        try:
            data = json.loads(text_data)
            message_text = data.get('message', '').strip()
            
            if not message_text:
                await self.send(text_data=json.dumps({
                    'error': 'Message cannot be empty'
                }))
                return
            
            # Save message to database
            message_obj = await self.save_message(
                self.user.id,
                self.chat_id,
                message_text
            )
            
            # Broadcast to group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': message_text,
                    'sender_id': self.user.id,
                    'sender_name': self.user.get_full_name() or self.user.username,
                    'created_at': message_obj.created_at.isoformat(),
                }
            )
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({'error': 'Invalid JSON'}))
        except Exception as e:
            logger.error(f"Error in receive: {str(e)}")
            await self.send(text_data=json.dumps({'error': 'Server error'}))
    
    async def chat_message(self, event):
        """Handle chat_message event from group."""
        await self.send(text_data=json.dumps({
            'type': 'message',
            'message': event['message'],
            'sender_id': event['sender_id'],
            'sender_name': event['sender_name'],
            'created_at': event['created_at'],
        }))
    
    @database_sync_to_async
    def user_has_chat_access(self, user_id: int, chat_id: int) -> bool:
        """Check if user is a participant in this chat."""
        try:
            chat = Chat.objects.get(id=chat_id)
            return chat.participants.filter(id=user_id).exists()
        except Chat.DoesNotExist:
            return False
    
    @database_sync_to_async
    def save_message(self, user_id: int, chat_id: int, message_text: str):
        """Save message to database."""
        return Message.objects.create(
            chat_id=chat_id,
            sender_id=user_id,
            content=message_text
        )

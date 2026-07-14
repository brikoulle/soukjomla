"""
REST API views for chat management.
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q

from .models import Chat, Message
from .serializers import ChatSerializer, ChatDetailSerializer, MessageSerializer


class ChatViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing user chats.
    Authenticated users can view and create chats.
    """
    serializer_class = ChatSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return chats for the authenticated user."""
        return Chat.objects.filter(
            participants=self.request.user
        ).prefetch_related('participants')
    
    def get_serializer_class(self):
        """Use detailed serializer for retrieve action."""
        if self.action == 'retrieve':
            return ChatDetailSerializer
        return ChatSerializer
    
    @action(detail=False, methods=['post'])
    def create_or_get(self, request):
        """
        Create a new chat or get existing chat with another user.
        
        Request body: { "user_id": <int> }
        """
        other_user_id = request.data.get('user_id')
        
        if not other_user_id:
            return Response(
                {'error': 'user_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if other_user_id == request.user.id:
            return Response(
                {'error': 'Cannot chat with yourself'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if chat already exists between these users
        chat = Chat.objects.filter(
            participants=request.user
        ).filter(
            participants__id=other_user_id
        ).first()
        
        if chat:
            serializer = ChatDetailSerializer(chat)
            return Response(serializer.data)
        
        # Create new chat
        chat = Chat.objects.create()
        chat.participants.add(request.user.id, other_user_id)
        
        serializer = ChatSerializer(chat)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'])
    def send_message(self, request, pk=None):
        """
        Send a message in a chat.
        
        Request body: { "content": "message text" }
        """
        chat = self.get_object()
        content = request.data.get('content', '').strip()
        
        if not content:
            return Response(
                {'error': 'Message content is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        message = Message.objects.create(
            chat=chat,
            sender=request.user,
            content=content
        )
        
        serializer = MessageSerializer(message)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['get'])
    def messages(self, request, pk=None):
        """Get messages for a specific chat (paginated)."""
        chat = self.get_object()
        
        # Get page number from query params (default 1)
        page = int(request.query_params.get('page', 1))
        page_size = int(request.query_params.get('page_size', 50))
        
        # Calculate offset
        offset = (page - 1) * page_size
        
        # Get messages in reverse chronological order
        messages = chat.messages.all().order_by('-created_at')[offset:offset + page_size]
        
        serializer = MessageSerializer(messages, many=True)
        return Response({
            'count': chat.messages.count(),
            'page': page,
            'page_size': page_size,
            'results': serializer.data
        })


class MessageViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ReadOnly ViewSet for messages.
    Users can view messages from their chats.
    """
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return messages from chats the user participates in."""
        return Message.objects.filter(
            chat__participants=self.request.user
        ).select_related('sender', 'chat')

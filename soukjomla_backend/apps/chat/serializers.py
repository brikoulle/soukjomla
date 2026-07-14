"""
Serializers for Chat and Message models.
"""

from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Chat, Message


class UserMinimalSerializer(serializers.ModelSerializer):
    """Minimal user info for chat participants."""
    
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name']


class MessageSerializer(serializers.ModelSerializer):
    """Serializer for individual messages."""
    sender = UserMinimalSerializer(read_only=True)
    
    class Meta:
        model = Message
        fields = ['id', 'sender', 'content', 'created_at', 'is_read']
        read_only_fields = ['id', 'sender', 'created_at']


class ChatSerializer(serializers.ModelSerializer):
    """Serializer for chat conversations."""
    participants = UserMinimalSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    
    class Meta:
        model = Chat
        fields = ['id', 'participants', 'created_at', 'updated_at', 'last_message']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_last_message(self, obj):
        """Get the last message in the chat."""
        last_msg = obj.messages.first()
        if last_msg:
            return MessageSerializer(last_msg).data
        return None


class ChatDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer for chat with message history."""
    participants = UserMinimalSerializer(many=True, read_only=True)
    messages = serializers.SerializerMethodField()
    
    class Meta:
        model = Chat
        fields = ['id', 'participants', 'created_at', 'updated_at', 'messages']
    
    def get_messages(self, obj):
        """Get paginated messages for the chat."""
        # Return last 50 messages
        messages = obj.messages.all()[:50]
        return MessageSerializer(messages, many=True).data

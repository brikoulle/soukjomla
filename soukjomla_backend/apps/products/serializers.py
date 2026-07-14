"""
Serializers for Product and ProductImage.
"""

from rest_framework import serializers
from .models import Product, ProductImage, Category


class ProductImageSerializer(serializers.ModelSerializer):
    """Serializer for product images."""
    
    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'is_cover', 'order', 'created_at']
        read_only_fields = ['id', 'created_at']


class ProductSerializer(serializers.ModelSerializer):
    """Serializer for product listing."""
    seller_name = serializers.CharField(source='seller.get_full_name', read_only=True)
    category_name = serializers.CharField(source='category.name', read_only=True)
    cover_image = serializers.SerializerMethodField()
    image_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Product
        fields = [
            'id', 'title', 'description', 'price', 'unit', 'quantity',
            'category', 'category_name', 'seller', 'seller_name',
            'status', 'created_at', 'updated_at', 'cover_image', 'image_count'
        ]
        read_only_fields = ['id', 'seller', 'created_at', 'updated_at']
    
    def get_cover_image(self, obj):
        """Get the cover image URL."""
        cover = obj.get_cover_image()
        if cover:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(cover.image.url)
            return cover.image.url
        return None
    
    def get_image_count(self, obj):
        """Count total images for this product."""
        return obj.images.count()


class ProductDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer with all images."""
    seller_name = serializers.CharField(source='seller.get_full_name', read_only=True)
    category_name = serializers.CharField(source='category.name', read_only=True)
    images = ProductImageSerializer(many=True, read_only=True)
    
    class Meta:
        model = Product
        fields = [
            'id', 'title', 'description', 'price', 'unit', 'quantity',
            'category', 'category_name', 'seller', 'seller_name',
            'status', 'created_at', 'updated_at', 'images'
        ]
        read_only_fields = ['id', 'seller', 'created_at', 'updated_at', 'images']


class ProductImageUploadSerializer(serializers.ModelSerializer):
    """Serializer for uploading images to a product."""
    
    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'order']
        read_only_fields = ['id']


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for product categories."""
    
    class Meta:
        model = Category
        fields = ['id', 'name', 'description', 'slug']

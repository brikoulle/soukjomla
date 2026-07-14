"""
ViewSets for Product and ProductImage API endpoints.
"""

from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django.shortcuts import get_object_or_404
from django.db.models import Q
from .models import Product, ProductImage, Category
from .serializers import (
    ProductSerializer,
    ProductDetailSerializer,
    ProductImageUploadSerializer,
    ProductImageSerializer,
    CategorySerializer,
)


class IsSellerOrReadOnly(permissions.BasePermission):
    """Permission: sellers can edit/delete their products, others can only read."""
    
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.seller == request.user


class ProductViewSet(viewsets.ModelViewSet):
    """
    ViewSet for product management.
    Authenticated sellers can create/edit/delete their products.
    """
    queryset = Product.objects.select_related('seller', 'category').prefetch_related('images')
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsSellerOrReadOnly]
    
    def get_serializer_class(self):
        """Use detailed serializer for retrieve action."""
        if self.action == 'retrieve':
            return ProductDetailSerializer
        return ProductSerializer
    
    def get_queryset(self):
        """Filter by status and seller if applicable."""
        queryset = Product.objects.select_related('seller', 'category').prefetch_related('images')
        
        # Filter by seller if provided
        seller_id = self.request.query_params.get('seller')
        if seller_id:
            queryset = queryset.filter(seller_id=seller_id)
        
        # Filter by category if provided
        category = self.request.query_params.get('category')
        if category:
            queryset = queryset.filter(category__slug=category)
        
        # Filter by status (anonymous users see published only)
        if not self.request.user.is_authenticated:
            queryset = queryset.filter(status='published')
        elif not self.request.user.is_staff:
            # Regular users see published products + their own products
            queryset = queryset.filter(
                Q(status='published') | Q(seller=self.request.user)
            )
        
        # Search by title or description
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) | Q(description__icontains=search)
            )
        
        return queryset
    
    def perform_create(self, serializer):
        """Set the seller to the current user."""
        serializer.save(seller=self.request.user)
    
    @action(detail=True, methods=['post'], parser_classes=(MultiPartParser, FormParser))
    def upload_image(self, request, pk=None):
        """
        Upload an image to a product.
        
        Request: multipart/form-data with 'image' file
        
        Response: Newly created ProductImage object
        """
        product = self.get_object()
        
        # Check permission
        if product.seller != request.user:
            return Response(
                {'error': 'You can only upload images to your own products'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Check image limit (max 4 per product)
        if product.images.count() >= 4:
            return Response(
                {'error': 'Maximum 4 images per product'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Validate image
        image_file = request.FILES.get('image')
        if not image_file:
            return Response(
                {'error': 'No image file provided'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check file size (max 5MB)
        if image_file.size > 5 * 1024 * 1024:
            return Response(
                {'error': 'Image size must be less than 5MB'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # If this is the first image, make it cover
        is_cover = product.images.count() == 0
        
        try:
            # Create image
            order = request.data.get('order', product.images.count())
            product_image = ProductImage.objects.create(
                product=product,
                image=image_file,
                is_cover=is_cover,
                order=order,
            )
            
            serializer = ProductImageSerializer(product_image)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        except Exception as e:
            return Response(
                {'error': f'Failed to upload image: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['delete'])
    def delete_image(self, request, pk=None):
        """
        Delete a product image.
        
        Query params: ?image_id=<int>
        """
        product = self.get_object()
        
        # Check permission
        if product.seller != request.user:
            return Response(
                {'error': 'You can only delete images from your own products'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        image_id = request.query_params.get('image_id')
        if not image_id:
            return Response(
                {'error': 'image_id query parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        image = get_object_or_404(ProductImage, id=image_id, product=product)
        image.delete()
        
        return Response(status=status.HTTP_204_NO_CONTENT)
    
    @action(detail=True, methods=['post'])
    def set_cover_image(self, request, pk=None):
        """
        Set a product image as the cover.
        
        Request body: { "image_id": <int> }
        """
        product = self.get_object()
        
        # Check permission
        if product.seller != request.user:
            return Response(
                {'error': 'You can only modify your own products'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        image_id = request.data.get('image_id')
        if not image_id:
            return Response(
                {'error': 'image_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        image = get_object_or_404(ProductImage, id=image_id, product=product)
        image.is_cover = True
        image.save()  # save() method handles unsetting other covers
        
        serializer = ProductImageSerializer(image)
        return Response(serializer.data)


class ProductImageViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ReadOnly ViewSet for product images.
    """
    queryset = ProductImage.objects.select_related('product')
    serializer_class = ProductImageSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ReadOnly ViewSet for product categories.
    """
    queryset = Category.objects.all().exclude(name='matériel de construction')
    serializer_class = CategorySerializer
    lookup_field = 'slug'

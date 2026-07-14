"""
Django admin configuration for product models.
"""

from django.contrib import admin
from .models import Product, ProductImage, Category


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug']
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ['name']


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['title', 'seller', 'category', 'price', 'quantity', 'status', 'created_at']
    list_filter = ['status', 'category', 'created_at']
    search_fields = ['title', 'description', 'seller__username']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Basic Info', {
            'fields': ('seller', 'title', 'category', 'description')
        }),
        ('Pricing & Quantity', {
            'fields': ('price', 'unit', 'quantity')
        }),
        ('Status', {
            'fields': ('status',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(ProductImage)
class ProductImageAdmin(admin.ModelAdmin):
    list_display = ['product', 'is_cover', 'order', 'created_at', 'image_preview']
    list_filter = ['is_cover', 'created_at']
    search_fields = ['product__title']
    readonly_fields = ['created_at', 'image_preview']
    
    def image_preview(self, obj):
        """Display thumbnail preview of image."""
        if obj.image:
            from django.utils.html import format_html
            return format_html(
                '<img src=\"{}\" width=\"100\" height=\"100\" />',
                obj.image.url
            )
        return '-'
    image_preview.short_description = 'Preview'

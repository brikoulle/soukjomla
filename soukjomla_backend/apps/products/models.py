"""
Product models for the marketplace.
"""

from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import User


class Category(models.Model):
    """Product categories (excludes \"matériel de construction\")."""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    slug = models.SlugField(unique=True)
    
    class Meta:
        verbose_name_plural = "categories"
    
    def __str__(self):
        return self.name


class Product(models.Model):
    """Product listing on the marketplace."""
    
    STATUS_CHOICES = [
        ('draft', _('Draft')),
        ('published', _('Published')),
        ('sold', _('Sold')),
        ('inactive', _('Inactive')),
    ]
    
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)])
    unit = models.CharField(max_length=50, default='unit', help_text=_('e.g., kg, liter, piece'))
    quantity = models.PositiveIntegerField(default=1, help_text=_('Available quantity'))
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['seller', '-created_at']),
            models.Index(fields=['category', '-created_at']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return self.title
    
    def get_cover_image(self):
        """Get the cover (first) image for this product."""
        return self.images.filter(is_cover=True).first() or self.images.first()


class ProductImage(models.Model):
    """Images for products (up to 4 per product)."""
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='products/%Y/%m/%d/', help_text=_('Product image'))
    is_cover = models.BooleanField(default=False, help_text=_('Set as product cover image'))
    order = models.PositiveIntegerField(default=0, help_text=_('Display order'))
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['order', 'created_at']
        indexes = [
            models.Index(fields=['product', 'is_cover']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['product'],
                condition=models.Q(is_cover=True),
                name='unique_cover_per_product'
            ),
        ]
    
    def __str__(self):
        return f"Image for {self.product.title}"
    
    def save(self, *args, **kwargs):
        """Ensure only one cover image per product."""
        if self.is_cover:
            # Remove cover flag from other images
            ProductImage.objects.filter(product=self.product).exclude(pk=self.pk).update(is_cover=False)
        super().save(*args, **kwargs)

"""
Flutter service for product management including image upload.
"""

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../models/product_models.dart';

class ProductService {
  final Dio _dio;
  final ImagePicker _imagePicker = ImagePicker();

  ProductService(this._dio);

  /// Get list of products with optional filters
  Future<List<Product>> getProducts({
    int? sellerId,
    String? category,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final params = {
        'page': page,
        'page_size': pageSize,
        if (sellerId != null) 'seller': sellerId,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      };

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/api/products/',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        return data.map((p) => Product.fromJson(p)).toList();
      }
      throw Exception('Failed to load products');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get product details with all images
  Future<Product> getProductDetail(int productId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/api/products/$productId/',
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      throw Exception('Product not found');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create new product
  Future<Product> createProduct(Product product) async {
    try {
      final data = {
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'unit': product.unit,
        'quantity': product.quantity,
        'category': product.categoryId,
        'status': product.status,
      };

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/products/',
        data: data,
      );

      if (response.statusCode == 201) {
        return Product.fromJson(response.data);
      }
      throw Exception('Failed to create product');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update existing product
  Future<Product> updateProduct(int productId, Product product) async {
    try {
      final data = {
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'unit': product.unit,
        'quantity': product.quantity,
        'category': product.categoryId,
        'status': product.status,
      };

      final response = await _dio.patch(
        '${AppConfig.apiBaseUrl}/api/products/$productId/',
        data: data,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      throw Exception('Failed to update product');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete product
  Future<void> deleteProduct(int productId) async {
    try {
      final response = await _dio.delete(
        '${AppConfig.apiBaseUrl}/api/products/$productId/',
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Pick image from gallery or camera
  Future<File?> pickImage({
    required ImageSource source,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload image to product
  Future<ProductImage> uploadProductImage(
    int productId,
    File imageFile, {
    int order = 0,
  }) async {
    try {
      // Validate file size (max 5MB)
      final fileSizeInBytes = await imageFile.length();
      if (fileSizeInBytes > 5 * 1024 * 1024) {
        throw Exception('Image must be less than 5MB');
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'order': order,
      });

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/products/$productId/upload_image/',
        data: formData,
      );

      if (response.statusCode == 201) {
        return ProductImage.fromJson(response.data);
      }
      throw Exception('Failed to upload image');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete product image
  Future<void> deleteProductImage(int productId, int imageId) async {
    try {
      final response = await _dio.delete(
        '${AppConfig.apiBaseUrl}/api/products/$productId/delete_image/',
        queryParameters: {'image_id': imageId},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete image');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Set product cover image
  Future<ProductImage> setCoverImage(int productId, int imageId) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/products/$productId/set_cover_image/',
        data: {'image_id': imageId},
      );

      if (response.statusCode == 200) {
        return ProductImage.fromJson(response.data);
      }
      throw Exception('Failed to set cover image');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get product categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/api/categories/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        return data.map((c) => Category.fromJson(c)).toList();
      }
      throw Exception('Failed to load categories');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to user-friendly messages
  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 400) {
          return e.response?.data['error'] ?? 'Invalid request';
        } else if (e.response?.statusCode == 403) {
          return 'You do not have permission to perform this action';
        } else if (e.response?.statusCode == 404) {
          return 'Product not found';
        }
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        return 'Network error. Please try again.';
      default:
        return 'An unexpected error occurred';
    }
  }
}

// Models
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String unit;
  final int quantity;
  final int sellerId;
  final String sellerName;
  final int? categoryId;
  final String? categoryName;
  final String status;
  final String? coverImageUrl;
  final int imageCount;
  final List<ProductImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.sellerId,
    required this.sellerName,
    this.categoryId,
    this.categoryName,
    required this.status,
    this.coverImageUrl,
    this.imageCount = 0,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      unit: json['unit'],
      quantity: json['quantity'],
      sellerId: json['seller'],
      sellerName: json['seller_name'] ?? '',
      categoryId: json['category'],
      categoryName: json['category_name'],
      status: json['status'],
      coverImageUrl: json['cover_image'],
      imageCount: json['image_count'] ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ProductImage.fromJson(img))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'price': price,
    'unit': unit,
    'quantity': quantity,
    'category': categoryId,
    'status': status,
  };
}

class ProductImage {
  final int id;
  final String imageUrl;
  final bool isCover;
  final int order;
  final DateTime createdAt;

  ProductImage({
    required this.id,
    required this.imageUrl,
    required this.isCover,
    required this.order,
    required this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      imageUrl: json['image'],
      isCover: json['is_cover'] ?? false,
      order: json['order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
    );
  }
}

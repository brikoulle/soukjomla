"""
Flutter widget for product image gallery with upload preview.
"""

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/design_system.dart';

class ProductImageGallery extends StatefulWidget {
  final List<File> selectedImages;
  final List<dynamic> uploadedImages;
  final Function(int) onRemoveImage;
  final Function(int) onSetCover;
  final bool isLoading;

  const ProductImageGallery({
    Key? key,
    required this.selectedImages,
    required this.uploadedImages,
    required this.onRemoveImage,
    required this.onSetCover,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  @override
  Widget build(BuildContext context) {
    final totalImages = widget.selectedImages.length + widget.uploadedImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صور المنتج',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primaryColor,
                    ),
              ),
              Text(
                '$totalImages/4',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        if (totalImages == 0)
          _EmptyImagePlaceholder()
        else
          _ImageGrid(
            selectedImages: widget.selectedImages,
            uploadedImages: widget.uploadedImages,
            onRemove: widget.onRemoveImage,
            onSetCover: widget.onSetCover,
            isLoading: widget.isLoading,
          ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<File> selectedImages;
  final List<dynamic> uploadedImages;
  final Function(int) onRemove;
  final Function(int) onSetCover;
  final bool isLoading;

  const _ImageGrid({
    required this.selectedImages,
    required this.uploadedImages,
    required this.onRemove,
    required this.onSetCover,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          // Local selected images (not uploaded yet)
          ...List.generate(selectedImages.length, (index) {
            return _ImageCard(
              imageProvider: FileImage(selectedImages[index]),
              imageIndex: index,
              isSelected: true,
              isCover: index == 0, // First image is cover
              onRemove: () => onRemove(index),
              onSetCover: () => onSetCover(index),
              isLoading: isLoading,
            );
          }),

          // Uploaded images from server
          ...List.generate(uploadedImages.length, (index) {
            final image = uploadedImages[index];
            final imageIndex = selectedImages.length + index;
            return _ImageCard(
              imageUrl: image['image'],
              imageIndex: imageIndex,
              isSelected: false,
              isCover: image['is_cover'] ?? false,
              onRemove: () => onRemove(index),
              onSetCover: () => onSetCover(index),
              isLoading: isLoading,
            );
          }),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String? imageUrl;
  final ImageProvider? imageProvider;
  final int imageIndex;
  final bool isSelected;
  final bool isCover;
  final VoidCallback onRemove;
  final VoidCallback onSetCover;
  final bool isLoading;

  const _ImageCard({
    this.imageUrl,
    this.imageProvider,
    required this.imageIndex,
    required this.isSelected,
    required this.isCover,
    required this.onRemove,
    required this.onSetCover,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isCover
                ? Border.all(color: DesignSystem.accentColor, width: 3)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _ImagePlaceholder(),
                    errorWidget: (context, url, error) => _ImageError(),
                  )
                : Image(
                    image: imageProvider!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        // Loading overlay
        if (isLoading)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black26,
            ),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),

        // Cover badge
        if (isCover)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: DesignSystem.accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'غلاف',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Image number
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${imageIndex + 1}/4',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Action buttons
        Positioned(
          bottom: 4,
          right: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Remove button
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 4),

              // Set cover button
              if (!isCover)
                GestureDetector(
                  onTap: onSetCover,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: DesignSystem.accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'لا توجد صور',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'اختر 1-4 صور من الأسفل',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(DesignSystem.primaryColor),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.red),
          SizedBox(height: 4),
          Text(
            'خطأ',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

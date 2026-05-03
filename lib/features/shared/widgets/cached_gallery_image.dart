import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedGalleryImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double borderRadius;

  const CachedGalleryImage({
    super.key,
    required this.imageUrl,
    this.height = 100,
    this.width = 100,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          height: height,
          width: width,
          child: const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),

        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          height: height,
          width: width,
          child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

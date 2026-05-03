import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String fallbackInitials;
  final Color fallbackColor;
  final Color textColor;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    required this.fallbackInitials,
    this.fallbackColor = const Color(0xFFC4B5FD),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Widget initialsWidget() => CircleAvatar(
      backgroundColor: fallbackColor,
      radius: radius,
      child: Text(
        fallbackInitials,
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return initialsWidget();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) =>
          CircleAvatar(radius: radius, backgroundImage: imageProvider),
      placeholder: (context, url) => initialsWidget(),
      errorWidget: (context, url, error) => initialsWidget(),
    );
  }
}

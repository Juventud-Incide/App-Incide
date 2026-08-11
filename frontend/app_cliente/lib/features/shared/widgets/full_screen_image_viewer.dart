import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageSource;

  /// Bandera para saber cómo procesar la ruta
  final bool isNetwork;

  /// Etiqueta para la animación fluida (Hero)
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageSource,
    required this.isNetwork,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Hero(
              tag: heroTag,
              child: isNetwork
                  ? CachedNetworkImage(
                      imageUrl: imageSource,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    )
                  : Image.file(File(imageSource), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

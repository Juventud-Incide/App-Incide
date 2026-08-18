import 'package:app_proveedor/features/shared/widgets/full_screen_image_viewer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_proveedor/features/provider/chat/providers/chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CachedGalleryImage extends ConsumerStatefulWidget {
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
  ConsumerState<CachedGalleryImage> createState() => _CachedGalleryImageState();
}

class _CachedGalleryImageState extends ConsumerState<CachedGalleryImage> {
  Key _imageKey = UniqueKey();

  void _forceRetry() async {
    await CachedNetworkImage.evictFromCache(widget.imageUrl);

    if (mounted) {
      setState(() {
        _imageKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(networkStreamProvider, (previous, next) {
      if (next.hasValue) {
        // connectivity_plus v6+ devuelve una lista de conexiones.
        // Si NO contiene 'none', significa que tenemos internet (Wi-Fi, Datos, etc.)
        final hasInternet = !next.value!.contains(ConnectivityResult.none);

        if (hasInternet) {
          _forceRetry();
        }
      }
    });

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              imageSource: widget.imageUrl,
              isNetwork: true,
              heroTag: widget
                  .imageUrl, // Usamos la URL como identificador único para la animación Hero
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CachedNetworkImage(
          key: _imageKey,
          imageUrl: widget.imageUrl,
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            height: widget.height,
            width: widget.width,
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),

          errorWidget: (context, url, error) => GestureDetector(
            onTap: _forceRetry,
            child: Container(
              color: Colors.grey.shade200,
              height: widget.height,
              width: widget.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: Colors.grey.shade500,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reintentar',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

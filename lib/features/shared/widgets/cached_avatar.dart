import 'package:app_incide/features/shared/widgets/full_screen_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_incide/features/provider/chat/providers/chat_provider.dart';

class CachedAvatar extends ConsumerStatefulWidget {
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
  ConsumerState<CachedAvatar> createState() => _CachedAvatarState();
}

class _CachedAvatarState extends ConsumerState<CachedAvatar> {
  Key _avatarKey = UniqueKey();

  void _forceRetry() async {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      await CachedNetworkImage.evictFromCache(widget.imageUrl!);
    }

    if (mounted) {
      setState(() {
        _avatarKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(networkStreamProvider, (previous, next) {
      if (next.hasValue) {
        final hasInternet = !next.value!.contains(ConnectivityResult.none);
        if (hasInternet &&
            widget.imageUrl != null &&
            widget.imageUrl!.isNotEmpty) {
          _forceRetry();
        }
      }
    });

    Widget initialsWidget() => GestureDetector(
      onTap: _forceRetry, // Permite recargar la foto tocando las iniciales
      child: CircleAvatar(
        backgroundColor: widget.fallbackColor,
        radius: widget.radius,
        child: Text(
          widget.fallbackInitials,
          style: TextStyle(
            color: widget.textColor,
            fontSize: widget.radius * 0.75,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return initialsWidget();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              imageSource: widget.imageUrl!,
              isNetwork: true,
              heroTag: widget.imageUrl!,
            ),
          ),
        );
      },
      child: CachedNetworkImage(
        key: _avatarKey,
        imageUrl: widget.imageUrl!,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(radius: widget.radius, backgroundImage: imageProvider),
        placeholder: (context, url) => initialsWidget(),
        errorWidget: (context, url, error) => initialsWidget(),
      ),
    );
  }
}

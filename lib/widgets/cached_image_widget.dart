import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

/// Виджет для кэширования изображений
class CachedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? imagePath;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CachedImageWidget({
    super.key,
    this.imageUrl,
    this.imagePath,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  }) : assert(imageUrl != null || imagePath != null,
             'Either imageUrl or imagePath must be provided');

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imagePath != null) {
      // Локальный файл
      image = Image.file(
        File(imagePath!),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _defaultErrorWidget();
        },
      );
    } else if (imageUrl != null) {
      // Сетевой URL
      image = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) =>
            placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _defaultErrorWidget(),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      );
    } else {
      return _defaultErrorWidget();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.error_outline, color: Colors.grey),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A reusable widget to safely display images from various sources (Network, Base64, Asset).
/// Includes loading placeholders, error handling, and rounded corners support.
class SafeImageWidget extends StatelessWidget {
  /// The image source string (URL, Base64, or Asset path)
  final String? image;

  /// Width of the image container
  final double width;

  /// Height of the image container
  final double height;

  /// Border radius for rounded corners
  final double borderRadius;

  /// How the image should be inscribed into the box
  final BoxFit fit;

  /// Optional custom fallback widget. If null, a default person icon avatar is used.
  final Widget? fallback;

  /// Background color for the fallback container
  final Color? fallbackBackgroundColor;

  /// Icon color for the default fallback
  final Color? fallbackIconColor;

  const SafeImageWidget({
    super.key,
    required this.image,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 0.0,
    this.fit = BoxFit.cover,
    this.fallback,
    this.fallbackBackgroundColor,
    this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor =
        fallbackBackgroundColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[200]!);
    final defaultIconColor =
        fallbackIconColor ?? (isDark ? Colors.grey[400]! : Colors.grey[500]!);

    // Build the fallback widget
    final fallbackWidget =
        fallback ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: defaultBgColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: Icon(
              Symbols.person,
              size: (width < height ? width : height) * 0.5,
              color: defaultIconColor,
            ),
          ),
        );

    // 1 & 2. Validate URL / Image source
    if (image == null || image!.trim().isEmpty) {
      return fallbackWidget;
    }

    final trimmedImage = image!.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildImage(
          context,
          trimmedImage,
          fallbackWidget,
          defaultBgColor,
        ),
      ),
    );
  }

  Widget _buildImage(
    BuildContext context,
    String source,
    Widget fallbackWidget,
    Color placeholderColor,
  ) {
    // 5. Check if it looks like Base64 (simple heuristic: no spaces, ends with =, or just very long continuous string often starting with /9j/ or iVBORw0KGgo)
    // A more robust check is trying to decode it.
    if (!source.startsWith('http') && !source.startsWith('assets/')) {
      // Try to parse as base64
      try {
        // Remove data URI scheme prefix if present (e.g., data:image/png;base64,)
        String base64String = source;
        if (source.contains(',')) {
          base64String = source.split(',').last;
        }

        // Basic validation before decoding
        if (base64String.length % 4 == 0 || base64String.endsWith('=')) {
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => fallbackWidget,
          );
        }
      } catch (e) {
        debugPrint('SafeImageWidget: Failed to decode base64: $e');
        // Let it fall through to error or return fallback
        return fallbackWidget;
      }
    }

    // Local Asset
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => fallbackWidget,
      );
    }

    // 6. Network Image
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => fallbackWidget,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // 3. Shimmer / Placeholder while loading
          return Container(
            width: width,
            height: height,
            color: placeholderColor,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
          );
        },
      );
    }

    // Unrecognized format
    return fallbackWidget;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_utils.dart';
import 'config/image_config.dart';
import 'image_embed_types.dart';
import 'image_menu.dart';
import 'widgets/image.dart';

class QuillEditorImageEmbedBuilder extends EmbedBuilder {
  QuillEditorImageEmbedBuilder({
    required this.config,
  });
  final QuillEditorImageEmbedConfig config;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final imageSource = standardizeImageUrl(embedContext.node.value.data);
    final ((imageSize), margin, alignment) = getElementAttributes(
      embedContext.node,
      context,
    );

    final width = imageSize.width;
    final height = imageSize.height;

    // Check if customImageBuilder is provided
    final customImageBuilder = config.customImageBuilder;
    if (customImageBuilder != null) {
      final imageContext = ImageContext(
        width: width,
        height: height,
        margin: margin,
        alignment: alignment,
      );
      final customWidget = customImageBuilder(
        imageSource,
        embedContext.readOnly,
        imageContext,
      );
      if (customWidget != null) {
        // Apply margin and alignment wrapping
        return _wrapWithMarginAndAlignment(
          child: customWidget,
          alignment: alignment,
          margin: margin,
        );
      }
    }

    // Default implementation
    final imageWidget = getImageWidgetByImageSource(
      context: context,
      imageSource,
      imageProviderBuilder: config.imageProviderBuilder,
      imageErrorWidgetBuilder: config.imageErrorWidgetBuilder,
      alignment: alignment,
      height: height,
      width: width,
    );

    return GestureDetector(
      onTap: () {
        final onImageClicked = config.onImageClicked;
        if (onImageClicked != null) {
          onImageClicked(imageSource);
          return;
        }
        showDialog(
          context: context,
          builder: (_) => ImageOptionsMenu(
            controller: embedContext.controller,
            config: config,
            imageSource: imageSource,
            imageSize: imageSize,
            readOnly: embedContext.readOnly,
            imageProvider: imageWidget.image,
          ),
        );
      },
      child: Builder(
        builder: (context) {
          if (margin != null) {
            return Padding(
              padding: EdgeInsets.all(margin),
              child: imageWidget,
            );
          }
          return imageWidget;
        },
      ),
    );
  }

  /// Helper method to wrap a widget with margin padding.
  ///
  /// This is used when [customImageBuilder] returns a non-null Widget
  /// to apply the same margin treatment as the default implementation.
  Widget _wrapWithMarginAndAlignment({
    required Widget child,
    required Alignment alignment,
    double? margin,
  }) {
    var result = child;

    if (margin != null) {
      result = Padding(
        padding: EdgeInsets.all(margin),
        child: result,
      );
    }

    return result;
  }
}

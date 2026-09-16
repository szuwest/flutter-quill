import 'package:flutter/widgets.dart'
    show
        Alignment,
        BuildContext,
        ImageErrorWidgetBuilder,
        ImageProvider,
        Widget;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart' show experimental, immutable;

/// When request picking an image, for example when the image button toolbar
/// clicked, it should be null in case the user didn't choose any image or
/// any other reasons, and it should be the image file path as string that is
/// exists in case the user picked the image successfully
///
/// by default we already have a default implementation that show a dialog
/// request the source for picking the image, from gallery, link or camera
typedef OnRequestPickImage = Future<String?> Function(
  BuildContext context,
);

/// A callback will called when inserting a image in the editor
/// it have the logic that will insert the image block using the controller
typedef OnImageInsertCallback = Future<void> Function(
  String image,
  QuillController controller,
);

/// When a new image picked this callback will called and you might want to
/// do some logic depending on your use case
typedef OnImageInsertedCallback = Future<void> Function(
  String image,
);

enum InsertImageSource {
  gallery,
  camera,
  link,
}

/// Configurations for dealing with images, on insert a image
/// on request picking a image
@immutable
class QuillToolbarImageConfig {
  const QuillToolbarImageConfig({
    this.onRequestPickImage,
    this.onImageInsertedCallback,
    this.onImageInsertCallback,
  });

  final OnRequestPickImage? onRequestPickImage;

  final OnImageInsertedCallback? onImageInsertedCallback;

  final OnImageInsertCallback? onImageInsertCallback;
}

typedef ImageEmbedBuilderWillRemoveCallback = Future<bool> Function(
  String imageUrl,
);

typedef ImageEmbedBuilderOnRemovedCallback = Future<void> Function(
  String imageUrl,
);

typedef ImageEmbedBuilderProviderBuilder = ImageProvider? Function(
  BuildContext context,
  String imageUrl,
);

typedef ImageEmbedBuilderErrorWidgetBuilder = ImageErrorWidgetBuilder;

/// Custom image builder callback type.
///
/// A callback function that receives the image URL, a read-only flag, and
/// image context. This allows users to define their own logic for rendering
/// image widgets, enabling support for custom image components with special
/// gestures, animations, or business logic.
///
/// [imageUrl] - Image URL or path (already processed by standardizeImageUrl)
/// [isReadOnly] - Whether the editor is in read-only mode
/// [imageContext] - Context object containing image dimensions, margin, and
/// alignment properties
///
/// Returns a [Widget] to replace the default implementation, or `null` to
/// fall back to the default image implementation.
///
/// Example usage:
/// ```dart
/// customImageBuilder: (imageUrl, isReadOnly, imageContext) {
///   // Return `null` to fallback to default logic
///
///   // Return a custom image widget based on the imageUrl
///   return CustomImageWidget(
///     imageUrl: imageUrl,
///     readOnly: isReadOnly,
///     width: imageContext.width,
///     height: imageContext.height,
///   );
/// },
/// ```
///
/// **Might be removed or changed in future releases.**
@experimental
typedef CustomImageEmbedBuilder = Widget? Function(
  String imageUrl,
  bool isReadOnly,
  ImageContext imageContext,
);

/// Context information passed to [CustomImageEmbedBuilder].
///
/// Contains image dimensions, margin, and alignment information parsed from
/// the embed node's element style attributes.
///
/// Example usage:
/// ```dart
/// customImageBuilder: (imageUrl, isReadOnly, imageContext) {
///   return CustomImageWidget(
///     url: imageUrl,
///     width: imageContext.width,
///     height: imageContext.height,
///     alignment: imageContext.alignment,
///   );
/// },
/// ```
@immutable
class ImageContext {
  /// Creates an [ImageContext] with the given properties.
  ///
  /// [width] and [height] are optional and represent the image dimensions
  /// parsed from element style attributes. When null, the image uses its
  /// natural size or is sized by its parent container.
  ///
  /// [margin] represents uniform margin around the image. When null, no
  /// margin is applied.
  ///
  /// [alignment] defaults to [Alignment.center] when not specified in the
  /// element attributes.
  const ImageContext({
    this.width,
    this.height,
    this.margin,
    this.alignment = Alignment.center,
  });

  /// Image width parsed from element style attributes.
  ///
  /// When null, the image uses its natural width or is sized by its parent
  /// container.
  final double? width;

  /// Image height parsed from element style attributes.
  ///
  /// When null, the image uses its natural height or is sized by its parent
  /// container.
  final double? height;

  /// Uniform margin around the image parsed from element style attributes.
  ///
  /// When null, no margin is applied.
  final double? margin;

  /// Horizontal alignment of the image parsed from element style attributes.
  ///
  /// Defaults to [Alignment.center] when not specified in element attributes.
  final Alignment alignment;
}

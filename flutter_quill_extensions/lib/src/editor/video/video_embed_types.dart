import 'package:flutter/widgets.dart' show Alignment, Widget;
import 'package:meta/meta.dart' show experimental, immutable;

/// Callback invoked before a video is removed from the editor.
///
/// [videoUrl] The URL or path of the video being removed.
///
/// Return `true` to allow the video removal, or `false` to prevent it.
///
/// Example usage:
/// ```dart
/// shouldRemoveVideoCallback: (videoUrl) async {
///   // Show a confirmation dialog before removing the video
///   final shouldRemove = await showDialog<bool>(
///     context: context,
///     builder: (context) => AlertDialog(
///       title: const Text('Delete Video'),
///       content: const Text('Are you sure you want to delete this video?'),
///       actions: [
///         TextButton(
///           onPressed: () => Navigator.pop(context, false),
///           child: const Text('Cancel'),
///         ),
///         TextButton(
///           onPressed: () => Navigator.pop(context, true),
///           child: const Text('Delete'),
///         ),
///       ],
///     ),
///   );
///   return shouldRemove ?? false;
/// }
/// ```
typedef VideoEmbedBuilderWillRemoveCallback = Future<bool> Function(
  String videoUrl,
);

/// Callback invoked after a video has been removed from the editor.
///
/// [videoUrl] The URL or path of the video that was removed.
///
/// Use this callback to clean up resources associated with the video,
/// such as deleting local video files.
///
/// Example usage:
/// ```dart
/// onVideoRemovedCallback: (videoUrl) async {
///   // Delete the video file from local storage
///   await MediaFileUtils.deleteVideoFile(videoUrl);
/// }
/// ```
typedef VideoEmbedBuilderOnRemovedCallback = Future<void> Function(
  String videoUrl,
);

/// Custom video builder callback type.
///
/// A callback function that receives the video URL, a read-only flag, and
/// video context. This allows users to define their own logic for rendering
/// video widgets, enabling support for various video platforms (e.g., YouTube)
/// or custom video players with special controls.
///
/// [videoUrl] - Video URL or path
/// [isReadOnly] - Whether the editor is in read-only mode
/// [videoContext] - Context object containing video dimensions, margin,
/// alignment, and document offset for deletion operations
///
/// Returns a [Widget] to replace the default implementation, or `null` to
/// fall back to the default video implementation.
///
/// Example usage:
/// ```dart
/// customVideoBuilder: (videoUrl, isReadOnly, videoContext) {
///   // Return `null` to fallback to default logic
///
///   // Return a custom video widget
///   return Stack(
///     children: [
///       MyVideoPlayer(url: videoUrl),
///       if (!isReadOnly)
///         IconButton(
///           icon: const Icon(Icons.delete),
///           onPressed: () async {
///             await MediaFileUtils.removeEmbedFromDocument(
///               controller: controller,
///               offset: videoContext.offset,
///               fileUrl: videoUrl,
///             );
///           },
///         ),
///     ],
///   );
/// },
/// ```
///
/// **Might be removed or changed in future releases.**
@experimental
typedef CustomVideoEmbedBuilder = Widget? Function(
  String videoUrl,
  bool isReadOnly,
  VideoContext videoContext,
);

/// Context information passed to [CustomVideoEmbedBuilder].
///
/// Contains video dimensions, margin, alignment, and document offset
/// information parsed from the embed node's element style attributes.
///
/// Example usage:
/// ```dart
/// customVideoBuilder: (videoUrl, isReadOnly, videoContext) {
///   return MyVideoPlayer(
///     url: videoUrl,
///     width: videoContext.width,
///     height: videoContext.height,
///     onDelete: () {
///       // Use offset to remove the embed from document
///       controller.replaceText(
///         videoContext.offset,
///         1,
///         '',
///         TextSelection.collapsed(offset: videoContext.offset),
///       );
///       // Then clean up the local file
///       MediaFileUtils.deleteVideoFile(videoUrl);
///     },
///   );
/// },
/// ```
@immutable
class VideoContext {
  /// Creates a [VideoContext] with the given properties.
  ///
  /// [offset] is required and represents the position of this embed node
  /// in the document, useful for deletion operations.
  ///
  /// [width] and [height] are optional and represent the video dimensions
  /// parsed from element style attributes. When null, the video uses default
  /// sizing or is sized by its parent container.
  ///
  /// [margin] represents uniform margin around the video. When null, no
  /// margin is applied.
  ///
  /// [alignment] defaults to [Alignment.center] when not specified in the
  /// element attributes.
  const VideoContext({
    required this.offset,
    this.width,
    this.height,
    this.margin,
    this.alignment = Alignment.center,
  });

  /// The offset (position) of this embed node in the document.
  ///
  /// This is useful for deletion operations. To remove this video from the
  /// document, use:
  /// ```dart
  /// controller.replaceText(
  ///   videoContext.offset,
  ///   1,
  ///   '',
  ///   TextSelection.collapsed(offset: videoContext.offset),
  /// );
  /// ```
  final int offset;

  /// Video width parsed from element style attributes.
  ///
  /// When null, the video uses default width or is sized by its parent
  /// container.
  final double? width;

  /// Video height parsed from element style attributes.
  ///
  /// When null, the video uses default height or is sized by its parent
  /// container.
  final double? height;

  /// Uniform margin around the video parsed from element style attributes.
  ///
  /// When null, no margin is applied.
  final double? margin;

  /// Horizontal alignment of the video parsed from element style attributes.
  ///
  /// Defaults to [Alignment.center] when not specified in element attributes.
  final Alignment alignment;
}

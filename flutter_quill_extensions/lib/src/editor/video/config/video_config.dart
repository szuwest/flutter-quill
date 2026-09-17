import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:flutter_quill/internal.dart';

import '../video_embed_types.dart';

@immutable
class QuillEditorVideoEmbedConfig {
  const QuillEditorVideoEmbedConfig({
    VideoEmbedBuilderOnRemovedCallback? onVideoRemovedCallback,
    this.shouldRemoveVideoCallback,
    this.onVideoInit,
    this.customVideoBuilder,
  }) : _onVideoRemovedCallback = onVideoRemovedCallback;

  /// [onVideoRemovedCallback] is called when a video is removed from the editor.
  ///
  /// By default, [onVideoRemovedCallback] deletes the temporary video file if
  /// the platform is mobile and if it still exists. You can customize this
  /// behavior by passing your own function that handles the removal process.
  ///
  /// Example of [onVideoRemovedCallback] customization:
  /// ```dart
  /// onVideoRemovedCallback: (videoUrl) async {
  ///   // Your custom logic here
  ///   // or leave it empty to do nothing
  /// }
  /// ```
  ///
  /// Default value if the passed value is null:
  /// [QuillEditorVideoEmbedConfig.defaultOnVideoRemovedCallback]
  ///
  /// If you want to do nothing, make sure to pass an empty callback
  /// instead of passing null as value.
  final VideoEmbedBuilderOnRemovedCallback? _onVideoRemovedCallback;

  VideoEmbedBuilderOnRemovedCallback get onVideoRemovedCallback {
    return _onVideoRemovedCallback ??
        QuillEditorVideoEmbedConfig.defaultOnVideoRemovedCallback;
  }

  /// [shouldRemoveVideoCallback] is a callback function that is invoked when
  /// the user attempts to remove a video from the editor. It allows you to
  /// control whether the video should be removed based on your custom logic.
  ///
  /// Example of [shouldRemoveVideoCallback] customization:
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
  final VideoEmbedBuilderWillRemoveCallback? shouldRemoveVideoCallback;

  /// [onVideoInit] is a callback function that gets triggered when
  ///  a video is initialized.
  /// You can use this to perform actions or setup configurations related
  ///  to video embedding.
  ///
  ///
  /// Example usage:
  /// ```dart
  ///   onVideoInit: (videoContainerKey) {
  ///     // Custom video initialization logic
  ///   },
  ///   // Customize other callback functions as needed
  /// ```
  final void Function(GlobalKey videoContainerKey)? onVideoInit;

  /// [customVideoBuilder] is a callback function that receives the video URL,
  /// a read-only flag, and video context. This allows users to define their
  /// own logic for rendering video widgets, enabling support for various video
  /// platforms (e.g., YouTube) or custom video players with special controls.
  ///
  /// Example usage:
  /// ```dart
  ///   customVideoBuilder: (videoUrl, readOnly, videoContext) {
  ///     // Return `null` to fallback to default logic of QuillEditorVideoEmbedBuilder
  ///
  ///     // Return a custom video widget based on the videoUrl
  ///     return Stack(
  ///       children: [
  ///         MyVideoPlayer(url: videoUrl),
  ///         if (!readOnly)
  ///           IconButton(
  ///             icon: const Icon(Icons.delete),
  ///             onPressed: () async {
  ///               await MediaFileUtils.removeEmbedFromDocument(
  ///                 controller: controller,
  ///                 offset: videoContext.offset,
  ///                 fileUrl: videoUrl,
  ///               );
  ///             },
  ///           ),
  ///       ],
  ///     );
  ///   },
  /// ```
  ///
  /// It's a quick solution as response to https://github.com/singerdmx/flutter-quill/issues/2284
  ///
  /// **Might be removed or changed in future releases.**
  final CustomVideoEmbedBuilder? customVideoBuilder;

  /// Default callback for handling video file cleanup after removal.
  ///
  /// This follows the same platform-specific logic as image removal:
  /// - On Web: Does nothing (files are managed by the browser).
  /// - On Desktop: Does nothing to avoid deleting user's original files.
  /// - On Mobile: Deletes the temporary video file if it exists.
  static VideoEmbedBuilderOnRemovedCallback get defaultOnVideoRemovedCallback {
    return (videoUrl) async {
      if (kIsWeb) {
        return;
      }

      // Only delete files on mobile platforms where the OS provides copies
      // of picked media in the app's temporary directory.
      if (!isMobileApp) {
        return;
      }

      final videoFile = File(videoUrl);
      final exists = await videoFile.exists();
      if (exists) {
        await videoFile.delete();
      }
    };
  }

  QuillEditorVideoEmbedConfig copyWith({
    VideoEmbedBuilderOnRemovedCallback? onVideoRemovedCallback,
    VideoEmbedBuilderWillRemoveCallback? shouldRemoveVideoCallback,
    void Function(GlobalKey videoContainerKey)? onVideoInit,
    CustomVideoEmbedBuilder? customVideoBuilder,
  }) {
    return QuillEditorVideoEmbedConfig(
      onVideoRemovedCallback: onVideoRemovedCallback ?? _onVideoRemovedCallback,
      shouldRemoveVideoCallback:
          shouldRemoveVideoCallback ?? this.shouldRemoveVideoCallback,
      onVideoInit: onVideoInit ?? this.onVideoInit,
      customVideoBuilder: customVideoBuilder ?? this.customVideoBuilder,
    );
  }
}

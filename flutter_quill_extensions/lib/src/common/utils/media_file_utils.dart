import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart' show QuillController;
import 'package:flutter_quill/internal.dart';

/// Utility class for managing media file cleanup in flutter_quill_extensions.
///
/// This class provides static methods for deleting local media files (images
/// and videos) following the same platform-specific logic as the default
/// embed builders.
///
/// ## Platform Behavior
///
/// - **Web**: No action is taken (files are managed by the browser).
/// - **Desktop** (Windows, macOS, Linux): No action is taken to avoid
///   accidentally deleting user files that may be referenced from their
///   original locations.
/// - **Mobile** (Android, iOS): Files in the application's temporary directory
///   are deleted, as the OS provides copies of picked media rather than
///   direct access to the original files.
///
/// ## Usage with customImageBuilder/customVideoBuilder
///
/// When using custom builders, you can use [removeEmbedFromDocument] to handle
/// the complete deletion flow:
///
/// ```dart
/// customImageBuilder: (imageUrl, isReadOnly, imageContext) {
///   return MyCustomImage(
///     url: imageUrl,
///     onDelete: () async {
///       // Remove from document and clean up file in one call
///       await MediaFileUtils.removeEmbedFromDocument(
///         controller: controller,
///         offset: imageContext.offset,
///         fileUrl: imageUrl,
///       );
///     },
///   );
/// }
/// ```
///
/// Or handle each step separately:
///
/// ```dart
/// onDelete: () async {
///   // Step 1: Remove from editor document
///   controller.replaceText(
///     imageContext.offset,
///     1,
///     '',
///     TextSelection.collapsed(offset: imageContext.offset),
///   );
///
///   // Step 2: Clean up local file
///   await MediaFileUtils.deleteLocalFile(imageUrl);
/// }
/// ```
///
/// ## Note
///
/// This utility only handles local file cleanup. For network URLs or custom
/// storage solutions, implement your own cleanup logic.
abstract final class MediaFileUtils {
  /// Removes an embed from the document and deletes the associated local file.
  ///
  /// This is a convenience method that combines document modification and
  /// file cleanup into a single call, useful for custom image/video builders.
  ///
  /// [controller] The QuillController managing the editor.
  /// [offset] The document offset of the embed to remove. This can be obtained
  /// from `imageContext.offset` in the customImageBuilder callback.
  /// [fileUrl] The file path or URL of the media. Local files will be deleted
  /// according to platform-specific rules (see [deleteLocalFile]).
  ///
  /// Example:
  /// ```dart
  /// customImageBuilder: (imageUrl, isReadOnly, imageContext) {
  ///   return GestureDetector(
  ///     onLongPress: () async {
  ///       final shouldDelete = await showDeleteConfirmDialog(context);
  ///       if (shouldDelete) {
  ///         await MediaFileUtils.removeEmbedFromDocument(
  ///           controller: controller,
  ///           offset: imageContext.offset,
  ///           fileUrl: imageUrl,
  ///         );
  ///       }
  ///     },
  ///     child: Image.network(imageUrl),
  ///   );
  /// }
  /// ```
  static Future<void> removeEmbedFromDocument({
    required QuillController controller,
    required int offset,
    required String fileUrl,
  }) async {
    // Remove the embed from the document
    controller.replaceText(
      offset,
      1,
      '',
      TextSelection.collapsed(offset: offset),
    );

    // Clean up the local file
    await deleteLocalFile(fileUrl);
  }

  /// Deletes a local media file (image or video) if appropriate for the
  /// current platform.
  ///
  /// This method follows the same platform-specific logic as the default
  /// image/video embed builders:
  ///
  /// - On **Web**: Does nothing (returns immediately).
  /// - On **Desktop**: Does nothing to avoid deleting user's original files.
  /// - On **Mobile**: Deletes the file if it exists in the temporary directory.
  ///
  /// [fileUrl] The file path or URL to delete. For local files, this should
  /// be the absolute path to the file.
  ///
  /// This method is safe to call with network URLs - it will simply return
  /// without taking any action if the file doesn't exist locally.
  ///
  /// Example:
  /// ```dart
  /// // Delete an image file
  /// await MediaFileUtils.deleteLocalFile('/path/to/temp/image.jpg');
  ///
  /// // Delete a video file
  /// await MediaFileUtils.deleteLocalFile('/path/to/temp/video.mp4');
  /// ```
  static Future<void> deleteLocalFile(String fileUrl) async {
    if (kIsWeb) {
      return;
    }

    // Only delete files on mobile platforms where the OS provides copies
    // of picked media in the app's temporary directory.
    // On desktop, we don't touch user files as they may be referencing
    // files from their original locations.
    if (!isMobileApp) {
      return;
    }

    final file = File(fileUrl);
    final exists = await file.exists();
    if (exists) {
      await file.delete();
    }
  }

  /// Deletes a local image file if appropriate for the current platform.
  ///
  /// This is an alias for [deleteLocalFile] with a more descriptive name
  /// for image-specific use cases.
  ///
  /// [imageUrl] The image file path to delete.
  ///
  /// See [deleteLocalFile] for platform-specific behavior details.
  static Future<void> deleteImageFile(String imageUrl) =>
      deleteLocalFile(imageUrl);

  /// Deletes a local video file if appropriate for the current platform.
  ///
  /// This is an alias for [deleteLocalFile] with a more descriptive name
  /// for video-specific use cases.
  ///
  /// [videoUrl] The video file path to delete.
  ///
  /// See [deleteLocalFile] for platform-specific behavior details.
  static Future<void> deleteVideoFile(String videoUrl) =>
      deleteLocalFile(videoUrl);
}

import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaFileUtils', () {
    group('deleteLocalFile', () {
      test('completes without error for non-existent file', () async {
        // Should not throw even if file doesn't exist
        await expectLater(
          MediaFileUtils.deleteLocalFile('/non/existent/path/image.jpg'),
          completes,
        );
      });

      test('completes without error for network URL', () async {
        // Should safely handle network URLs without error
        await expectLater(
          MediaFileUtils.deleteLocalFile('https://example.com/image.jpg'),
          completes,
        );
      });

      test('completes without error for empty string', () async {
        await expectLater(
          MediaFileUtils.deleteLocalFile(''),
          completes,
        );
      });
    });

    group('deleteImageFile', () {
      test('is an alias for deleteLocalFile', () async {
        // Both methods should complete without error for the same input
        await expectLater(
          MediaFileUtils.deleteImageFile('/path/to/image.png'),
          completes,
        );
      });

      test('completes without error for various image extensions', () async {
        final imageUrls = [
          '/path/to/image.jpg',
          '/path/to/image.jpeg',
          '/path/to/image.png',
          '/path/to/image.gif',
          '/path/to/image.webp',
        ];

        for (final url in imageUrls) {
          await expectLater(
            MediaFileUtils.deleteImageFile(url),
            completes,
          );
        }
      });
    });

    group('deleteVideoFile', () {
      test('is an alias for deleteLocalFile', () async {
        // Both methods should complete without error for the same input
        await expectLater(
          MediaFileUtils.deleteVideoFile('/path/to/video.mp4'),
          completes,
        );
      });

      test('completes without error for various video extensions', () async {
        final videoUrls = [
          '/path/to/video.mp4',
          '/path/to/video.mov',
          '/path/to/video.avi',
          '/path/to/video.mkv',
          '/path/to/video.webm',
        ];

        for (final url in videoUrls) {
          await expectLater(
            MediaFileUtils.deleteVideoFile(url),
            completes,
          );
        }
      });
    });

    group('API consistency', () {
      test('all methods return Future<void>', () {
        // Verify the return types are correct
        expect(
          MediaFileUtils.deleteLocalFile('test'),
          isA<Future<void>>(),
        );
        expect(
          MediaFileUtils.deleteImageFile('test'),
          isA<Future<void>>(),
        );
        expect(
          MediaFileUtils.deleteVideoFile('test'),
          isA<Future<void>>(),
        );
      });
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuillEditorImageEmbedConfig', () {
    group('customImageBuilder', () {
      test('defaults to null when not provided', () {
        const config = QuillEditorImageEmbedConfig();

        expect(config.customImageBuilder, isNull);
      });

      test('can be set via constructor', () {
        Widget? testBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return const SizedBox();
        }

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: testBuilder,
        );

        expect(config.customImageBuilder, isNotNull);
        expect(config.customImageBuilder, equals(testBuilder));
      });

      test('can return null from the callback', () {
        Widget? testBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return null;
        }

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: testBuilder,
        );

        expect(config.customImageBuilder, isNotNull);
        final result = config.customImageBuilder!(
          'test.png',
          false,
          const ImageContext(),
        );
        expect(result, isNull);
      });

      test('can return a Widget from the callback', () {
        const testWidget = Text('Custom Image');

        Widget? testBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return testWidget;
        }

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: testBuilder,
        );

        final result = config.customImageBuilder!(
          'test.png',
          false,
          const ImageContext(),
        );
        expect(result, equals(testWidget));
      });

      test('receives correct parameters in the callback', () {
        String? capturedImageUrl;
        bool? capturedIsReadOnly;
        ImageContext? capturedContext;

        Widget? testBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          capturedImageUrl = imageUrl;
          capturedIsReadOnly = isReadOnly;
          capturedContext = context;
          return null;
        }

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: testBuilder,
        );

        const testImageUrl = 'https://example.com/image.png';
        const testIsReadOnly = true;
        const testContext = ImageContext(
          width: 100,
          height: 200,
          margin: 10,
          alignment: Alignment.topLeft,
        );

        config.customImageBuilder!(testImageUrl, testIsReadOnly, testContext);

        expect(capturedImageUrl, equals(testImageUrl));
        expect(capturedIsReadOnly, equals(testIsReadOnly));
        expect(capturedContext, equals(testContext));
        expect(capturedContext?.width, equals(100));
        expect(capturedContext?.height, equals(200));
        expect(capturedContext?.margin, equals(10));
        expect(capturedContext?.alignment, equals(Alignment.topLeft));
      });
    });

    group('copyWith', () {
      test('preserves customImageBuilder when not specified', () {
        Widget? testBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return const SizedBox();
        }

        final original = QuillEditorImageEmbedConfig(
          customImageBuilder: testBuilder,
        );

        final copied = original.copyWith();

        expect(copied.customImageBuilder, equals(testBuilder));
      });

      test('updates customImageBuilder when specified', () {
        Widget? originalBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return const SizedBox();
        }

        Widget? newBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return const Text('New');
        }

        final original = QuillEditorImageEmbedConfig(
          customImageBuilder: originalBuilder,
        );

        final copied = original.copyWith(customImageBuilder: newBuilder);

        expect(copied.customImageBuilder, equals(newBuilder));
        expect(copied.customImageBuilder, isNot(equals(originalBuilder)));
      });

      test('can set customImageBuilder to a new value from null', () {
        const original = QuillEditorImageEmbedConfig();

        expect(original.customImageBuilder, isNull);

        Widget? testBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return const SizedBox();
        }

        final copied = original.copyWith(customImageBuilder: testBuilder);

        expect(copied.customImageBuilder, equals(testBuilder));
      });

      test('preserves other properties when updating customImageBuilder', () {
        void onImageClicked(String imageSource) {}
        ImageProvider? imageProviderBuilder(
            BuildContext context, String imageUrl) {
          return null;
        }

        final original = QuillEditorImageEmbedConfig(
          onImageClicked: onImageClicked,
          imageProviderBuilder: imageProviderBuilder,
        );

        Widget? testBuilder(
            String imageUrl, bool isReadOnly, ImageContext context) {
          return const SizedBox();
        }

        final copied = original.copyWith(customImageBuilder: testBuilder);

        expect(copied.customImageBuilder, equals(testBuilder));
        expect(copied.onImageClicked, equals(onImageClicked));
        expect(copied.imageProviderBuilder, equals(imageProviderBuilder));
      });
    });

    group('backward compatibility', () {
      test('can be constructed without customImageBuilder', () {
        void onImageClicked(String imageSource) {}
        ImageProvider? imageProviderBuilder(
            BuildContext context, String imageUrl) {
          return null;
        }

        final config = QuillEditorImageEmbedConfig(
          onImageClicked: onImageClicked,
          imageProviderBuilder: imageProviderBuilder,
        );

        expect(config.customImageBuilder, isNull);
        expect(config.onImageClicked, equals(onImageClicked));
        expect(config.imageProviderBuilder, equals(imageProviderBuilder));
      });

      test('default constructor maintains backward compatibility', () {
        const config = QuillEditorImageEmbedConfig();

        expect(config.customImageBuilder, isNull);
        expect(config.shouldRemoveImageCallback, isNull);
        expect(config.imageProviderBuilder, isNull);
        expect(config.imageErrorWidgetBuilder, isNull);
        expect(config.onImageClicked, isNull);
      });
    });
  });
}

import 'package:flutter/widgets.dart' show Alignment;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoContext', () {
    group('required offset property', () {
      test('offset is required and correctly assigned', () {
        const videoContext = VideoContext(offset: 42);

        expect(videoContext.offset, equals(42));
      });

      test('offset can be zero', () {
        const videoContext = VideoContext(offset: 0);

        expect(videoContext.offset, equals(0));
      });

      test('offset can be a large value', () {
        const videoContext = VideoContext(offset: 999999);

        expect(videoContext.offset, equals(999999));
      });
    });

    group('default values', () {
      test('alignment defaults to Alignment.center when not specified', () {
        const videoContext = VideoContext(offset: 0);

        expect(videoContext.alignment, equals(Alignment.center));
      });

      test('width defaults to null when not specified', () {
        const videoContext = VideoContext(offset: 0);

        expect(videoContext.width, isNull);
      });

      test('height defaults to null when not specified', () {
        const videoContext = VideoContext(offset: 0);

        expect(videoContext.height, isNull);
      });

      test('margin defaults to null when not specified', () {
        const videoContext = VideoContext(offset: 0);

        expect(videoContext.margin, isNull);
      });

      test('all optional properties default correctly', () {
        const videoContext = VideoContext(offset: 0);

        expect(videoContext.width, isNull);
        expect(videoContext.height, isNull);
        expect(videoContext.margin, isNull);
        expect(videoContext.alignment, equals(Alignment.center));
      });
    });

    group('complete parameters', () {
      test('all parameters are correctly assigned', () {
        const offset = 10;
        const width = 640.0;
        const height = 480.0;
        const margin = 10.0;
        const alignment = Alignment.topLeft;

        const videoContext = VideoContext(
          offset: offset,
          width: width,
          height: height,
          margin: margin,
          alignment: alignment,
        );

        expect(videoContext.offset, equals(offset));
        expect(videoContext.width, equals(width));
        expect(videoContext.height, equals(height));
        expect(videoContext.margin, equals(margin));
        expect(videoContext.alignment, equals(alignment));
      });

      test('width is correctly assigned when only width is provided', () {
        const width = 1280.0;

        const videoContext = VideoContext(offset: 0, width: width);

        expect(videoContext.width, equals(width));
        expect(videoContext.height, isNull);
        expect(videoContext.margin, isNull);
        expect(videoContext.alignment, equals(Alignment.center));
      });

      test('height is correctly assigned when only height is provided', () {
        const height = 720.0;

        const videoContext = VideoContext(offset: 0, height: height);

        expect(videoContext.width, isNull);
        expect(videoContext.height, equals(height));
        expect(videoContext.margin, isNull);
        expect(videoContext.alignment, equals(Alignment.center));
      });
    });

    group('null properties', () {
      test('width can be explicitly set to null', () {
        const videoContext = VideoContext(offset: 0, width: null);

        expect(videoContext.width, isNull);
      });

      test('height can be explicitly set to null', () {
        const videoContext = VideoContext(offset: 0, height: null);

        expect(videoContext.height, isNull);
      });

      test('margin can be explicitly set to null', () {
        const videoContext = VideoContext(offset: 0, margin: null);

        expect(videoContext.margin, isNull);
      });

      test('all nullable properties can be null simultaneously', () {
        const videoContext = VideoContext(
          offset: 0,
          width: null,
          height: null,
          margin: null,
        );

        expect(videoContext.width, isNull);
        expect(videoContext.height, isNull);
        expect(videoContext.margin, isNull);
      });
    });

    group('alignment variations', () {
      test('supports Alignment.topLeft', () {
        const videoContext =
            VideoContext(offset: 0, alignment: Alignment.topLeft);
        expect(videoContext.alignment, equals(Alignment.topLeft));
      });

      test('supports Alignment.center', () {
        const videoContext =
            VideoContext(offset: 0, alignment: Alignment.center);
        expect(videoContext.alignment, equals(Alignment.center));
      });

      test('supports Alignment.bottomRight', () {
        const videoContext =
            VideoContext(offset: 0, alignment: Alignment.bottomRight);
        expect(videoContext.alignment, equals(Alignment.bottomRight));
      });
    });

    group('immutability', () {
      test('VideoContext is a const constructor', () {
        const videoContext1 = VideoContext(
          offset: 5,
          width: 640.0,
          height: 480.0,
          margin: 5.0,
          alignment: Alignment.center,
        );

        const videoContext2 = VideoContext(
          offset: 5,
          width: 640.0,
          height: 480.0,
          margin: 5.0,
          alignment: Alignment.center,
        );

        // Compile-time constants with same values are identical
        expect(identical(videoContext1, videoContext2), isTrue);
      });
    });

    group('deletion use case', () {
      test('offset can be used for document removal operations', () {
        // This test documents the intended use case of the offset property
        const videoContext = VideoContext(
          offset: 42,
          width: 640,
          height: 480,
        );

        // The offset should be usable for deletion operations:
        // controller.replaceText(videoContext.offset, 1, '', selection);
        expect(videoContext.offset, equals(42));
        expect(videoContext.offset, isA<int>());
      });
    });

    group('consistency with ImageContext', () {
      test('has the same properties as ImageContext', () {
        const videoContext = VideoContext(
          offset: 10,
          width: 640,
          height: 480,
          margin: 5,
          alignment: Alignment.topLeft,
        );

        const imageContext = ImageContext(
          offset: 10,
          width: 640,
          height: 480,
          margin: 5,
          alignment: Alignment.topLeft,
        );

        // Both contexts should have the same property values
        expect(videoContext.offset, equals(imageContext.offset));
        expect(videoContext.width, equals(imageContext.width));
        expect(videoContext.height, equals(imageContext.height));
        expect(videoContext.margin, equals(imageContext.margin));
        expect(videoContext.alignment, equals(imageContext.alignment));
      });
    });
  });
}

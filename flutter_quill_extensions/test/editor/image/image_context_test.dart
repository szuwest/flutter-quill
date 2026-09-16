import 'package:flutter/widgets.dart' show Alignment;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageContext', () {
    group('default values', () {
      test('alignment defaults to Alignment.center when not specified', () {
        const imageContext = ImageContext();

        expect(imageContext.alignment, equals(Alignment.center));
      });

      test('width defaults to null when not specified', () {
        const imageContext = ImageContext();

        expect(imageContext.width, isNull);
      });

      test('height defaults to null when not specified', () {
        const imageContext = ImageContext();

        expect(imageContext.height, isNull);
      });

      test('margin defaults to null when not specified', () {
        const imageContext = ImageContext();

        expect(imageContext.margin, isNull);
      });

      test('all optional properties default correctly', () {
        const imageContext = ImageContext();

        expect(imageContext.width, isNull);
        expect(imageContext.height, isNull);
        expect(imageContext.margin, isNull);
        expect(imageContext.alignment, equals(Alignment.center));
      });
    });

    group('complete parameters', () {
      test('all parameters are correctly assigned', () {
        const width = 200.0;
        const height = 150.0;
        const margin = 10.0;
        const alignment = Alignment.topLeft;

        const imageContext = ImageContext(
          width: width,
          height: height,
          margin: margin,
          alignment: alignment,
        );

        expect(imageContext.width, equals(width));
        expect(imageContext.height, equals(height));
        expect(imageContext.margin, equals(margin));
        expect(imageContext.alignment, equals(alignment));
      });

      test('width is correctly assigned when only width is provided', () {
        const width = 300.0;

        const imageContext = ImageContext(width: width);

        expect(imageContext.width, equals(width));
        expect(imageContext.height, isNull);
        expect(imageContext.margin, isNull);
        expect(imageContext.alignment, equals(Alignment.center));
      });

      test('height is correctly assigned when only height is provided', () {
        const height = 250.0;

        const imageContext = ImageContext(height: height);

        expect(imageContext.width, isNull);
        expect(imageContext.height, equals(height));
        expect(imageContext.margin, isNull);
        expect(imageContext.alignment, equals(Alignment.center));
      });

      test('margin is correctly assigned when only margin is provided', () {
        const margin = 15.0;

        const imageContext = ImageContext(margin: margin);

        expect(imageContext.width, isNull);
        expect(imageContext.height, isNull);
        expect(imageContext.margin, equals(margin));
        expect(imageContext.alignment, equals(Alignment.center));
      });

      test('alignment is correctly assigned when only alignment is provided',
          () {
        const alignment = Alignment.bottomRight;

        const imageContext = ImageContext(alignment: alignment);

        expect(imageContext.width, isNull);
        expect(imageContext.height, isNull);
        expect(imageContext.margin, isNull);
        expect(imageContext.alignment, equals(alignment));
      });
    });

    group('null properties', () {
      test('width can be explicitly set to null', () {
        const imageContext = ImageContext(width: null);

        expect(imageContext.width, isNull);
      });

      test('height can be explicitly set to null', () {
        const imageContext = ImageContext(height: null);

        expect(imageContext.height, isNull);
      });

      test('margin can be explicitly set to null', () {
        const imageContext = ImageContext(margin: null);

        expect(imageContext.margin, isNull);
      });

      test('all nullable properties can be null simultaneously', () {
        const imageContext = ImageContext(
          width: null,
          height: null,
          margin: null,
        );

        expect(imageContext.width, isNull);
        expect(imageContext.height, isNull);
        expect(imageContext.margin, isNull);
      });
    });

    group('alignment variations', () {
      test('supports Alignment.topLeft', () {
        const imageContext = ImageContext(alignment: Alignment.topLeft);
        expect(imageContext.alignment, equals(Alignment.topLeft));
      });

      test('supports Alignment.topCenter', () {
        const imageContext = ImageContext(alignment: Alignment.topCenter);
        expect(imageContext.alignment, equals(Alignment.topCenter));
      });

      test('supports Alignment.topRight', () {
        const imageContext = ImageContext(alignment: Alignment.topRight);
        expect(imageContext.alignment, equals(Alignment.topRight));
      });

      test('supports Alignment.centerLeft', () {
        const imageContext = ImageContext(alignment: Alignment.centerLeft);
        expect(imageContext.alignment, equals(Alignment.centerLeft));
      });

      test('supports Alignment.centerRight', () {
        const imageContext = ImageContext(alignment: Alignment.centerRight);
        expect(imageContext.alignment, equals(Alignment.centerRight));
      });

      test('supports Alignment.bottomLeft', () {
        const imageContext = ImageContext(alignment: Alignment.bottomLeft);
        expect(imageContext.alignment, equals(Alignment.bottomLeft));
      });

      test('supports Alignment.bottomCenter', () {
        const imageContext = ImageContext(alignment: Alignment.bottomCenter);
        expect(imageContext.alignment, equals(Alignment.bottomCenter));
      });

      test('supports Alignment.bottomRight', () {
        const imageContext = ImageContext(alignment: Alignment.bottomRight);
        expect(imageContext.alignment, equals(Alignment.bottomRight));
      });
    });

    group('immutability', () {
      test('ImageContext is a const constructor', () {
        // This test verifies that ImageContext can be instantiated as a
        // compile-time constant, which is a requirement for @immutable classes
        const imageContext1 = ImageContext(
          width: 100.0,
          height: 100.0,
          margin: 5.0,
          alignment: Alignment.center,
        );

        const imageContext2 = ImageContext(
          width: 100.0,
          height: 100.0,
          margin: 5.0,
          alignment: Alignment.center,
        );

        // Compile-time constants with same values are identical
        expect(identical(imageContext1, imageContext2), isTrue);
      });
    });

    group('edge cases', () {
      test('accepts zero values for width', () {
        const imageContext = ImageContext(width: 0.0);
        expect(imageContext.width, equals(0.0));
      });

      test('accepts zero values for height', () {
        const imageContext = ImageContext(height: 0.0);
        expect(imageContext.height, equals(0.0));
      });

      test('accepts zero values for margin', () {
        const imageContext = ImageContext(margin: 0.0);
        expect(imageContext.margin, equals(0.0));
      });

      test('accepts large values for dimensions', () {
        const largeValue = 10000.0;
        const imageContext = ImageContext(
          width: largeValue,
          height: largeValue,
          margin: largeValue,
        );

        expect(imageContext.width, equals(largeValue));
        expect(imageContext.height, equals(largeValue));
        expect(imageContext.margin, equals(largeValue));
      });

      test('accepts fractional values', () {
        const imageContext = ImageContext(
          width: 123.456,
          height: 78.9,
          margin: 1.5,
        );

        expect(imageContext.width, equals(123.456));
        expect(imageContext.height, equals(78.9));
        expect(imageContext.margin, equals(1.5));
      });
    });
  });
}

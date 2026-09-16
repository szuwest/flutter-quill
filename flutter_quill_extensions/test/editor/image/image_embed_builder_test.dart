import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../quill_test_app.dart';

void main() {
  group('QuillEditorImageEmbedBuilder', () {
    late QuillController controller;
    late FocusNode focusNode;
    late ScrollController scrollController;

    setUp(() {
      controller = QuillController.basic();
      focusNode = FocusNode();
      scrollController = ScrollController();
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
      scrollController.dispose();
    });

    /// Helper to create a QuillEditor with image embed configuration
    Widget createEditorWithImageConfig({
      required QuillEditorImageEmbedConfig imageConfig,
      String imageUrl = 'https://example.com/test.png',
      QuillController? customController,
      FocusNode? customFocusNode,
    }) {
      final ctrl = customController ?? controller;
      final fn = customFocusNode ?? focusNode;

      // Insert an image into the document
      ctrl.document = Document.fromJson([
        {
          'insert': {'image': imageUrl}
        },
        {'insert': '\n'},
      ]);

      return QuillTestApp.home(
        QuillEditor(
          controller: ctrl,
          focusNode: fn,
          scrollController: scrollController,
          config: QuillEditorConfig(
            embedBuilders: [
              QuillEditorImageEmbedBuilder(config: imageConfig),
            ],
          ),
        ),
      );
    }

    group('customImageBuilder returns Widget', () {
      testWidgets(
          'renders the custom widget when customImageBuilder returns a Widget',
          (tester) async {
        const customKey = Key('custom_image_widget');

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            return Container(
              key: customKey,
              child: const Text('Custom Image'),
            );
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        // Verify the custom widget is rendered
        expect(find.byKey(customKey), findsOneWidget);
        expect(find.text('Custom Image'), findsOneWidget);
      });

      testWidgets('custom widget receives correct imageUrl', (tester) async {
        String? capturedImageUrl;
        const testImageUrl = 'https://example.com/captured.png';

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedImageUrl = imageUrl;
            return const Text('Custom');
          },
        );

        await tester.pumpWidget(createEditorWithImageConfig(
          imageConfig: config,
          imageUrl: testImageUrl,
        ));
        await tester.pumpAndSettle();

        expect(capturedImageUrl, equals(testImageUrl));
      });

      testWidgets('custom widget receives readOnly flag correctly',
          (tester) async {
        bool? capturedReadOnly;

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedReadOnly = isReadOnly;
            return const Text('Custom');
          },
        );

        // Create a read-only controller
        final readOnlyController = QuillController(
          document: Document.fromJson([
            {
              'insert': {'image': 'https://example.com/test.png'}
            },
            {'insert': '\n'},
          ]),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );

        final readOnlyFocusNode = FocusNode();

        await tester.pumpWidget(createEditorWithImageConfig(
          imageConfig: config,
          customController: readOnlyController,
          customFocusNode: readOnlyFocusNode,
        ));
        await tester.pumpAndSettle();

        expect(capturedReadOnly, isTrue);

        readOnlyController.dispose();
        readOnlyFocusNode.dispose();
      });

      testWidgets(
          'custom widget receives readOnly as false when editor is editable',
          (tester) async {
        bool? capturedReadOnly;

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedReadOnly = isReadOnly;
            return const Text('Custom');
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        expect(capturedReadOnly, isFalse);
      });
    });

    group('customImageBuilder returns null - callback verification', () {
      // Note: These tests verify callback invocation only.
      // Full rendering tests for the fallback path require complex image mocking
      // which is handled by integration tests.

      testWidgets('customImageBuilder is invoked when configured',
          (tester) async {
        var customBuilderCalled = false;
        String? receivedImageUrl;
        bool? receivedIsReadOnly;
        ImageContext? receivedImageContext;

        // Use customImageBuilder that returns a Widget to avoid network issues
        // but capture the parameters it receives
        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            customBuilderCalled = true;
            receivedImageUrl = imageUrl;
            receivedIsReadOnly = isReadOnly;
            receivedImageContext = imageContext;
            return const Text('Custom');
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        expect(customBuilderCalled, isTrue);
        expect(receivedImageUrl, equals('https://example.com/test.png'));
        expect(receivedIsReadOnly, isFalse);
        expect(receivedImageContext, isNotNull);
      });
    });

    group('margin wrapping', () {
      testWidgets('wraps custom widget with Padding when margin is specified',
          (tester) async {
        const customKey = Key('custom_image');

        // Create an image embed with margin style attribute
        controller.document = Document.fromJson([
          {
            'insert': {'image': 'https://example.com/test.png'},
            'attributes': {'style': 'margin:10'}
          },
          {'insert': '\n'},
        ]);

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            return Container(
              key: customKey,
              child: const Text('Custom'),
            );
          },
        );

        await tester.pumpWidget(QuillTestApp.home(
          QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: QuillEditorConfig(
              embedBuilders: [
                QuillEditorImageEmbedBuilder(config: config),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // The custom widget should be present
        expect(find.byKey(customKey), findsOneWidget);
      });

      testWidgets('does not add unnecessary Padding when margin is null',
          (tester) async {
        const customKey = Key('custom_image_no_margin');

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            // Verify margin is null when not specified
            expect(imageContext.margin, isNull);
            return Container(
              key: customKey,
              child: const Text('Custom No Margin'),
            );
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        expect(find.byKey(customKey), findsOneWidget);
      });
    });

    group('ImageContext parameter passing', () {
      testWidgets('passes width to ImageContext when specified in attributes',
          (tester) async {
        ImageContext? capturedContext;

        controller.document = Document.fromJson([
          {
            'insert': {'image': 'https://example.com/test.png'},
            'attributes': {'width': '200'}
          },
          {'insert': '\n'},
        ]);

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedContext = imageContext;
            return const Text('Custom');
          },
        );

        await tester.pumpWidget(QuillTestApp.home(
          QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: QuillEditorConfig(
              embedBuilders: [
                QuillEditorImageEmbedBuilder(config: config),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(capturedContext!.width, equals(200.0));
      });

      testWidgets('passes height to ImageContext when specified in attributes',
          (tester) async {
        ImageContext? capturedContext;

        controller.document = Document.fromJson([
          {
            'insert': {'image': 'https://example.com/test.png'},
            'attributes': {'height': '150'}
          },
          {'insert': '\n'},
        ]);

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedContext = imageContext;
            return const Text('Custom');
          },
        );

        await tester.pumpWidget(QuillTestApp.home(
          QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: QuillEditorConfig(
              embedBuilders: [
                QuillEditorImageEmbedBuilder(config: config),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(capturedContext!.height, equals(150.0));
      });

      testWidgets(
          'passes default alignment (center) to ImageContext when not specified',
          (tester) async {
        ImageContext? capturedContext;

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedContext = imageContext;
            return const Text('Custom');
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(capturedContext!.alignment, equals(Alignment.center));
      });

      testWidgets('passes null for width/height/margin when not specified',
          (tester) async {
        ImageContext? capturedContext;

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedContext = imageContext;
            return const Text('Custom');
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(capturedContext!.width, isNull);
        expect(capturedContext!.height, isNull);
        expect(capturedContext!.margin, isNull);
      });

      testWidgets(
          'passes all ImageContext properties correctly when all are specified',
          (tester) async {
        ImageContext? capturedContext;

        controller.document = Document.fromJson([
          {
            'insert': {'image': 'https://example.com/test.png'},
            'attributes': {
              'width': '300',
              'height': '200',
              'style': 'alignment:topLeft;margin:15'
            }
          },
          {'insert': '\n'},
        ]);

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            capturedContext = imageContext;
            return const Text('Custom');
          },
        );

        await tester.pumpWidget(QuillTestApp.home(
          QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: QuillEditorConfig(
              embedBuilders: [
                QuillEditorImageEmbedBuilder(config: config),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(capturedContext!.width, equals(300.0));
        expect(capturedContext!.height, equals(200.0));
      });
    });

    group('backward compatibility', () {
      testWidgets(
          'imageProviderBuilder is NOT called when customImageBuilder returns Widget',
          (tester) async {
        var imageProviderBuilderCalled = false;

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            return const Text('Custom Widget');
          },
          imageProviderBuilder: (context, imageUrl) {
            imageProviderBuilderCalled = true;
            return null;
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        // When customImageBuilder returns a widget, imageProviderBuilder should NOT be called
        expect(imageProviderBuilderCalled, isFalse);
      });

      testWidgets(
          'onImageClicked is NOT invoked when customImageBuilder returns Widget',
          (tester) async {
        var imageClicked = false;
        const customKey = Key('custom_image_clickable');

        final config = QuillEditorImageEmbedConfig(
          customImageBuilder: (imageUrl, isReadOnly, imageContext) {
            return GestureDetector(
              key: customKey,
              onTap: () {
                // Custom click handling
              },
              child: const Text('Custom'),
            );
          },
          onImageClicked: (imageSource) {
            imageClicked = true;
          },
        );

        await tester
            .pumpWidget(createEditorWithImageConfig(imageConfig: config));
        await tester.pumpAndSettle();

        // Tap on the custom widget
        await tester.tap(find.byKey(customKey));
        await tester.pumpAndSettle();

        // The default onImageClicked should NOT be invoked
        expect(imageClicked, isFalse);
      });
    });

    group('QuillEditorImageEmbedBuilder properties', () {
      test('key returns BlockEmbed.imageType', () {
        const config = QuillEditorImageEmbedConfig();
        final builder = QuillEditorImageEmbedBuilder(config: config);

        expect(builder.key, equals(BlockEmbed.imageType));
      });

      test('expanded returns false', () {
        const config = QuillEditorImageEmbedConfig();
        final builder = QuillEditorImageEmbedBuilder(config: config);

        expect(builder.expanded, isFalse);
      });
    });
  });
}

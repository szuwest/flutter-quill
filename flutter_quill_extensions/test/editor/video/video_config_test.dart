import 'package:flutter/widgets.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuillEditorVideoEmbedConfig', () {
    group('onVideoRemovedCallback', () {
      test('defaults to defaultOnVideoRemovedCallback when not provided', () {
        const config = QuillEditorVideoEmbedConfig();

        // The getter should return the default callback
        expect(config.onVideoRemovedCallback, isNotNull);
      });

      test('can be set via constructor', () {
        var callbackCalled = false;
        String? capturedUrl;

        final config = QuillEditorVideoEmbedConfig(
          onVideoRemovedCallback: (videoUrl) async {
            callbackCalled = true;
            capturedUrl = videoUrl;
          },
        );

        // Invoke the callback
        config.onVideoRemovedCallback('test_video.mp4');

        expect(callbackCalled, isTrue);
        expect(capturedUrl, equals('test_video.mp4'));
      });

      test('custom callback overrides default', () {
        var customCallbackCalled = false;

        final config = QuillEditorVideoEmbedConfig(
          onVideoRemovedCallback: (videoUrl) async {
            customCallbackCalled = true;
          },
        );

        config.onVideoRemovedCallback('video.mp4');

        expect(customCallbackCalled, isTrue);
      });
    });

    group('shouldRemoveVideoCallback', () {
      test('defaults to null when not provided', () {
        const config = QuillEditorVideoEmbedConfig();

        expect(config.shouldRemoveVideoCallback, isNull);
      });

      test('can be set via constructor', () async {
        final config = QuillEditorVideoEmbedConfig(
          shouldRemoveVideoCallback: (videoUrl) async {
            return videoUrl.endsWith('.mp4');
          },
        );

        expect(config.shouldRemoveVideoCallback, isNotNull);

        final shouldRemoveMp4 =
            await config.shouldRemoveVideoCallback!('video.mp4');
        final shouldRemoveAvi =
            await config.shouldRemoveVideoCallback!('video.avi');

        expect(shouldRemoveMp4, isTrue);
        expect(shouldRemoveAvi, isFalse);
      });

      test('receives correct video URL', () async {
        String? capturedUrl;

        final config = QuillEditorVideoEmbedConfig(
          shouldRemoveVideoCallback: (videoUrl) async {
            capturedUrl = videoUrl;
            return true;
          },
        );

        await config
            .shouldRemoveVideoCallback!('https://example.com/video.mp4');

        expect(capturedUrl, equals('https://example.com/video.mp4'));
      });
    });

    group('copyWith', () {
      test('preserves onVideoRemovedCallback when not specified', () {
        var originalCalled = false;

        final original = QuillEditorVideoEmbedConfig(
          onVideoRemovedCallback: (videoUrl) async {
            originalCalled = true;
          },
        );

        final copied = original.copyWith();

        copied.onVideoRemovedCallback('test.mp4');

        expect(originalCalled, isTrue);
      });

      test('updates onVideoRemovedCallback when specified', () {
        var originalCalled = false;
        var newCalled = false;

        final original = QuillEditorVideoEmbedConfig(
          onVideoRemovedCallback: (videoUrl) async {
            originalCalled = true;
          },
        );

        final copied = original.copyWith(
          onVideoRemovedCallback: (videoUrl) async {
            newCalled = true;
          },
        );

        copied.onVideoRemovedCallback('test.mp4');

        expect(originalCalled, isFalse);
        expect(newCalled, isTrue);
      });

      test('preserves shouldRemoveVideoCallback when not specified', () async {
        final original = QuillEditorVideoEmbedConfig(
          shouldRemoveVideoCallback: (videoUrl) async => true,
        );

        final copied = original.copyWith();

        expect(copied.shouldRemoveVideoCallback, isNotNull);
        expect(await copied.shouldRemoveVideoCallback!('test'), isTrue);
      });

      test('updates shouldRemoveVideoCallback when specified', () async {
        final original = QuillEditorVideoEmbedConfig(
          shouldRemoveVideoCallback: (videoUrl) async => true,
        );

        final copied = original.copyWith(
          shouldRemoveVideoCallback: (videoUrl) async => false,
        );

        expect(await copied.shouldRemoveVideoCallback!('test'), isFalse);
      });

      test('preserves other properties when updating callbacks', () {
        void onVideoInit(GlobalKey key) {}
        Widget? customBuilder(
                String url, bool readOnly, VideoContext context) =>
            null;

        final original = QuillEditorVideoEmbedConfig(
          onVideoInit: onVideoInit,
          customVideoBuilder: customBuilder,
        );

        final copied = original.copyWith(
          onVideoRemovedCallback: (url) async {},
        );

        expect(copied.onVideoInit, equals(onVideoInit));
        expect(copied.customVideoBuilder, equals(customBuilder));
      });
    });

    group('backward compatibility', () {
      test('can be constructed without any callbacks', () {
        const config = QuillEditorVideoEmbedConfig();

        expect(config.onVideoInit, isNull);
        expect(config.customVideoBuilder, isNull);
        expect(config.shouldRemoveVideoCallback, isNull);
        // onVideoRemovedCallback has a default
        expect(config.onVideoRemovedCallback, isNotNull);
      });

      test('can be constructed with only legacy properties', () {
        void onVideoInit(GlobalKey key) {}
        Widget? customBuilder(
                String url, bool readOnly, VideoContext context) =>
            null;

        final config = QuillEditorVideoEmbedConfig(
          onVideoInit: onVideoInit,
          customVideoBuilder: customBuilder,
        );

        expect(config.onVideoInit, equals(onVideoInit));
        expect(config.customVideoBuilder, equals(customBuilder));
      });
    });

    group('defaultOnVideoRemovedCallback', () {
      test('is accessible as a static getter', () {
        final callback =
            QuillEditorVideoEmbedConfig.defaultOnVideoRemovedCallback;

        expect(callback, isNotNull);
        expect(callback, isA<VideoEmbedBuilderOnRemovedCallback>());
      });

      test('completes without error for non-existent file', () async {
        final callback =
            QuillEditorVideoEmbedConfig.defaultOnVideoRemovedCallback;

        await expectLater(
          callback('/non/existent/video.mp4'),
          completes,
        );
      });
    });
  });
}

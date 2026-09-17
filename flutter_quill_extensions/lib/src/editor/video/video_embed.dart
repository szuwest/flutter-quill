import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../common/utils/element_utils/element_utils.dart';
import 'config/video_config.dart';
import 'video_embed_types.dart';
import 'widgets/video_app.dart';

class QuillEditorVideoEmbedBuilder extends EmbedBuilder {
  const QuillEditorVideoEmbedBuilder({
    required this.config,
  });

  final QuillEditorVideoEmbedConfig config;

  @override
  String get key => BlockEmbed.videoType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final videoUrl = embedContext.node.value.data;

    final ((elementSize), margin, alignment) = getElementAttributes(
      embedContext.node,
      context,
    );

    final width = elementSize.width;
    final height = elementSize.height;

    // Check if customVideoBuilder is provided
    final customVideoBuilder = config.customVideoBuilder;
    if (customVideoBuilder != null) {
      final videoContext = VideoContext(
        offset: embedContext.node.documentOffset,
        width: width,
        height: height,
        margin: margin,
        alignment: alignment,
      );
      final customWidget = customVideoBuilder(
        videoUrl,
        embedContext.readOnly,
        videoContext,
      );
      if (customWidget != null) {
        // Apply margin wrapping if needed
        if (margin != null) {
          return Padding(
            padding: EdgeInsets.all(margin),
            child: customWidget,
          );
        }
        return customWidget;
      }
    }

    // Default implementation
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all(margin ?? 0.0),
      alignment: alignment,
      child: VideoApp(
        videoUrl: videoUrl,
        readOnly: embedContext.readOnly,
        onVideoInit: config.onVideoInit,
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwfh_chewie/fwfh_chewie.dart';
import 'package:html/dom.dart' as dom;
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_state.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/custom_elements/error_element.dart';
import 'package:xayn_discovery_app/presentation/utils/reader_mode_settings_extension.dart';
import 'package:xayn_discovery_app/presentation/widget/widget_testable_progress_indicator.dart';
import 'package:xayn_readability/xayn_readability.dart' as readability;

typedef ScrollHandler = void Function(double position);

const String _kUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36';
const List<String> _kClassesToPreserve = [
  'caption',
  'emoji',
  'hidden',
  'invisible',
  'sr-only',
  'visually-hidden',
  'visuallyhidden',
  'wp-caption',
  'wp-caption-text',
  'wp-smiley',
];
const EdgeInsets _kPadding = EdgeInsets.zero;
final RegExp _kMatchManifestRegExp = RegExp(
  r'manifest\([^\)]+\)',
  caseSensitive: false,
);

class ReaderMode extends StatefulWidget {
  final String title;
  final String languageCode;
  final Uri? uri;
  final readability.ProcessHtmlResult? processHtmlResult;
  final VoidCallback? onProcessedHtml;
  final ScrollHandler? onScroll;
  final EdgeInsets padding;

  const ReaderMode({
    Key? key,
    required this.title,
    required this.languageCode,
    this.uri,
    this.processHtmlResult,
    this.padding = _kPadding,
    this.onProcessedHtml,
    this.onScroll,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReaderModeState();
}

class _ReaderModeState extends State<ReaderMode> {
  late final ReaderModeManager _readerModeManager = di.get();
  late final _readerModeController = readability.ReaderModeController();

  @override
  void initState() {
    super.initState();

    _updateCardData();
  }

  @override
  void dispose() {
    super.dispose();

    _readerModeManager.close();
    _readerModeController.dispose();
  }

  @override
  void didUpdateWidget(ReaderMode oldWidget) {
    if (oldWidget.title != widget.title ||
        oldWidget.processHtmlResult != widget.processHtmlResult) {
      _updateCardData();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final loading = LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight / 3 - R.dimen.unit;

        return SizedBox(
          width: double.maxFinite,
          height: height.clamp(.0, double.maxFinite),
          child: Padding(
            padding: EdgeInsets.all(R.dimen.unit2),
            child: Container(),
          ),
        );
      },
    );

    return BlocBuilder<ReaderModeManager, ReaderModeState>(
      bloc: _readerModeManager,
      builder: (context, state) {
        final uri = state.uri;
        final fontSettings = state.readerModeSettings;

        if (uri == null) {
          return loading;
        }

        overrideLinkStyle(element) => element.localName?.toLowerCase() == 'a'
            ? {
                'text-decoration': 'none',
                'color': _getHtmlColorString(fontSettings),
              }
            : null;

        _readerModeController.loadUri(uri);

        final readerMode = readability.ReaderMode(
          controller: _readerModeController,
          textStyle: _getReaderModeStyle(fontSettings),
          userAgent: _kUserAgent,
          classesToPreserve: _kClassesToPreserve,
          rendererPadding: widget.padding,
          factoryBuilder: () => _ReaderModeWidgetFactory(),
          loadingBuilder: () => loading,
          onProcessedHtml: (result) async {
            widget.onProcessedHtml?.call();

            final contents = result.contents;

            if (contents != null && contents.isNotEmpty) {
              _readerModeManager.handleSpeechStart(
                languageCode: widget.languageCode,
                uri: widget.uri,
                html: contents,
              );
            }

            return _onProcessedHtml(result);
          },
          onScroll: widget.onScroll,
          customStylesBuilder: overrideLinkStyle,
          customWidgetBuilder: _customElements,
        );

        return ColoredBox(
          color: fontSettings.backgroundColor.color,
          child: readerMode,
        );
      },
    );
  }

  Widget? _customElements(dom.Element element) {
    final name = element.localName?.toLowerCase();

    switch (name) {
      case 'error':
        return ErrorElement(element: element);
    }

    return null;
  }

  TextStyle _getReaderModeStyle(ReaderModeSettings settings) {
    final fontSize = settings.fontSize.textStyle;
    final fontStyle = settings.fontStyle.textStyle;
    final readerModeTextStyle = fontSize.merge(fontStyle);
    final textColor = settings.backgroundColor.textColor;
    return readerModeTextStyle.copyWith(color: textColor);
  }

  String _getHtmlColorString(ReaderModeSettings settings) {
    final textColor = settings.backgroundColor.textColor;
    final htmlColor =
        'rgba(${textColor.red},${textColor.green},${textColor.blue},${textColor.alpha ~/ 0xff})';
    return htmlColor;
  }

  Future<readability.ProcessHtmlResult> _onProcessedHtml(
      readability.ProcessHtmlResult result) async {
    final byline = result.metadata?.byline?.trim();

    if (byline == null || byline.isEmpty) {
      return result;
    }

    return result.withOtherContent(
        '<p>${R.strings.readerModeBylinePrefix} <b>$byline</b></p>${result.contents}');
  }

  void _updateCardData() {
    final processHtmlResult = widget.processHtmlResult;

    if (processHtmlResult != null) {
      _readerModeManager.handleCardData(
        title: widget.title,
        processHtmlResult: processHtmlResult,
      );
    }
  }
}

class _ReaderModeWidgetFactory extends readability.WidgetFactory
    with ChewieFactory {
  /// This property is actually used for link callbacks,
  /// we don't want to follow links, so this is set to be null.
  /// Simply remove this override to re-enable links, when needed.
  @override
  GestureTapCallback? gestureTapCallback(String url) => null;

  @override
  Widget? buildImageWidget(
          readability.BuildMetadata meta, readability.ImageSource src) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(R.dimen.unit),
        child: CachedImage(
          uri: Uri.parse(src.url),
          errorBuilder: (_) => Container(),
          noImageBuilder: (_) => Container(),
          loadingBuilder: (_, __) => const WidgetTestableProgressIndicator(),
        ),
      );

  @override
  Widget? buildVideoPlayer(
    readability.BuildMetadata meta,
    String url, {
    required bool autoplay,
    required bool controls,
    double? height,
    required bool loop,
    String? posterUrl,
    double? width,
  }) {
    var actualUrl = url;
    final uri = Uri.parse(url);
    final maybeFile = uri.pathSegments.last;

    if (maybeFile.startsWith(_kMatchManifestRegExp)) {
      // common with Bing/MSN
      actualUrl = '$url.m3u8';
    }

    return super.buildVideoPlayer(
      meta,
      actualUrl,
      autoplay: false,
      controls: true,
      loop: false,
      height: height,
      posterUrl: posterUrl,
      width: width,
    );
  }
}

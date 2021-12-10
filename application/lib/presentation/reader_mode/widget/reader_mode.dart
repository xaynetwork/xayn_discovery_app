import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwfh_chewie/fwfh_chewie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/reading_time_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_state.dart';
import 'package:xayn_readability/xayn_readability.dart' as readability;

const String kUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36';
const List<String> kClassesToPreserve = [
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

class ReaderMode extends StatefulWidget {
  final readability.ProcessHtmlResult? processHtmlResult;

  const ReaderMode({
    Key? key,
    this.processHtmlResult,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReaderModeState();
}

class _ReaderModeState extends State<ReaderMode> {
  late final ReaderModeManager _readerModeManager;
  late final readability.ReaderModeController _readerModeController;

  @override
  void initState() {
    super.initState();

    _readerModeManager = di.get();
    _readerModeController = readability.ReaderModeController();

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
    if (oldWidget.processHtmlResult != widget.processHtmlResult) {
      _updateCardData();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderModeManager, ReaderModeState>(
        bloc: _readerModeManager,
        builder: (context, state) {
          final uri = state.uri;

          if (uri == null) {
            return _createShimmer();
          }

          _readerModeController.loadUri(uri);

          return readability.ReaderMode(
            controller: _readerModeController,
            // todo: move into xayn_design
            textStyle: R.styles.readerModeTextStyle,
            userAgent: kUserAgent,
            classesToPreserve: kClassesToPreserve,
            factoryBuilder: () => _ReaderModeWidgetFactory(),
            loadingBuilder: () => _createShimmer(),
          );
        });
  }

  void _updateCardData() {
    final processHtmlResult = widget.processHtmlResult;

    if (processHtmlResult != null) {
      _readerModeManager.handleCardData(ReadingTimeInput(
        processHtmlResult: processHtmlResult,
        lang: 'en', // todo: fetch from app settings
        singleUnit: Strings.timeUnitM,
        pluralUnit: Strings.timeUnitMM,
      ));
    }
  }

  /// creates shimmer which resembles paragraphs
  Widget _createShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final random = Random(0x80);

        // random break every 1/4 times
        isParagraphBreak() => random.nextDouble() > .75;
        // [35%, 100%] of width
        textLineWidth() =>
            (.35 + random.nextDouble() * .65) * constraints.maxWidth;

        buildTextLine() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: isParagraphBreak() ? R.dimen.unit3 : R.dimen.unit / 2,
                  ),
                  child: Container(
                    width: textLineWidth(),
                    height: R.dimen.unit,
                    color: Colors.white,
                  ),
                ),
              ],
            );

        return Shimmer.fromColors(
          baseColor: R.colors.primaryText.withAlpha(50),
          highlightColor: R.colors.primaryText.withAlpha(20),
          enabled: true,
          child: ListView.builder(
            itemBuilder: (_, __) => Padding(
              padding: EdgeInsets.only(bottom: R.dimen.unit),
              child: buildTextLine(),
            ),
            itemCount: 32,
          ),
        );
      },
    );
  }
}

class _ReaderModeWidgetFactory extends readability.WidgetFactory
    with ChewieFactory {
  _ReaderModeWidgetFactory();

  @override
  Widget buildBodyWidget(BuildContext context, Widget child) {
    final builtChild = super.buildBodyWidget(
      context,
      Padding(
        padding: EdgeInsets.only(
          left: R.dimen.unit2,
          right: R.dimen.unit2,
          top: R.dimen.unit2,
        ),
        child: child,
      ),
    );

    return builtChild;
  }

  @override
  Widget? buildImageWidget(
      readability.BuildMetadata meta, readability.ImageSource src) {
    // if w/h is zero, fall back to R.dimen.unit8, showing the image as a thumbnail then
    return ClipRRect(
      borderRadius: BorderRadius.circular(R.dimen.unit),
      child: CachedImage(
        uri: Uri.parse(src.url),
        width: (src.width ?? R.dimen.unit8).floor(),
        height: (src.height ?? R.dimen.unit8).floor(),
        fit: BoxFit.fitWidth,
      ),
    );
  }

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

    if (maybeFile.startsWith(RegExp(
      r'manifest\([^\)]+\)',
      caseSensitive: false,
    ))) {
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

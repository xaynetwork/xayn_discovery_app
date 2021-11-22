import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwfh_chewie/fwfh_chewie.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
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
  final String title;
  final String snippet;
  final Uri imageUri;
  final readability.ProcessHtmlResult? processHtmlResult;

  const ReaderMode({
    Key? key,
    required this.title,
    required this.snippet,
    required this.imageUri,
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
    if (oldWidget.title != widget.title ||
        oldWidget.snippet != widget.snippet ||
        oldWidget.imageUri != widget.imageUri ||
        oldWidget.processHtmlResult != widget.processHtmlResult) {
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
            return Container();
          }

          _readerModeController.loadUri(uri);

          return readability.ReaderMode(
            controller: _readerModeController,
            // todo: move into xayn_design
            textStyle: R.styles.appBodyTextBright?.copyWith(
              fontSize: 14.0,
              height: 1.75,
              letterSpacing: 1.1,
            ),
            userAgent: kUserAgent,
            classesToPreserve: kClassesToPreserve,
            factoryBuilder: () => _ReaderModeWidgetFactory(),
          );
        });
  }

  void _updateCardData() {
    final processHtmlResult = widget.processHtmlResult;

    if (processHtmlResult != null) {
      _readerModeManager.handleCardData(
        title: widget.title,
        snippet: widget.snippet,
        imageUri: widget.imageUri,
        processHtmlResult: processHtmlResult,
      );
    }
  }
}

class _ReaderModeWidgetFactory extends readability.WidgetFactory
    with ChewieFactory {
  _ReaderModeWidgetFactory();

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
}

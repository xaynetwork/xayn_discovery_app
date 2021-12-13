import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/shared_card_image.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';

class ReaderModeScreen extends StatefulWidget {
  final Document document;
  final String heroTag;
  final Animation<double> animation;
  final DiscoveryCardManager? discoveryCardManager;
  final ImageManager? imageManager;
  final SharedCardImageController? sharedCardImageController;
  final ViewTypeCallback? onViewTypeChanged;

  const ReaderModeScreen({
    Key? key,
    required this.document,
    required this.heroTag,
    required this.animation,
    this.discoveryCardManager,
    this.imageManager,
    this.sharedCardImageController,
    this.onViewTypeChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReaderModeScreenState();
}

class _ReaderModeScreenState extends State<ReaderModeScreen> {
  late final DiscoveryCardManager _discoveryCardManager;

  WebResource get webResource => widget.document.webResource;
  Uri get uri => webResource.url;
  String get imageUrl => webResource.displayUrl.toString();

  double _opacity = .0;
  double _scrollPosition = .0;

  @override
  void initState() {
    super.initState();

    final discoveryCardManager = widget.discoveryCardManager;

    if (discoveryCardManager == null) {
      _discoveryCardManager = di.get()..updateUri(uri);
    } else {
      _discoveryCardManager = discoveryCardManager;
    }

    widget.animation.addListener(
      () => setState(() => _opacity = widget.animation.value),
    );

    widget.onViewTypeChanged?.call(DocumentViewType.readerMode);
  }

  @override
  void dispose() {
    super.dispose();

    widget.onViewTypeChanged?.call(DocumentViewType.story);

    if (widget.discoveryCardManager == null) {
      _discoveryCardManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
          bloc: _discoveryCardManager,
          builder: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DiscoveryCardState state) {
    final hasValidImage = const ['http', 'https']
        .contains(widget.document.webResource.displayUrl.scheme);
    final backgroundPane = ColoredBox(
      color: R.colors.swipeCardBackground,
    );
    buildImage(double height) => hasValidImage
        ? Hero(
            tag: widget.heroTag,
            child: SharedCardImage(
              uri: Uri.parse(imageUrl),
              height: height,
              imageManager: widget.imageManager,
              controller: widget.sharedCardImageController,
              fit: BoxFit.cover,
            ),
          )
        : backgroundPane;

    onScroll(double position) => setState(() => _scrollPosition = position);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxImageSize = 2 * constraints.maxHeight / 3 + R.dimen.unit;
        final maxTweenUp = constraints.maxHeight - maxImageSize;
        final inverseOpacity = 1.0 - _opacity;
        final processHtmlResult = _opacity == 1.0 ? state.result : null;

        return Stack(
          children: [
            Positioned(
              top: .0,
              bottom: .0,
              left: .0,
              right: .0,
              child: Opacity(
                opacity: _opacity,
                child: ReaderMode(
                  padding: EdgeInsets.only(
                    left: R.dimen.unit2,
                    right: R.dimen.unit2,
                    top: maxImageSize,
                  ),
                  processHtmlResult: processHtmlResult,
                  onScroll: onScroll,
                ),
              ),
            ),
            Positioned(
              top: inverseOpacity * R.dimen.unit,
              bottom: _opacity * maxTweenUp + _scrollPosition,
              left: inverseOpacity * R.dimen.unit,
              right: inverseOpacity * R.dimen.unit,
              child: Container(
                decoration: BoxDecoration(
                  color: R.colors.swipeCardBackground,
                  borderRadius: BorderRadius.all(
                    Radius.circular(R.dimen.unit2),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -_scrollPosition,
              left: .0,
              right: .0,
              child: buildImage(maxImageSize),
            ),
          ],
        );
      },
    );
  }
}

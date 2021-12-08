import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/shared_card_image.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';

class ReaderModeScreen extends StatefulWidget {
  final Document document;
  final String heroTag;
  final Animation<double> animation;
  final DiscoveryCardManager? discoveryCardManager;
  final ImageManager? imageManager;
  final SharedCardImageController? sharedCardImageController;

  const ReaderModeScreen({
    Key? key,
    required this.document,
    required this.heroTag,
    required this.animation,
    this.discoveryCardManager,
    this.imageManager,
    this.sharedCardImageController,
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
  }

  @override
  void dispose() {
    super.dispose();

    if (widget.discoveryCardManager == null) {
      _discoveryCardManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit),
          child: BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
            bloc: _discoveryCardManager,
            builder: _buildBody,
          ),
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
    final image = hasValidImage
        ? Hero(
            tag: widget.heroTag,
            child: SharedCardImage(
              uri: Uri.parse(imageUrl),
              imageManager: widget.imageManager,
              controller: widget.sharedCardImageController,
            ),
          )
        : backgroundPane;

    return Stack(
      children: [
        Opacity(
          opacity: 1.0 - _opacity,
          child: Container(color: R.colors.swipeCardBackground),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight / 5,
                child: image,
              ),
              Expanded(
                child: Opacity(
                  opacity: _opacity,
                  child: ReaderMode(processHtmlResult: state.result),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

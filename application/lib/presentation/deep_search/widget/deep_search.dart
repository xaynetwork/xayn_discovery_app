import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/deep_search/manager/deep_search_manager.dart';
import 'package:xayn_discovery_app/presentation/deep_search/manager/deep_search_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/shimmering_feed_view.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

const _deepSearchNavBarConfigId = NavBarConfigId('deepSearchNavBarConfigId');

class DeepSearchScreen extends StatefulWidget {
  const DeepSearchScreen({
    super.key,
    required this.documentId,
  });

  final DocumentId documentId;

  @override
  State<StatefulWidget> createState() => _DeepSearchScreenState();
}

class _DeepSearchScreenState extends State<DeepSearchScreen>
    with
        WidgetsBindingObserver,
        NavBarConfigMixin,
        TooltipStateMixin<DeepSearchScreen>,
        OverlayMixin<DeepSearchScreen>,
        OverlayStateMixin<DeepSearchScreen> {
  late final DeepSearchScreenManager _screenManager =
      di.get(param1: widget.documentId);
  late final CardViewController _cardViewController = CardViewController();

  CardViewController get cardViewController => _cardViewController;

  /// no need to dispose here, handled by the Card Widget itself
  DiscoveryCardController? currentCardController;

  double _dragDistance = .0;

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        _deepSearchNavBarConfigId,
        buildNavBarItemBack(
          onPressed: _screenManager.onBackNavPressed,
        ),
      );

  @override
  OverlayManager get overlayManager => _screenManager.overlayManager;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return _screenManager.handleActivityStatus(true);
      default:
        return _screenManager.handleActivityStatus(false);
    }
  }

  @override
  void dispose() {
    _cardViewController.dispose();
    // featureManager.close();

    WidgetsBinding.instance.removeObserver(this);

    // on dispose, no longer observe any documents
    // this Function's argument is nullable Document, by not passing anything,
    // it stops the observer buffer.
    _screenManager.observeDocument();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return AppScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: R.colors.homePageBackground,
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: BlocBuilder<DeepSearchScreenManager, DeepSearchState>(
          builder: (context, state) => _buildFeedView(state),
          bloc: _screenManager,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(double notchSize) =>
      ShimmeringFeedView(notchSize: notchSize);

  Widget _buildFeedView(DeepSearchState state) {
    return LayoutBuilder(builder: (context, constraints) {
      // transform the cardNotchSize to a fractional value between [0.0, 1.0]
      final notchSize = 1.0 - R.dimen.cardNotchSize / constraints.maxHeight;
      final results =
          state is SearchSuccessState ? state.results : <Document>{};
      final totalResults = results.length;

      // if (state.shouldUpdateNavBar) NavBarContainer.updateNavBar(context);

      if (state is InitState || state is LoadingState) {
        return _buildLoadingIndicator(notchSize);
      }

      if (_screenManager.cardIndex < totalResults &&
          _cardViewController.index != _screenManager.cardIndex) {
        _cardViewController.index = _screenManager.cardIndex;
      }

      void onIndexChanged(int index) {
        _screenManager.handleIndexChanged(index);
      }

      return FeedView(
        key: Keys.deepSearchView,
        cardViewController: _cardViewController,
        itemBuilder: _itemBuilder(
          results: results,
          isPrimary: true,
          isSwipingEnabled: !_screenManager.isFullScreen,
          isFullScreen: _screenManager.isFullScreen,
        ),
        secondaryItemBuilder: _itemBuilder(
          results: results,
          isPrimary: false,
          isSwipingEnabled: true,
          isFullScreen: false,
        ),
        itemCount: totalResults,
        onIndexChanged: totalResults > 0 ? onIndexChanged : null,
        isFullScreen: _screenManager.isFullScreen,
        fullScreenOffsetFraction: _dragDistance / DiscoveryCard.dragThreshold,
        notchSize: notchSize,
        cardIdentifierBuilder: _createUniqueCardIdentity(results),
        noItemsBuilder: _noItemsBuilder,
      );
    });
  }

  Widget Function(BuildContext, int) _itemBuilder({
    required Set<Document> results,
    required bool isPrimary,
    required bool isSwipingEnabled,
    required bool isFullScreen,
  }) =>
      (BuildContext context, int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final document = results.elementAt(normalizedIndex);

        if (isPrimary) {
          _screenManager.handleViewType(
            document,
            isFullScreen ? DocumentViewMode.reader : DocumentViewMode.story,
          );
        }

        final shaderType = _getShaderType(document.resource);
        final card = isFullScreen
            ? DiscoveryCard(
                isPrimary: true,
                document: document,
                onDiscard: () {
                  _screenManager.triggerHapticFeedbackMedium();
                  return _screenManager.handleNavigateOutOfCard(document);
                },
                onDrag: _onFullScreenDrag,
                onController: (controller) =>
                    currentCardController = controller,
                feedType: FeedType.search,
                primaryCardShader: ShaderFactory.fromType(
                  shaderType,
                  transitionToIdle: true,
                ),
              )
            : GestureDetector(
                onTap: () {
                  if (isPrimary) {
                    hideTooltip();
                    _screenManager.maybeNavigateIntoCard(document);
                  } else {
                    _cardViewController.jump(JumpDirection.down);
                  }
                },
                child: DiscoveryFeedCard(
                  isPrimary: isPrimary,
                  document: document,
                  primaryCardShader: ShaderFactory.fromType(shaderType),
                  feedType: FeedType.search,
                ),
              );

        return Semantics(
          button: true,
          child: card,
        );
      };

  String Function(int) _createUniqueCardIdentity(Set<Document> results) =>
      (int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final document = results.elementAt(normalizedIndex);
        return document.documentId.toString();
      };

  Widget _noItemsBuilder(BuildContext context, double? width, double? height) {
    return const Center(
      child: Text('no results available'),
    );
  }

  ShaderType _getShaderType(NewsResource newsResource) {
    // A document doesn't have a unique 'index',
    // and also, the index within the feed is not static, as older
    // documents are removed.
    // So while not ideal, using hashcode to consistently resolve the exact
    // same shader does work:
    switch (newsResource.hashCode % 3) {
      case 0:
        return ShaderType.static;
      case 1:
        return ShaderType.pan;
      default:
        return ShaderType.zoom;
    }
  }

  void _onFullScreenDrag(double distance) =>
      setState(() => _dragDistance = distance.abs());
}

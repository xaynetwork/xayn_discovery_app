import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/app_scrollbar.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/card_menu_indicator.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_header_menu.dart';
import 'package:xayn_discovery_app/presentation/images/widget/arc.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';
import 'package:xayn_readability/xayn_readability.dart' show ProcessHtmlResult;

/// the fraction height of the card image.
/// This value must be in the range of [0.0, 1.0], where 1.0 is the
/// maximum context height.
const double _kImageFractionSize = .4;

/// Implementation of [DiscoveryCardBase] which is used inside the feed view.
class DiscoveryCardStatic extends DiscoveryCardBase {
  DiscoveryCardStatic({
    Key? key,
    required Document document,
    FeedType? feedType,
    OnTtsData? onTtsData,
  }) : super(
          key: key,
          isPrimary: true,
          document: document,
          onTtsData: onTtsData,
          feedType: feedType,
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryCardStaticState();
}

class _DiscoveryCardStaticState
    extends DiscoveryCardBaseState<DiscoveryCardStatic> with OverlayStateMixin {
  late final _scrollController = ScrollController(keepScrollOffset: false);
  double _scrollOffset = .0;

  @override
  OverlayManager get overlayManager => discoveryCardManager.overlayManager;

  @override
  void dispose() {
    super.dispose();

    cardManagersCache.removeObsoleteCardManagers([widget.document]);
  }

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final mediaQuery = MediaQuery.of(context);
    final processedDocument = state.processedDocument;
    final provider = processedDocument?.getProvider(webResource);

    return LayoutBuilder(
      builder: (context, constraints) {
        final elements = DiscoveryCardElements(
          manager: discoveryCardManager,
          document: widget.document,
          explicitDocumentUserReaction: state.explicitDocumentUserReaction,
          title: webResource.title,
          timeToRead: state.processedDocument?.timeToRead ?? '',
          url: webResource.url,
          provider: provider,
          datePublished: webResource.datePublished,
          isInteractionEnabled: true,
          isBookmarkButtonVisible: !featureManager.isDemoModeEnabled,
          isDislikeButtonVisible: !featureManager.isDemoModeEnabled,
          onLikePressed: () => onFeedbackPressed(UserReaction.positive),
          onDislikePressed: () => onFeedbackPressed(UserReaction.negative),
          onProviderSectionTap: () {
            widget.onTtsData?.call(TtsData.disabled());

            discoveryCardManager.openWebResourceUrl(
              widget.document,
              CurrentView.story,
              widget.feedType,
            );
          },
          onToggleTts: () => widget.onTtsData?.call(
            TtsData(
              enabled: true,
              languageCode: widget.document.resource.language,
              uri: widget.document.resource.url,
              html: discoveryCardManager
                  .state.processedDocument?.processHtmlResult.contents,
            ),
          ),
          onBookmarkPressed: () => onBookmarkPressed(feedType: widget.feedType),
          onBookmarkLongPressed: onBookmarkLongPressed(),
          bookmarkStatus: state.bookmarkStatus,
          fractionSize: .0,
          feedType: widget.feedType,
          useLargeTitle: false,
        );

        // Limits the max scroll-away distance,
        // to park the image only just outside the visible range at max, when it finally animates back,
        // then you see it 'falling' back immediately, instead of much, much later if scrolled far away.
        final outerScrollOffset =
            min(_scrollOffset, _kImageFractionSize * mediaQuery.size.height);

        final readerMode = _buildReaderMode(
          processHtmlResult: state.processedDocument?.processHtmlResult,
          size: mediaQuery.size,
          bookmarkStatus: state.bookmarkStatus,
        );

        final imageWidget = Container(
          height: constraints.maxHeight * _kImageFractionSize,
          alignment: Alignment.topCenter,
          child: image,
        );

        final indicator = CardMenuIndicator(
          isInteractionEnabled: widget.isPrimary,
          onOpenHeaderMenu: () {
            widget.onTtsData?.call(TtsData.disabled());

            toggleOverlay(
              builder: (_) => DiscoveryCardHeaderMenu(
                itemsMap: _buildDiscoveryCardHeaderMenuItems,
                source: Source.fromJson(widget.document.resource.url.host),
                onClose: removeOverlay,
              ),
              useRootOverlay: true,
            );
          },
        );

        return AppScrollbar(
          scrollController: _scrollController,
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  child: readerMode,
                ),
                Positioned(
                  top: constraints.maxHeight / 2.5 - _scrollOffset,
                  bottom: (constraints.maxHeight / 3.5) + _scrollOffset,
                  left: 0,
                  right: 0,
                  child: elements,
                ),
                Positioned(
                  top: -outerScrollOffset,
                  left: 0,
                  right: 0,
                  child: imageWidget,
                ),
                Positioned(
                  top: R.dimen.unit2,
                  right: R.dimen.unit2,
                  child: indicator,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildImage() => Arc(
        arcVariation: discoveryCardManager.state.arcVariation,
        child: super.buildImage(),
      );

  Widget _buildReaderMode({
    required ProcessHtmlResult? processHtmlResult,
    required Size size,
    required BookmarkStatus bookmarkStatus,
  }) {
    final imageAndTitleSpace =
        size.height * _kImageFractionSize + R.dimen.unit21;

    final readerMode = ReaderMode(
      scrollController: _scrollController,
      title: title,
      languageCode: widget.document.resource.language,
      uri: widget.document.resource.url,
      processHtmlResult: processHtmlResult,
      padding: EdgeInsets.only(
        left: R.dimen.unit3,
        right: R.dimen.unit3,
        bottom: R.dimen.readerModeBottomPadding,
        top: imageAndTitleSpace,
      ),
      onScroll: (position) => setState(() => _scrollOffset = position),
    );

    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
      bloc: discoveryCardManager,
      builder: (context, state) {
        if (state.bookmarkStatus != bookmarkStatus) {
          NavBarContainer.updateNavBar(context);
        }

        return ClipRRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxWidth: size.width,
            child: readerMode,
          ),
        );
      },
    );
  }

  Map<DiscoveryCardHeaderMenuItemEnum, DiscoveryCardHeaderMenuItem>
      get _buildDiscoveryCardHeaderMenuItems => {
            DiscoveryCardHeaderMenuItemEnum.openInBrowser:
                DiscoveryCardHeaderMenuHelper.buildOpenInBrowserItem(
              onTap: () {
                removeOverlay();
                discoveryCardManager.openWebResourceUrl(
                  widget.document,
                  CurrentView.story,
                  widget.feedType,
                );
              },
            ),
            DiscoveryCardHeaderMenuItemEnum.excludeSource:
                DiscoveryCardHeaderMenuHelper.buildExcludeSourceItem(
              onTap: () {
                removeOverlay();
                discoveryCardManager.onExcludeSource(
                  document: widget.document,
                );
              },
            ),
            DiscoveryCardHeaderMenuItemEnum.includeSource:
                DiscoveryCardHeaderMenuHelper.buildIncludeSourceBackItem(
              onTap: () {
                removeOverlay();
                discoveryCardManager.onIncludeSource(
                  document: widget.document,
                );
              },
            ),
          };
}

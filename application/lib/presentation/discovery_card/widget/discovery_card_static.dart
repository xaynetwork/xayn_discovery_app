import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/app_scrollbar.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_card_headline_image.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/tooltip_controller_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';
import 'package:xayn_readability/xayn_readability.dart' show ProcessHtmlResult;

/// the fraction height of the card image.
/// This value must be in the range of [0.0, 1.0], where 1.0 is the
/// maximum context height.
const double _kImageFractionSize = .4;

/// Implementation of [DiscoveryCardBase] which is used inside the feed view.
class DiscoveryCardStatic extends DiscoveryCardBase {
  const DiscoveryCardStatic({
    Key? key,
    required Document document,
    DiscoveryCardManager? discoveryCardManager,
    ImageManager? imageManager,
    OnTtsData? onTtsData,
  }) : super(
          key: key,
          isPrimary: true,
          document: document,
          discoveryCardManager: discoveryCardManager,
          imageManager: imageManager,
          onTtsData: onTtsData,
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryCardStaticState();
}

class _DiscoveryCardStaticState
    extends DiscoveryCardBaseState<DiscoveryCardStatic>
    with TooltipControllerMixin<DiscoveryCardStatic> {
  late final _scrollController = ScrollController(keepScrollOffset: false);
  double _scrollOffset = .0;

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
          onLikePressed: () => onFeedbackPressed(UserReaction.positive),
          onDislikePressed: () => onFeedbackPressed(UserReaction.negative),
          onOpenUrl: () {
            widget.onTtsData?.call(TtsData.disabled());

            discoveryCardManager.openWebResourceUrl(
              widget.document,
              CurrentView.reader,
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
          onBookmarkPressed: onBookmarkPressed,
          onBookmarkLongPressed: onBookmarkLongPressed(state),
          bookmarkStatus: state.bookmarkStatus,
          fractionSize: .0,
        );

        // Limits the max scroll-away distance,
        // to park the image only just outside the visible range at max, when it finally animates back,
        // then you see it 'falling' back immediately, instead of much, much later if scrolled far away.
        final outerScrollOffset =
            min(_scrollOffset, _kImageFractionSize * mediaQuery.size.height);
        final maskedImage = DiscoveryCardHeadlineImage(child: image);

        return AppScrollbar(
          scrollController: _scrollController,
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildReaderMode(
                  processHtmlResult: state.processedDocument?.processHtmlResult,
                  size: mediaQuery.size,
                  bookmarkStatus: state.bookmarkStatus,
                ),
              ),
              Positioned(
                top: -outerScrollOffset,
                left: 0,
                right: 0,
                child: Container(
                  height: constraints.maxHeight * _kImageFractionSize,
                  alignment: Alignment.topCenter,
                  child: Stack(
                    children: [
                      maskedImage,
                      elements,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReaderMode({
    required ProcessHtmlResult? processHtmlResult,
    required Size size,
    required BookmarkStatus bookmarkStatus,
  }) {
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
        top: size.height * _kImageFractionSize,
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
}

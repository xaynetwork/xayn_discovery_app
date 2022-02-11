import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
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
  }) : super(
          key: key,
          isPrimary: true,
          document: document,
          discoveryCardManager: discoveryCardManager,
          imageManager: imageManager,
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryCardStaticState();
}

class _DiscoveryCardStaticState
    extends DiscoveryCardBaseState<DiscoveryCardStatic> {
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
          explicitDocumentFeedback: state.explicitDocumentFeedback,
          title: webResource.title,
          timeToRead: state.processedDocument?.timeToRead ?? '',
          url: webResource.url,
          provider: provider,
          datePublished: webResource.datePublished,
          onLikePressed: () => discoveryCardManager.onFeedback(
            document: widget.document,
            feedback: state.explicitDocumentFeedback.isRelevant
                ? DocumentFeedback.neutral
                : DocumentFeedback.positive,
          ),
          onDislikePressed: () => discoveryCardManager.onFeedback(
            document: widget.document,
            feedback: state.explicitDocumentFeedback.isIrrelevant
                ? DocumentFeedback.neutral
                : DocumentFeedback.negative,
          ),
          onOpenUrl: () =>
              discoveryCardManager.openWebResourceUrl(widget.document),
          onBookmarkPressed: onBookmarkPressed,
          onBookmarkLongPressed: onBookmarkLongPressed(state),
          isBookmarked: state.isBookmarked,
          fractionSize: .0,
        );

        // Limits the max scroll-away distance,
        // to park the image only just outside the visible range at max, when it finally animates back,
        // then you see it 'falling' back immediately, instead of much, much later if scrolled far away.
        final outerScrollOffset =
            min(_scrollOffset, _kImageFractionSize * mediaQuery.size.height);
        final maskedImage = Container(
          foregroundDecoration: BoxDecoration(
            gradient: buildGradient(),
          ),
          child: image,
        );

        return Stack(
          children: [
            Positioned.fill(
                child: _buildReaderMode(
              processHtmlResult: state.processedDocument?.processHtmlResult,
              size: mediaQuery.size,
              isBookmarked: state.isBookmarked,
            )),
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
        );
      },
    );
  }

  Widget _buildReaderMode({
    required ProcessHtmlResult? processHtmlResult,
    required Size size,
    required bool isBookmarked,
  }) {
    final readerMode = ReaderMode(
      title: title,
      processHtmlResult: processHtmlResult,
      padding: EdgeInsets.only(
        left: R.dimen.unit2,
        right: R.dimen.unit2,
        // todo: bottom offset should compensate for the NavBar, so we need to calculate it
        bottom: R.dimen.unit12,
        top: size.height * _kImageFractionSize,
      ),
      onScroll: (position) => setState(() => _scrollOffset = position),
    );

    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
      bloc: discoveryCardManager,
      builder: (context, state) {
        if (state.isBookmarked != isBookmarked) {
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

  @override
  void discoveryCardStateListener(DiscoveryCardState state) {
    if (state.isBookmarkToggled) {
      showTooltip(
        BookmarkToolTipKeys.bookmarkedToDefault,
        parameters: [
          context,
          widget.document,
          discoveryCardManager.state.processedDocument
              ?.getProvider(widget.document.webResource),
          (tooltipKey) => showTooltip(tooltipKey),
        ],
      );
    }
  }
}

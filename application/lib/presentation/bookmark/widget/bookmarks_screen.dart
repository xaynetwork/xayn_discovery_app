import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_state.dart';
import 'package:xayn_discovery_app/presentation/bookmark/widget/swipeable_bookmark_card.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/utils/semantics_labels.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget_transition/card_widget_transition_mixin.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget_transition/card_widget_transition_wrapper.dart';
import 'package:xayn_discovery_app/presentation/widget/custom_animated_list.dart';

class BookmarksScreen extends StatefulWidget {
  final UniqueId collectionId;

  const BookmarksScreen({Key? key, required this.collectionId})
      : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

const _bookmarksNavBarConfigId = NavBarConfigId('bookmarksNavBarConfigId');

class _BookmarksScreenState extends State<BookmarksScreen>
    with
        NavBarConfigMixin,
        OverlayMixin<BookmarksScreen>,
        CardWidgetTransitionMixin {
  late final _bookmarkManager =
      di.get<BookmarksScreenManager>(param1: widget.collectionId);

  @override
  OverlayManager get overlayManager => _bookmarkManager.overlayManager;

  @override
  void initState() {
    _bookmarkManager.checkIfNeedToShowOnboarding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksScreenManager, BookmarksScreenState>(
      builder: (ctx, state) => Stack(
        children: [
          AppScaffold(
            appToolbarData: AppToolbarData.titleOnly(
                title:
                    state.collectionName ?? R.strings.personalAreaCollections),
            body: state.bookmarks.isEmpty ? Container() : _buildScreen(state),
          ),
          if (state.bookmarks.isEmpty) _buildEmptyScreen()
        ],
      ),
      bloc: _bookmarkManager,
    );
  }

  Widget _buildEmptyScreen() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationPlayer.asset(
                R.linden.assets.lottie.contextual.emptyCollection),
            Text(
              R.strings.bookmarkScreenNoArticles,
              style: R.styles.xlBoldStyle,
            ),
          ],
        ),
      );

  Widget _buildScreen(BookmarksScreenState state) {
    final list = CustomAnimatedList<Bookmark>(
      items: state.bookmarks,
      itemBuilder: (_, index, __, bookmark) {
        final card = CardWidgetTransitionWrapper(
          onAnimationDone: () => _bookmarkManager.onBookmarkLongPressed(
            bookmarkId: bookmark.id,
            onClose: closeCardWidgetTransition,
          ),
          onLongPress: _bookmarkManager.triggerHapticFeedbackMedium,
          child: _createBookmarkCard(context, bookmark, index),
        );
        return Padding(
          padding: EdgeInsets.only(bottom: R.dimen.unit2),
          child: card,
        );
      },
      areItemsTheSame: (a, b) => a.id == b.id,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
      child: list,
    );
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        _bookmarksNavBarConfigId,
        buildNavBarItemBack(
          onPressed: _bookmarkManager.onBackNavPressed,
        ),
      );

  Widget _createBookmarkCard(
          BuildContext context, Bookmark bookmark, int bookmarkIndex) =>
      SwipeableBookmarkCard(
        onMove: _bookmarkManager.onMoveSwipe,
        onDelete: _bookmarkManager.onDeleteSwipe,
        bookmarkId: bookmark.id,
        child: CardWidget(
          cardData: CardData.bookmark(
            key: Key(bookmark.title),
            title: bookmark.title,
            onPressed: () => _bookmarkManager.onBookmarkPressed(
              bookmarkId: bookmark.id,
              isPrimary: false,
            ),
            backgroundImage: bookmark.image,
            created: DateTime.parse(bookmark.createdAt),
            provider: bookmark.provider,
            // Screenwidth - 2 * side paddings
            cardWidth: MediaQuery.of(context).size.width - 2 * R.dimen.unit3,
            semanticsLabel: SemanticsLabels.generateBookmarkItemLabel(
              bookmarkIndex,
            ),
          ),
        ),
        onFling: () => _bookmarkManager.triggerHapticFeedbackMedium(),
      );
}

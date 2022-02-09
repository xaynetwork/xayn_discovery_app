import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_state.dart';
import 'package:xayn_discovery_app/presentation/bookmark/widget/swipeable_bookmark_card.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_bookmark_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class BookmarksScreen extends StatefulWidget {
  final UniqueId collectionId;

  const BookmarksScreen({Key? key, required this.collectionId})
      : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with NavBarConfigMixin, TooltipStateMixin {
  late final _bookmarkManager =
      di.get<BookmarksScreenManager>(param1: widget.collectionId);
  final VoidCallback _dispose =
      CardManagers.registerCardManagerCacheInDi('bookmarks');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksScreenManager, BookmarksScreenState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.titleOnly(
              title: state.collectionName ?? R.strings.personalAreaCollections),
        ),
        body:
            state.bookmarks.isEmpty ? _buildEmptyScreen() : _buildScreen(state),
      ),
      bloc: _bookmarkManager,
    );
  }

  Widget _buildEmptyScreen() => Padding(
        child: Center(
          child: Text(
            R.strings.bookmarkScreenNoArticles,
            style: R.styles.appScreenHeadline,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
      );

  Widget _buildScreen(BookmarksScreenState state) {
    final list = ListView.builder(
      itemBuilder: (context, i) =>
          _createBookmarkCard(context, state.bookmarks[i]),
      itemCount: state.bookmarks.length,
    );
    return Padding(
      child: list,
      padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
    );
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(buildNavBarItemBack(
        onPressed: _bookmarkManager.onBackNavPressed,
      ));

  Widget _createBookmarkCard(BuildContext context, Bookmark bookmark) =>
      Padding(
        padding: EdgeInsets.only(bottom: R.dimen.unit2),
        child: SwipeableBookmarkCard(
          onMove: (UniqueId bookmarkId) {
            _showMoveBookmarkBottomSheet(context, bookmarkId);
          },
          onDelete: (UniqueId bookmarkId) {
            _bookmarkManager.removeBookmark(bookmarkId);
          },
          bookmarkId: bookmark.id,
          child: CardWidget(
            cardData: CardData.bookmark(
              key: Key(bookmark.title),
              title: bookmark.title,
              onPressed: () => _bookmarkManager.onBookmarkPressed(
                  bookmarkId: bookmark.id, isPrimary: false),
              onLongPressed: () {},
              backgroundImage: bookmark.image,
              created: DateTime.parse(bookmark.createdAt),
              provider: bookmark.provider,
              // Screenwidth - 2 * side paddings
              cardWidth: MediaQuery.of(context).size.width - 2 * R.dimen.unit3,
            ),
          ),
        ),
      );

  void _showMoveBookmarkBottomSheet(
    BuildContext context,
    UniqueId bookmarkId,
  ) {
    showAppBottomSheet(
      context,
      builder: (_) => MoveBookmarkToCollectionBottomSheet(
        bookmarkId: bookmarkId,
        onError: (tooltipKey) => showTooltip(context, tooltipKey),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}

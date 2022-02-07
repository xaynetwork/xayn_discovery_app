import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_state.dart';
import 'package:xayn_discovery_app/presentation/bookmark/widget/swipeable_bookmark_card.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/widget/move_bookmark_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget.dart';
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
    with NavBarConfigMixin {
  late final _bookmarkManager =
      di.get<BookmarksScreenManager>(param1: widget.collectionId);
  final VoidCallback _dispose =
      CardManagers.registerCardManagerCacheInDi('bookmarks');
  GlobalKey? _animatedWidgetKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<BookmarksScreenManager, BookmarksScreenState>(
          builder: (ctx, state) => Scaffold(
              appBar: AppToolbar(
                appToolbarData: AppToolbarData.titleOnly(
                    title: state.collectionName ??
                        R.strings.personalAreaCollections),
              ),
              body: state.bookmarks.isEmpty
                  ? _buildEmptyScreen()
                  : _buildScreen(state)),
          bloc: _bookmarkManager,
        ),
        if (_animatedWidgetKey != null)
          AnimatedCard(
            childKey: _animatedWidgetKey!,
            onTapOutside: () {
              setState(() {
                _animatedWidgetKey = null;
              });
            },
          ),
      ],
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

  final _keys = <UniqueId, GlobalKey>{};

  Widget _createBookmarkCard(BuildContext context, Bookmark bookmark) {
    final childGlobalKey = _keys.putIfAbsent(bookmark.id, () => GlobalKey());
    return Padding(
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
            key: childGlobalKey,
            title: bookmark.title,
            onPressed: () => _bookmarkManager.onBookmarkPressed(
                bookmarkId: bookmark.id, isPrimary: false),
            onLongPressed: () {
              setState(() {
                _animatedWidgetKey = childGlobalKey;
              });
            },
            backgroundImage: bookmark.image,
            created: DateTime.parse(bookmark.createdAt),
            provider: bookmark.provider,
            // Screenwidth - 2 * side paddings
            cardWidth: MediaQuery.of(context).size.width - 2 * R.dimen.unit3,
          ),
        ),
      ),
    );
  }

  void _showMoveBookmarkBottomSheet(
    BuildContext context,
    UniqueId bookmarkId,
  ) {
    showAppBottomSheet(
      context,
      builder: (_) => MoveBookmarkToCollectionBottomSheet(
        bookmarkId: bookmarkId,
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}

class AnimatedCard extends StatefulWidget {
  final GlobalKey childKey;
  final VoidCallback onTapOutside;

  const AnimatedCard({
    Key? key,
    required this.childKey,
    required this.onTapOutside,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
  final _stackKey = GlobalKey();
  Animation<double>? _animation;

  Offset? _childPosition;

  @override
  void initState() {
    _checkPositions();
    super.initState();
  }

  void _checkPositions() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final childRenderBox =
          widget.childKey.currentContext?.findRenderObject() as RenderBox?;
      final stackRenderBox =
          _stackKey.currentContext?.findRenderObject() as RenderBox?;
      if (childRenderBox == null || stackRenderBox == null) {
        _checkPositions();
        return;
      }

      _childPosition = childRenderBox.localToGlobal(Offset.zero);
      final childHeight = childRenderBox.size.height;
      final childWidth = childRenderBox.size.width;
      final stackHeight = stackRenderBox.size.height;
      setState(() {
        _animation = Tween<double>(
                begin: _childPosition!.dy,
                end: stackHeight / 2 - childHeight / 2)
            .animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
        ));
        _controller.forward();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    final child = widget.childKey.currentWidget;

    if (animation == null || child == null) {
      return Stack(
        key: _stackKey,
        children: const [],
      );
    }

    return GestureDetector(
      onTap: () {
        _controller.reverse().then((_) => widget.onTapOutside());
      },
      child: Container(
        /// needs to be animated
        color: Colors.black87,
        child: Stack(
          key: _stackKey,
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? _) {
                return Positioned(
                  left: _childPosition!.dx,
                  top: animation.value,
                  child: child,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

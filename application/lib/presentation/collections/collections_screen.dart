import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/collection_options/collection_options_menu.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_collection/widget/create_or_rename_collection.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_state.dart';
import 'package:xayn_discovery_app/presentation/collections/swipeable_collection_card.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

import 'manager/collection_card_state.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen>
    with NavBarConfigMixin, CollectionCardManagersMixin, BottomSheetBodyMixin {
  CollectionsScreenManager? _collectionsScreenManager;

  @override
  void initState() {
    _initManager();
    super.initState();
  }

  void _initManager() {
    di.getAsync<CollectionsScreenManager>().then((it) {
      setState(() {
        _collectionsScreenManager = it;
      });
    });
  }

  @override
  void dispose() {
    _collectionsScreenManager?.close();
    super.dispose();
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        buildNavBarItemBack(
          onPressed: () => _collectionsScreenManager?.onBackNavPressed(),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.withTrailingIcon(
            title: R.strings.collectionsScreenTitle,
            iconPath: R.assets.icons.plus,
            onPressed: () => _showAddCollectionBottomSheet(),
          ),
        ),
        body: _buildBody(),
      );

  Widget _buildBody() {
    if (_collectionsScreenManager == null) {
      return Container();
    }
    Widget screenBloc =
        BlocBuilder<CollectionsScreenManager, CollectionsScreenState>(
      bloc: _collectionsScreenManager,
      builder: _buildScreen,
    );

    return ScreenStateSwitcher(child: screenBloc);
  }

  Widget _buildScreen(
    BuildContext context,
    CollectionsScreenState screenState,
  ) {
    final list = ListView.builder(
      itemCount: screenState.collections.length,
      itemBuilder: (_, index) => _buildCard(
        screenState.collections[index],
      ),
    );

    final bottomPadding = R.dimen.unit2;
    final sidePadding = R.dimen.unit3;
    final withPadding = Padding(
      child: list,
      padding: EdgeInsets.fromLTRB(
        sidePadding,
        0,
        sidePadding,
        bottomPadding,
      ),
    );
    return withPadding;
  }

  Widget _buildCard(Collection collection) {
    late Widget card;
    if (collection.isDefault) {
      card = _buildBaseCard(collection);
    } else {
      card = _buildSwipeableCard(collection);
    }
    return Padding(
      padding: EdgeInsets.only(bottom: R.dimen.unit2),
      child: card,
    );
  }

  Widget _buildBaseCard(Collection collection) =>
      BlocBuilder<CollectionCardManager, CollectionCardState>(
        bloc: managerOf(collection.id),
        builder: (context, cardState) {
          final cardKey = Keys.generateCollectionsScreenCardKey(
            collection.id.toString(),
          );
          return CardWidget(
            key: cardKey,
            cardData: CardData.collectionsScreen(
              key: cardKey,
              title: collection.name,
              onPressed: () =>
                  _collectionsScreenManager?.onCollectionPressed(collection.id),
              onLongPressed: () => _showCollectionCardOptions(collection.id),
              numOfItems: cardState.numOfItems,
              backgroundImage: cardState.image,
              color: R.colors.collectionsScreenCard,
              // Screenwidth - 2 * side paddings
              cardWidth: MediaQuery.of(context).size.width - 2 * R.dimen.unit3,
            ),
          );
        },
      );

  Widget _buildSwipeableCard(Collection collection) => SwipeableCollectionCard(
        collectionCard: _buildBaseCard(collection),
      );

  _showAddCollectionBottomSheet() {
    showAppBottomSheet(
      context,
      builder: (buildContext) => CreateOrRenameCollectionBottomSheet(),
    );
  }

  _showCollectionCardOptions(UniqueId collectionId) {
    showAppBottomSheet(
      context,
      builder: (buildContext) => CollectionOptionsBottomSheet(
        collectionId: collectionId,
      ),
    );
  }
}

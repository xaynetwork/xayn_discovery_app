import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_state.dart';
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
    with NavBarConfigMixin {
  CollectionsScreenManager? _collectionsScreenManager;
  late final CollectionCardManager _collectionCardManager;

  @override
  void initState() {
    _initManagers();
    super.initState();
  }

  void _initManagers() {
    _collectionCardManager = di.get();
    di.getAsync<CollectionsScreenManager>().then((it) {
      setState(() {
        _collectionsScreenManager = it;
      });
    });
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        buildNavBarItemBack(
          onPressed: () => _collectionsScreenManager?.onBackNavPressed(),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.withTrailingIcon(
            title: R.strings.collectionsScreenTitle,
            iconPath: R.assets.icons.plus,
            onPressed: () {
              _showTemporaryAlertDialog(_collectionsScreenManager!);
            },
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
      shrinkWrap: true,
      itemCount: screenState.collections.length,
      itemBuilder: (_, index) => _buildCard(screenState.collections[index]),
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
    _collectionCardManager.retrieveCollectionCardInfo(collection.id);
    return BlocBuilder<CollectionCardManager, CollectionCardState>(
      bloc: _collectionCardManager,
      builder: (context, cardState) {
        final card = CardWidget(
          key: Keys.generateCollectionsScreenCardKey(
            collection.id.toString(),
          ),
          cardData: CardData.collectionsScreen(
            title: collection.name,
            onPressed: () => throw UnimplementedError(),
            onLongPressed: () => throw UnimplementedError(),
            numOfItems: cardState.numOfItems,
            backgroundImage: cardState.image,
            color: R.colors.collectionsScreenCard,
          ),
        );
        return Padding(
          padding: EdgeInsets.only(bottom: R.dimen.unit2),
          child: card,
        );
      },
    );
  }

  /// Temporary dialog implemented in order to test the functionality
  /// Will be removed when the bottom sheet will be ready
  void _showTemporaryAlertDialog(CollectionsScreenManager _manager) async {
    String collectionName = '';

    // ignore: prefer_function_declarations_over_variables
    final dialog = (CollectionsScreenState state) => AlertDialog(
          title: const Text('Create collection'),
          content: TextField(
            onChanged: (value) {
              collectionName = value;
            },
            decoration: InputDecoration(
              hintText: 'Collection name',
              errorText: state.errorMsg,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                final collection = await _manager.createCollection(
                  collectionName: collectionName,
                );
                if (collection != null) {
                  Navigator.pop(context);
                }
              },
            )
          ],
        );
    final builder =
        BlocBuilder<CollectionsScreenManager, CollectionsScreenState>(
      bloc: _manager,
      builder: (_, state) => dialog(state),
    );

    await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => builder,
    );
  }
}

import 'dart:async';

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
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar.dart';

import 'manager/collection_card_state.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen>
    with NavBarConfigMixin {
  late final CollectionsScreenManager? _collectionsScreenManager;
  late final CollectionCardManager _collectionCardManager;
  late final StreamController<CollectionsScreenManager>
      _collectionsScreenManagerStream;

  @override
  void initState() {
    _initManagers();
    super.initState();
  }

  void _initManagers() {
    _collectionsScreenManagerStream = StreamController();
    _collectionCardManager = di.get();
    di.getAsync<CollectionsScreenManager>().then((it) {
      _collectionsScreenManager = it;
      _collectionsScreenManagerStream.add(it);
    });
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        buildNavBarItemBack(
          onPressed: () {
            if (_collectionsScreenManager != null) {
              _collectionsScreenManager!.onBackNavPressed();
            }
          },
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const AppToolbar(
          yourTitle: Strings.collectionsScreenHeader,
        ),
        body: StreamBuilder<CollectionsScreenManager>(
          stream: _collectionsScreenManagerStream.stream,
          builder: (_, snapshot) {
            return _buildBody(snapshot.data);
          },
        ),
      );

  Widget _buildBody(CollectionsScreenManager? manager) {
    if (manager == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget screenBloc =
        BlocBuilder<CollectionsScreenManager, CollectionsScreenState>(
      bloc: manager,
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
    return SingleChildScrollView(child: withPadding);
  }

  Widget _buildCard(Collection collection) {
    _collectionCardManager.retrieveCollectionCardInfo(collection.id);
    return BlocBuilder<CollectionCardManager, CollectionCardState>(
      bloc: _collectionCardManager,
      builder: (context, cardState) {
        return CardWidget(
          key: Keys.generateCollectionsScreenCardKey(
            collection.id.toString(),
          ),
          cardData: CardData.collectionsScreen(
            title: collection.name,
            onPressed: () {
              throw UnimplementedError();
            },
            onLongPressed: () {
              throw UnimplementedError();
            },
            numOfItems: cardState.numOfItems,
            backgroundImage: cardState.image,
            color: R.colors.collectionsScreenCard,
          ),
        );
      },
    );
  }
}

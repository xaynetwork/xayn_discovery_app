import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/collection_options/collection_options_menu.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/delete_collection_confirmation_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_state.dart';
import 'package:xayn_discovery_app/presentation/collections/swipeable_collection_card.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/new_personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/new_personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/payment/payment_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget_transition/card_widget_transition_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget_transition/card_widget_transition_wrapper.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/custom_animated_list.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class NewPersonalAreaScreen extends StatefulWidget {
  const NewPersonalAreaScreen({Key? key}) : super(key: key);

  @override
  NewPersonalAreaScreenState createState() => NewPersonalAreaScreenState();
}

class NewPersonalAreaScreenState extends State<NewPersonalAreaScreen>
    with
        NavBarConfigMixin,
        TooltipStateMixin,
        CollectionCardManagersMixin,
        BottomSheetBodyMixin,
        CardWidgetTransitionMixin {
  NewPersonalAreaManager? _manager;

  @override
  void initState() {
    _initManager();
    super.initState();
  }

  void _initManager() {
    di.getAsync<NewPersonalAreaManager>().then((it) {
      setState(() {
        _manager = it;
      });
    });
  }

  @override
  void dispose() {
    _manager?.close();
    super.dispose();
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig(
        configIdPersonalArea,
        [
          buildNavBarItemHome(onPressed: () {
            hideTooltip();
            _manager?.onHomeNavPressed();
          }),
          buildNavBarItemSearch(onPressed: () {
            hideTooltip();
            _manager?.onActiveSearchNavPressed();
          }),
          buildNavBarItemPersonalArea(
            isActive: true,
            onPressed: () {
              // nothing to do, we already on this screen :)
              hideTooltip();
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.withTrailingIcon(
            title: R.strings.personalAreaTitle,
            iconPath: R.assets.icons.plus,
            onPressed: () => _showAddCollectionBottomSheet(),
          ),
        ),
        body: _buildBody(),
      );

  Widget _buildBody() {
    if (_manager == null) {
      return Container();
    }
    Widget screenBloc =
        BlocBuilder<NewPersonalAreaManager, NewPersonalAreaState>(
      bloc: _manager,
      builder: _buildList,
    );

    return ScreenStateSwitcher(child: screenBloc);
  }

  Widget _buildList(
    BuildContext context,
    NewPersonalAreaState screenState,
  ) {
    final list = CustomAnimatedList<ListItemModel>(
      items: screenState.items,
      itemBuilder: (_, index, __, item) {
        if (item.isTrialBanner) {
          return _buildTrialBanner(item.trialEndDate!);
        }
        return _buildCard(
          item.collection!,
        );
      },
      areItemsTheSame: (a, b) => a.id == b.id,
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
      card = CardWidgetTransitionWrapper(
        key: ValueKey(collection.id),
        onAnimationDone: () => _showCollectionCardOptions(collection),
        onLongPress: _manager?.triggerHapticFeedbackMedium,
        child: _buildSwipeableCard(collection),
      );
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
          return CardWidget(
            cardData: CardData.collectionsScreen(
              key: Keys.generateCollectionsScreenCardKey(
                collection.id.toString(),
              ),
              title: collection.name,
              onPressed: () => _manager?.onCollectionPressed(collection.id),
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
        onSwipeOptionTap: _onSwipeOptionsTap(collection),
        onFling: _manager?.triggerHapticFeedbackMedium,
      );

  Widget _buildTrialBanner(DateTime trialEndDate) => Padding(
        padding: EdgeInsets.only(bottom: R.dimen.unit2),
        child: SubscriptionTrialBanner(
          trialEndDate: trialEndDate,
          onPressed: () => showAppBottomSheet(
            context,
            builder: (_) => PaymentBottomSheet(),
          ),
        ),
      );

  _showAddCollectionBottomSheet() {
    showAppBottomSheet(
      context,
      builder: (buildContext) => CreateOrRenameCollectionBottomSheet(),
    );
  }

  _showCollectionCardOptions(Collection collection) {
    showAppBottomSheet(
      context,
      showBarrierColor: false,
      builder: (buildContext) => CollectionOptionsBottomSheet(
        collection: collection,

        /// Close the route with the focused card
        onSystemPop: closeCardWidgetTransition,
      ),
    );
  }

  Map<SwipeOptionCollectionCard, VoidCallback> _onSwipeOptionsTap(
          Collection collection) =>
      {
        SwipeOptionCollectionCard.edit: () => showAppBottomSheet(
              context,
              builder: (_) => CreateOrRenameCollectionBottomSheet(
                collection: collection,
              ),
            ),
        SwipeOptionCollectionCard.remove: () => showAppBottomSheet(
              context,
              builder: (_) => DeleteCollectionConfirmationBottomSheet(
                collectionId: collection.id,
              ),
            ),
      };
}

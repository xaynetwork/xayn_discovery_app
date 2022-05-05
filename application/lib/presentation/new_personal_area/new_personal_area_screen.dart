import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_subscription_window_event.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/collection_options/collection_options_menu.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/contact_info/contact_info_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/delete_collection_confirmation_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_state.dart';
import 'package:xayn_discovery_app/presentation/collections/swipeable_collection_card.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/new_personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/new_personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/payment/payment_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/model/app_toolbar_icon_model.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget_transition/card_widget_transition_mixin.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget_transition/card_widget_transition_wrapper.dart';
import 'package:xayn_discovery_app/presentation/widget/custom_animated_list.dart';

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
  late final NewPersonalAreaManager _manager = di.get();

  @override
  void dispose() {
    _manager.close();
    super.dispose();
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig(
        configIdPersonalArea,
        [
          buildNavBarItemHome(onPressed: () {
            hideTooltip();
            _manager.onHomeNavPressed();
          }),
          buildNavBarItemSearch(onPressed: () {
            hideTooltip();
            _manager.onActiveSearchNavPressed();
          }),
          buildNavBarItemPersonalArea(
            isActive: true,
            onPressed: hideTooltip,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        appToolbarData: AppToolbarData.withTwoTrailingIcons(
          title: R.strings.personalAreaTitle,
          iconModels: [
            AppToolbarIconModel(
              iconPath: R.assets.icons.plus,
              onPressed: _showAddCollectionBottomSheet,
            ),
            AppToolbarIconModel(
              iconPath: R.assets.icons.gear,
              onPressed: _manager.onSettingsNavPressed,
              iconKey: Keys.personalAreaIconSettings,
            ),
          ],
        ),
        body: _buildBody(),
      );

  Widget _buildBody() =>
      BlocBuilder<NewPersonalAreaManager, NewPersonalAreaState>(
        bloc: _manager,
        builder: _buildList,
      );

  Widget _buildList(
    BuildContext context,
    NewPersonalAreaState screenState,
  ) {
    final list = CustomAnimatedList<ListItemModel>(
      items: screenState.items,
      itemBuilder: (_, index, __, item) {
        final child = item.map(
          collection: (itemModel) => _buildCard(
            itemModel.collection,
          ),
          payment: (itemModel) => _buildTrialBanner(
            itemModel.trialEndDate,
          ),
          contact: (_) => _buildContact(),
        );
        final isLastItem = index == screenState.items.length - 1;
        return isLastItem ? _withBottomPadding(child) : child;
      },
      areItemsTheSame: (a, b) => a.id == b.id,

      /// When opening the personal area screen and the collection list contains
      /// only one item (the default one), don't animate
      forceWithoutAnimation: screenState.items.length == 1,
    );

    final sidePadding = R.dimen.unit3;
    final withPadding = Padding(
      child: list,
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
    );
    return withPadding;
  }

  Widget _buildCard(Collection collection) {
    late Widget card;

    card = collection.isDefault
        ? _buildBaseCard(collection)
        : card = CardWidgetTransitionWrapper(
            key: ValueKey(collection.id),
            onAnimationDone: () => _showCollectionCardOptions(collection),
            onLongPress: _manager.triggerHapticFeedbackMedium,
            child: _buildSwipeableCard(collection),
          );

    return Padding(
      padding: EdgeInsets.only(bottom: R.dimen.unit2),
      child: card,
    );
  }

  Widget _buildBaseCard(Collection collection) =>
      BlocBuilder<CollectionCardManager, CollectionCardState>(
        bloc: managerOf(collection.id),
        builder: (context, cardState) {
          final sidePaddings = 2 * R.dimen.unit3;
          return CardWidget(
            cardData: CardData.collectionsScreen(
              key: Keys.generateCollectionsScreenCardKey(
                collection.id.toString(),
              ),
              title: collection.name,
              onPressed: () => _manager.onCollectionPressed(collection.id),
              numOfItems: cardState.numOfItems,
              backgroundImage: cardState.image,
              color: R.colors.collectionsScreenCard,
              // Screenwidth - 2 * side paddings
              cardWidth: R.dimen.screenWidth - sidePaddings,
            ),
          );
        },
      );

  Widget _buildSwipeableCard(Collection collection) => SwipeableCollectionCard(
        collectionCard: _buildBaseCard(collection),
        onSwipeOptionTap: _onSwipeOptionsTap(collection),
        onFling: _manager.triggerHapticFeedbackMedium,
      );

  Widget _buildTrialBanner(DateTime trialEndDate) => Padding(
        padding: EdgeInsets.only(bottom: R.dimen.unit2),
        child: SubscriptionTrialBanner(
            trialEndDate: trialEndDate,
            onPressed: () {
              _manager.onSubscriptionWindowOpened(
                currentView: SubscriptionWindowCurrentView.personalArea,
              );
              showAppBottomSheet(
                context,
                builder: (_) => PaymentBottomSheet(
                  onClosePressed: () => _manager.onSubscriptionWindowClosed(
                    currentView: SubscriptionWindowCurrentView.personalArea,
                  ),
                ),
              );
            }),
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

  Widget _withBottomPadding(Widget child) {
    final padding = (R.dimen.navBarBottomPadding * 2) + R.dimen.navBarHeight;
    return Padding(padding: EdgeInsets.only(bottom: padding), child: child);
  }

  SettingsCard _buildContact() {
    final data = SettingsCardData.fromTile(SettingsTileData(
      title: R.strings.settingsContactUs,
      svgIconPath: R.assets.icons.info,
      action: SettingsTileActionIcon(
        key: Keys.settingsContactUs,
        svgIconPath: R.assets.icons.arrowRight,
        onPressed: _showContactInfo,
      ),
    ));
    return SettingsCard(data: data);
  }

  _showContactInfo() {
    showAppBottomSheet(
      context,
      builder: (buildContext) => ContactInfoBottomSheet(
        onXaynSupportEmailTap: () => _manager.openExternalEmail(
            Constants.xaynSupportEmail, CurrentView.settings),
        onXaynPressEmailTap: () => _manager.openExternalEmail(
            Constants.xaynPressEmail, CurrentView.settings),
        onXaynUrlTap: () => _manager.openExternalUrl(
          url: Constants.xaynUrl,
          currentView: CurrentView.settings,
        ),
      ),
    );
  }
}

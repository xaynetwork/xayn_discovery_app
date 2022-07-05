import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/collection_card/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collection_card/manager/collection_card_state.dart';
import 'package:xayn_discovery_app/presentation/collection_card/swipeable_collection_card.dart';
import 'package:xayn_discovery_app/presentation/collection_card/util/collection_card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/semantics_labels.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/model/app_toolbar_icon_model.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget_transition/card_widget_transition_mixin.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_widget_transition/card_widget_transition_wrapper.dart';
import 'package:xayn_discovery_app/presentation/widget/custom_animated_list.dart';

class PersonalAreaScreen extends StatefulWidget {
  const PersonalAreaScreen({Key? key}) : super(key: key);

  @override
  PersonalAreaScreenState createState() => PersonalAreaScreenState();
}

class PersonalAreaScreenState extends State<PersonalAreaScreen>
    with
        NavBarConfigMixin,
        TooltipStateMixin,
        BottomSheetBodyMixin,
        OverlayMixin<PersonalAreaScreen>,
        CardWidgetTransitionMixin {
  late final PersonalAreaManager _manager = di.get();
  late final CollectionCardManagersCache _collectionCardManagersCache =
      di.get();

  @override
  void initState() {
    _manager.checkIfNeedToShowOnboarding();
    super.initState();
  }

  @override
  OverlayManager get overlayManager => _manager.overlayManager;

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
              onPressed: _manager.onAddCollectionPressed,
              semanticsLabel: SemanticsLabels.personalAreaIconPlus,
            ),
            AppToolbarIconModel(
              iconPath: R.assets.icons.gear,
              onPressed: _manager.onSettingsNavPressed,
              iconKey: Keys.personalAreaIconSettings,
              semanticsLabel: SemanticsLabels.personalAreaIconSettings,
            ),
          ],
        ),
        body: _buildBody(),
      );

  Widget _buildBody() => BlocBuilder<PersonalAreaManager, PersonalAreaState>(
        bloc: _manager,
        builder: _buildList,
      );

  Widget _buildList(
    BuildContext context,
    PersonalAreaState screenState,
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
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: list,
    );
    return withPadding;
  }

  Widget _buildCard(Collection collection) {
    late Widget card;

    card = collection.isDefault
        ? _buildBaseCard(collection)
        : card = CardWidgetTransitionWrapper(
            key: ValueKey(collection.id),
            onAnimationDone: () => _manager.onCollectionLongPress(
              collection,
              closeCardWidgetTransition,
            ),
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
        bloc: _collectionCardManagersCache.managerOf(collection.id),
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
              semanticsLabel:
                  SemanticsLabels.generateCollectionItemLabel(collection.index),
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
          onPressed: _manager.onPaymentTrialBannerPressed,
        ),
      );

  Map<SwipeOptionCollectionCard, VoidCallback> _onSwipeOptionsTap(
          Collection collection) =>
      {
        SwipeOptionCollectionCard.edit: () =>
            _manager.onCollectionSwipeEdit(collection),
        SwipeOptionCollectionCard.remove: () =>
            _manager.onCollectionSwipeRemove(collection),
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
        onPressed: _manager.onContactPressed,
      ),
    ));
    return SettingsCard(data: data);
  }
}

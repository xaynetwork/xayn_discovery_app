import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';

class PersonalAreaScreen extends StatefulWidget {
  const PersonalAreaScreen({Key? key}) : super(key: key);

  @override
  PersonalAreaScreenState createState() => PersonalAreaScreenState();
}

class PersonalAreaScreenState extends State<PersonalAreaScreen>
    with NavBarConfigMixin, TooltipStateMixin {
  late final PersonalAreaManager _manager = di.get();

  @override
  NavBarConfig get navBarConfig => NavBarConfig(
        [
          buildNavBarItemHome(onPressed: () {
            hideTooltip();
            _manager.onHomeNavPressed();
          }),
          buildNavBarItemSearch(
            isDisabled: true,
            onPressed: () => showTooltip(
              TooltipKeys.activeSearchDisabled,
              style: TooltipStyle.arrowDown,
            ),
          ),
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
  Widget build(BuildContext context) {
    final bloc = BlocBuilder<PersonalAreaManager, PersonalAreaState>(
      bloc: _manager,
      builder: (_, state) =>
          _buildScreen(state.subscriptionStatus?.trialEndDate),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppToolbar(
        appToolbarData: AppToolbarData.titleOnly(
          title: R.strings.personalAreaTitle,
        ),
      ),
      body: bloc,
    );
  }

  Widget _buildScreen(DateTime? trialEndDate) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildItems(trialEndDate),
    );
    final bottomPadding = R.dimen.navBarHeight + R.dimen.unit2;
    final sidePadding = R.dimen.unit3;
    final withPadding = Padding(
      child: column,
      padding: EdgeInsets.fromLTRB(
        sidePadding,
        0,
        sidePadding,
        bottomPadding,
      ),
    );
    return SingleChildScrollView(child: withPadding);
  }

  List<Widget> _buildItems(DateTime? trialEndDate) => [
        if (trialEndDate != null) _buildTrialBanner(trialEndDate),
        _buildCollection(),
        _buildHomeFeed(),
        _buildSettings(),
      ]
          .map((e) => Padding(
                padding: EdgeInsets.only(bottom: R.dimen.unit2),
                child: e,
              ))
          .toList();

  Widget _buildTrialBanner(DateTime trialEndDate) => SubscriptionTrialBanner(
        trialEndDate: trialEndDate,
        onPressed: () {}, // TODO: Show the payment screen
      );

  CardWidget _buildCollection() => CardWidget(
        cardData: CardData.personalArea(
          title: R.strings.personalAreaCollections,
          color: R.colors.personalAreaCollections,
          svgIconPath: R.assets.icons.book,
          svgBackgroundPath: R.assets.graphics.formsOrange,
          onPressed: _manager.onCollectionsNavPressed,
          key: Keys.personalAreaCardCollections,
        ),
      );

  CardWidget _buildHomeFeed() => CardWidget(
        cardData: CardData.personalArea(
          title: R.strings.personalAreaHomeFeed,
          color: R.colors.personalAreaHomeFeed,
          svgIconPath: R.assets.icons.confetti,
          svgBackgroundPath: R.assets.graphics.formsGreen,
          onPressed: _manager.onHomeFeedSettingsNavPressed,
          key: Keys.personalAreaCardHomeFeed,
        ),
      );

  CardWidget _buildSettings() => CardWidget(
        cardData: CardData.personalArea(
          title: R.strings.personalAreaSettings,
          color: R.colors.personalAreaSettings,
          svgIconPath: R.assets.icons.gear,
          svgBackgroundPath: R.assets.graphics.formsPurple,
          onPressed: _manager.onSettingsNavPressed,
          key: Keys.personalAreaCardSettings,
        ),
      );
}

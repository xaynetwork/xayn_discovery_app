import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/payment/payment_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/spans.dart';

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
      builder: (_, state) => _buildScreen(state),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppToolbar(
        appToolbarData: AppToolbarData.withTrailingIcon(
          title: R.strings.personalAreaTitle,
          iconPath: R.assets.icons.gear,
          onPressed: _manager.onSettingsNavPressed,
          iconkey: Keys.personalAreaIconSettings,
        ),
      ),
      body: bloc,
    );
  }

  Widget _buildScreen(PersonalAreaState state) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildItems(state),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
    final bottomPadding = R.dimen.navBarHeight + R.dimen.unit5;
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

  List<Widget> _buildItems(PersonalAreaState state) {
    final buildTrialBanner =
        state.isPaymentEnabled && state.subscriptionStatus.isFreeTrialActive;
    return [
      if (buildTrialBanner)
        _buildTrialBanner(state.subscriptionStatus.trialEndDate!),
      _buildCollection(),
      _buildContactSection(),
    ]
        .map((e) => Padding(
              padding: EdgeInsets.only(bottom: R.dimen.unit2),
              child: e,
            ))
        .toList();
  }

  Widget _buildTrialBanner(DateTime trialEndDate) => SubscriptionTrialBanner(
        trialEndDate: trialEndDate,
        onPressed: () => showAppBottomSheet(
          context,
          builder: (_) => PaymentBottomSheet(),
        ),
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

  Widget _buildContactSection() {
    void onXaynSupportEmailTap() => _manager.openExternalEmail(
        Constants.xaynSupportEmail, CurrentView.settings);
    void onXaynPressEmailTap() => _manager.openExternalEmail(
        Constants.xaynPressEmail, CurrentView.settings);
    void onXaynUrlTap() =>
        _manager.openExternalUrl(Constants.xaynUrl, CurrentView.settings);

    final space = ' '.span();
    final newLine = '\n'.span();
    return Text.rich(
      [
        R.strings.personalAreaContact.bold(),
        Constants.xaynAddress.span(),
        R.strings.contactSectionWeb.span(),
        space,
        Uri.parse(Constants.xaynUrl).host.link(onTap: onXaynUrlTap),
        newLine,
        R.strings.contactSectionSupportEmail.span(),
        space,
        Constants.xaynSupportEmail.link(onTap: () => onXaynSupportEmailTap),
        newLine,
        R.strings.contactSectionForPublishers.span(),
        space,
        Constants.xaynPressEmail.link(onTap: onXaynPressEmailTap),
        newLine,
        R.strings.contactSectionPhone.span(),
        space,
        Constants.xaynPressPhone.span(),
      ].span(),
      textAlign: TextAlign.start,
    );
  }
}

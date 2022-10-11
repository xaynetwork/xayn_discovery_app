import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

class PushNotificationsCard extends StatelessWidget {
  final CardType cardType;
  final VoidCallback onPressed;

  const PushNotificationsCard({
    Key? key,
    required this.cardType,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      SizedBox(height: R.dimen.unit),
      Expanded(child: _buildAnimation()),
      SizedBox(height: R.dimen.unit2),
      Text(
        R.strings.activatePushNotifications,
        textAlign: TextAlign.center,
        style: R.styles.lBoldStyle.copyWith(color: R.colors.primaryText),
      ),
      SizedBox(height: R.dimen.unit2),
      Text(
        R.strings.pushNotificationsCardSubtitle,
        textAlign: TextAlign.center,
        style: R.styles.mStyle.copyWith(color: R.colors.primaryText),
      ),
      SizedBox(height: R.dimen.unit),
      _buildPerks(),
      SizedBox(height: R.dimen.unit2_5),
      _buildAllowNotificationsBtn(),
    ];

    return Stack(
      children: [
        Container(
          color: R.colors.pageBackground,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: R.dimen.unit2_25,
            vertical: R.dimen.unit8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimation() => AnimationPlayer.assetUnrestrictedSize(
      R.assets.lottie.contextual.subscriptionActive);

  Widget _buildPerks() => SettingsSection(
      topPadding: .0,
      items: [
        R.strings.pushNotificationsCardPerk1,
        R.strings.pushNotificationsCardPerk2,
        R.strings.pushNotificationsCardPerk3,
      ]
          .map(
            (it) => SettingsTileData(
              title: it,
              svgIconPath: R.assets.icons.check,
            ),
          )
          .map((it) => SettingsCardData.fromTile(it))
          .toList(growable: false));

  Widget _buildAllowNotificationsBtn() => SizedBox(
        width: double.maxFinite,
        child: AppRaisedButton.text(
          text: R.strings.pushNotificationsCardCTA,
          onPressed: onPressed,
        ),
      );
}

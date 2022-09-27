import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/inline_card/widget/custom_feed_card_base.dart';
import 'package:xayn_discovery_app/presentation/inline_card/widget/push_notifications_card.dart';

class CustomFeedCard extends StatelessWidget {
  final VoidCallback onPressed;
  final ShaderBuilder? primaryCardShader;
  final CardType cardType;
  final String? selectedCountryName;

  const CustomFeedCard({
    Key? key,
    required this.cardType,
    required this.onPressed,
    this.primaryCardShader,
    required this.selectedCountryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (cardType) {
      case CardType.document:
        throw _CustomFeedCardException();
      case CardType.survey:
        return SurveyCard(
          onPressed: onPressed,
          primaryCardShader: primaryCardShader,
        );
      case CardType.sourceSelection:
        return SourceSelectionCard(
          onPressed: onPressed,
          primaryCardShader: primaryCardShader,
        );
      case CardType.countrySelection:
        return CountrySelectionCard(
          onPressed: onPressed,
          primaryCardShader: primaryCardShader,
          countryName: selectedCountryName,
        );
      case CardType.pushNotifications:
        return PushNotificationsCard(
          cardType: cardType,
          onPressed: onPressed,
          primaryCardShader: primaryCardShader,
        );
    }
  }
}

class _CustomFeedCardException implements Exception {
  _CustomFeedCardException();

  @override
  String toString() => 'CustomFeedCard can not build for CardType = document';
}

import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

class CountrySelectionCard extends _CustomFeedCardBase {
  CountrySelectionCard({
    Key? key,
    required VoidCallback onPressed,
    String? countryName,
  }) : super(
          key: key,
          title: R.strings.countrySelectionCardTitle,
          subtitle: countryName == null
              ? R.strings.countrySelectionCardSubtitle
              : '${R.strings.countrySelectionCardSelectedCountry.format(countryName)}\n${R.strings.countrySelectionCardSubtitle}',
          cTAString: R.strings.changeCountryRegionsCTA,
          highlightedSubtitleText: countryName,
          highlightedSubtitleTextStyle:
              R.styles.mBoldStyle.copyWith(color: R.colors.brightText),
          onPressed: onPressed,
          animationAsset: R.assets.lottie.countrySelection,
        );
}

class SourceSelectionCard extends _CustomFeedCardBase {
  SourceSelectionCard({
    Key? key,
    required VoidCallback onPressed,
  }) : super(
          key: key,
          title: R.strings.sourceSelectionCardTitle,
          subtitle: R.strings.sourceSelectionCardSubtitle,
          cTAString: R.strings.manageNewsSourcesCTA,
          onPressed: onPressed,
          animationAsset: R.assets.lottie.sourceSelection,
        );
}

class SurveyCard extends _CustomFeedCardBase {
  SurveyCard({
    Key? key,
    required VoidCallback onPressed,
  }) : super(
          key: key,
          title: R.strings.takeSurveyTitle,
          subtitle: R.strings.takeSurveySubtitle,
          cTAString: R.strings.takeSurveyCTA,
          onPressed: onPressed,
          animationAsset: R.assets.lottie.survey,
        );
}

class _CustomFeedCardBase extends StatelessWidget {
  final VoidCallback onPressed;
  final String animationAsset;
  final String title;
  final String subtitle;
  final String cTAString;
  final String? highlightedSubtitleText;
  final TextStyle? highlightedSubtitleTextStyle;

  const _CustomFeedCardBase({
    Key? key,
    required this.onPressed,
    required this.animationAsset,
    required this.title,
    required this.subtitle,
    required this.cTAString,
    this.highlightedSubtitleText,
    this.highlightedSubtitleTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      SizedBox(height: R.dimen.unit),
      Expanded(child: _buildAnimation()),
      SizedBox(height: R.dimen.unit2),
      Text(
        title,
        textAlign: TextAlign.center,
        style: R.styles.lBoldStyle.copyWith(color: R.colors.brightText),
      ),
      SizedBox(height: R.dimen.unit2),
      if (highlightedSubtitleText == null)
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: R.styles.mStyle.copyWith(color: R.colors.brightText),
        )
      else
        getHighlightedText(
          text: subtitle,
          highlight: highlightedSubtitleText!,
          textAlign: TextAlign.center,
          labelTextStyle: R.styles.mStyle.copyWith(color: R.colors.brightText),
          highlightTextStyle: highlightedSubtitleTextStyle,
        ),
      SizedBox(height: R.dimen.unit2_5),
      _buildCTABtn(),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                R.colors.videoBackground,
                R.colors.snippetBackground,
                R.colors.snippetBackground,
                R.colors.videoBackground,
                R.colors.videoBackground,
              ],
              stops: const <double>[0.0, 0.18, 0.45, 0.6, 1.0],
            ),
          )),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: R.dimen.unit4,
            vertical: R.dimen.unit6,
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

  Widget _buildAnimation() =>
      AnimationPlayer.assetUnrestrictedSize(animationAsset);

  Widget _buildCTABtn() => SizedBox(
        width: double.maxFinite,
        child: AppRaisedButton.text(
          text: cTAString,
          onPressed: onPressed,
        ),
      );
}

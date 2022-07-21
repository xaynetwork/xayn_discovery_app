import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/static/static_painter.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

class SurveyCard extends StatelessWidget {
  late final ShaderBuilder primaryCardShader =
      ShaderFactory.fromType(ShaderType.static);
  final VoidCallback onPressed;

  SurveyCard({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      SizedBox(height: R.dimen.unit),
      Expanded(child: _buildAnimation()),
      SizedBox(height: R.dimen.unit2),
      Text(
        R.strings.takeSurveyTitle,
        textAlign: TextAlign.center,
        style: R.styles.lBoldStyle.copyWith(color: R.colors.brightText),
      ),
      SizedBox(height: R.dimen.unit2),
      Text(
        R.strings.takeSurveySubtitle,
        textAlign: TextAlign.center,
        style: R.styles.mStyle.copyWith(color: R.colors.brightText),
      ),
      SizedBox(height: R.dimen.unit2_5),
      _buildTakeSurveyBtn(),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: StaticPainter(
              shadowColor: R.colors.shadow,
            ),
          ),
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
      AnimationPlayer.assetUnrestrictedSize(R.assets.lottie.survey);

  Widget _buildTakeSurveyBtn() => SizedBox(
        width: double.maxFinite,
        child: AppRaisedButton.text(
          text: R.strings.takeSurveyCTA,
          onPressed: onPressed,
        ),
      );
}

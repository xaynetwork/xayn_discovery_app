import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

class CustomCard extends StatelessWidget {
  final CardType cardType;
  final ShaderBuilder primaryCardShader;

  CustomCard({
    Key? key,
    required this.cardType,
    ShaderBuilder? primaryCardShader,
  })  : primaryCardShader =
            primaryCardShader ?? ShaderFactory.fromType(ShaderType.static),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: R.colors.swipeCardBackgroundDefault,
      child: AnimationPlayer.asset(
          R.linden.assets.lottie.contextual.paymentFailed),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_shadow_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_shadow_state.dart';
import 'package:xayn_discovery_app/presentation/utils/reader_mode_settings_extension.dart';

class DiscoveryCardHeadlineImage extends StatelessWidget {
  DiscoveryCardHeadlineImage({
    Key? key,
    required this.child,
    Color? shadowColor,
  })  : shadowColor = shadowColor ?? R.colors.swipeCardBackgroundDefault,
        super(key: key);

  final Widget child;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) => Container(
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              shadowColor.withAlpha(120),
              shadowColor.withAlpha(40),
              shadowColor.withAlpha(255),
              shadowColor.withAlpha(255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.15, 0.8, 1],
          ),
        ),
        child: child,
      );
}

class DiscoveryCardReaderModeHeadlineImage extends StatefulWidget {
  const DiscoveryCardReaderModeHeadlineImage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _DiscoveryCardReaderModeHeadlineImageState createState() =>
      _DiscoveryCardReaderModeHeadlineImageState();
}

class _DiscoveryCardReaderModeHeadlineImageState
    extends State<DiscoveryCardReaderModeHeadlineImage> {
  late final DiscoveryCardShadowManager _shadowManager = di.get();

  @override
  void dispose() {
    _shadowManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DiscoveryCardShadowManager, DiscoveryCardShadowState>(
        bloc: _shadowManager,
        builder: (_, state) => DiscoveryCardHeadlineImage(
          child: widget.child,
          shadowColor:
              R.isDarkMode ? state.readerModeBackgroundColor.color : null,
        ),
      );
}

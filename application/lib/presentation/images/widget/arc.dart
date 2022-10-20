import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/foreground/foreground_painter.dart';
import 'package:xayn_discovery_app/presentation/utils/reader_mode_settings_extension.dart';

class Arc extends StatefulWidget {
  final Widget child;
  final ArcVariation arcVariation;

  /// value between [.0, 1.0]
  /// this indicates how much the Arc covers:
  /// - .0 is minimal coverage
  /// - 1.0 is maximal coverage
  final double fractionSize;

  const Arc({
    Key? key,
    required this.child,
    required this.arcVariation,
    this.fractionSize = 1.0,
  }) : super(key: key);

  @override
  State<Arc> createState() => _ArcState();
}

class _ArcState extends State<Arc> {
  late final DiscoveryFeedManager _manager = di.get();

  @override
  Widget build(BuildContext context) {
    final foreground = BlocBuilder<DiscoveryFeedManager, DiscoveryState>(
      bloc: _manager,
      builder: (_, state) {
        final arcBackgroundColor =
            state.readerModeBackgroundColor?.color ?? R.colors.cardBackground;
        return CustomPaint(
          painter: ForegroundPainter(
            fractionSize: widget.fractionSize,
            bezierHeight: R.dimen.unit5,
            color: arcBackgroundColor,
            arcVariations: widget.arcVariation,
          ),
        );
      },
    );

    return LayoutBuilder(
        builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  bottom:
                      constraints.maxHeight / 2.5 * (1.0 - widget.fractionSize),
                  child: widget.child,
                ),
                Positioned.fill(child: foreground),
              ],
            ));
  }
}

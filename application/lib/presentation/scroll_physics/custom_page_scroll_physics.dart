import 'package:flutter/widgets.dart';

/// Custom physics based on [PageScrollPhysics].
///
/// These physics cause the page view to snap to page boundaries for a given page size.
///
/// See also:
///
///  * [ScrollPhysics], the base class which defines the API for scrolling
///    physics.
///  * [PageView.physics], which can override the physics used by a page view.
class CustomPageScrollPhysics extends ScrollPhysics {
  /// Creates physics for a [PageView].
  const CustomPageScrollPhysics({
    ScrollPhysics? parent,
    required this.pageSize,
  }) : super(parent: parent);

  final double pageSize;

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      CustomPageScrollPhysics(
        parent: buildParent(ancestor),
        pageSize: pageSize,
      );

  double _getPage(ScrollMetrics position) => position.pixels / pageSize;

  double _getPixels(ScrollMetrics position, double page) => page * pageSize;

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  double getPage(ScrollMetrics position) => position.pixels / pageSize;

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

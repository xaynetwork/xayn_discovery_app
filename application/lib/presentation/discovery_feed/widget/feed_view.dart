import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/util/custom_page_scroll_physics.dart';

class FeedView extends StatelessWidget {
  const FeedView({
    Key? key,
    this.scrollController,
    required this.itemBuilder,
    this.itemCount,
  }) : super(key: key);

  final ScrollController? scrollController;
  final Widget Function(BuildContext, int) itemBuilder;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Padding(
      padding: EdgeInsets.only(top: padding.top),
      child: LayoutBuilder(builder: (context, constraints) {
        final pageSize = constraints.maxHeight - padding.bottom;

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            itemExtent: pageSize,
            physics: CustomPageScrollPhysics(pageSize: pageSize),
            scrollDirection: Axis.vertical,
            controller: scrollController,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
      }),
    );
  }
}

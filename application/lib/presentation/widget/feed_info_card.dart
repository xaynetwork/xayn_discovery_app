import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class FeedEndOfResultsCard extends FeedInfoCard {
  FeedEndOfResultsCard({
    Key? key,
    double? width,
    double? height,
  }) : super(
          key: key,
          title: R.strings.searchEndOfResults,
          description: R.strings.searchEndOfResultsDesc,
          width: width,
          height: height,
        );
}

abstract class FeedInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final double? width;
  final double? height;

  const FeedInfoCard({
    Key? key,
    required this.title,
    required this.description,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              title,
              style: R.styles.lBoldStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.dimen.unit2),
            Text(
              description,
              style: R.styles.mStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class FeedLoadingCard extends StatelessWidget {
  final double? width;
  final double? height;

  const FeedLoadingCard({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: R.colors.searchResultSkeletonBase,
        highlightColor: R.colors.searchResultSkeletonHighlight,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: R.styles.roundBorder,
            color: R.colors.cardBackground,
          ),
        ),
      );
}

class FeedNoResultsCard extends FeedInfoCard {
  FeedNoResultsCard({
    Key? key,
    double? width,
    double? height,
  }) : super(
          key: key,
          title: R.strings.searchNoResultsFound,
          description: R.strings.searchNoResultsFoundDesc,
          width: width,
          height: height,
        );
}

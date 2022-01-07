import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class FaviconBar extends StatelessWidget {
  const FaviconBar({
    Key? key,
    required this.provider,
    required this.datePublished,
  }) : super(key: key);

  final WebResourceProvider provider;
  final DateTime datePublished;

  @override
  Widget build(BuildContext context) {
    final favicon = provider.thumbnail == null
        ? Icon(Icons.web, color: R.colors.icon)
        : Image.network(
            provider.thumbnail!.toString(),
            width: R.dimen.unit3,
            height: R.dimen.unit3,
          );

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(R.dimen.unit0_5),
          child: favicon,
        ),
        SizedBox(
          width: R.dimen.unit,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.name,
              style: R.styles.appThumbnailText?.copyWith(color: Colors.white),
            ),
            Text(
              timeAgo(datePublished, DateFormat.yMMMMd()),
              style:
                  R.styles.appThumbnailTextLight?.copyWith(color: Colors.white),
            ),
          ],
        )
      ],
    );
  }
}

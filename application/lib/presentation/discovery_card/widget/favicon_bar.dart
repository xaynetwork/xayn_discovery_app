import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';

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
        ? Icon(Icons.web, color: R.colors.iconNew)
        : Image.network(
            provider.thumbnail!,
            width: R.dimen.iconSize,
            height: R.dimen.iconSize,
          );

    return Center(
      child: Wrap(
        spacing: R.dimen.unit0_75,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(R.dimen.unit0_5),
            child: favicon,
          ),
          Text(
            provider.name,
            style: R.styles.appThumbnailText?.copyWith(color: Colors.white),
          ),
          Text(
            '•',
            style:
                R.styles.appThumbnailTextLight?.copyWith(color: Colors.white),
          ),
          Text(
            timeAgo(datePublished, DateFormat.yMMMMd()),
            style:
                R.styles.appThumbnailTextLight?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

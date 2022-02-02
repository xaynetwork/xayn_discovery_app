import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class FaviconBar extends StatelessWidget {
  const FaviconBar._({
    Key? key,
    this.provider,
    this.providerName,
    this.thumbnail,
    required this.datePublished,
  })  : assert(provider != null || (providerName != null && thumbnail != null),
            "Need to provide either a WebresourceProvider or directly an cached thumbnail."),
        super(key: key);

  factory FaviconBar.fromProvider({
    required WebResourceProvider provider,
    required DateTime datePublished,
  }) =>
      FaviconBar._(
        provider: provider,
        datePublished: datePublished,
      );

  final WebResourceProvider? provider;
  final DateTime datePublished;
  final String? providerName;
  final Uint8List? thumbnail;

  @override
  Widget build(BuildContext context) {
    final favicon = provider?.thumbnail == null
        ? Thumbnail.icon(Icons.web)
        : Thumbnail.networkImage(provider!.thumbnail!.toString());

    return Row(
      children: [
        favicon,
        SizedBox(
          width: R.dimen.unit,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider?.name ?? '',
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

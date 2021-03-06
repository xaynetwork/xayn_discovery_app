import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';

class FaviconBar extends StatelessWidget {
  const FaviconBar._({
    Key? key,
    this.provider,
    required this.datePublished,
  }) : super(key: key);

  factory FaviconBar.fromProvider({
    required DateTime datePublished,
    DocumentProvider? provider,
  }) =>
      FaviconBar._(
        provider: provider,
        datePublished: datePublished,
      );

  final DateTime datePublished;
  final DocumentProvider? provider;

  @override
  Widget build(BuildContext context) {
    final providerNameAndDatePublished = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider?.name ?? '',
          style: R.styles.sBoldStyle.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          timeAgo(datePublished, DateFormat.yMMMMd()),
          style: R.styles.sStyle.copyWith(color: Colors.white),
        ),
      ],
    );

    return Row(
      children: [
        if (provider?.favicon != null)
          Thumbnail.networkImage(
            provider!.favicon.toString(),
            errorWidgetBuilder: (context, _, s) => Icon(
              Icons.web,
              color: R.colors.icon,
            ),
          ),
        SizedBox(width: R.dimen.unit),
        Expanded(child: providerNameAndDatePublished),
      ],
    );
  }
}

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
    required this.timeToRead,
  }) : super(key: key);

  factory FaviconBar.fromProvider({
    required DateTime datePublished,
    required String timeToRead,
    DocumentProvider? provider,
  }) =>
      FaviconBar._(
        provider: provider,
        datePublished: datePublished,
        timeToRead: timeToRead,
      );

  final DateTime datePublished;
  final DocumentProvider? provider;
  final String timeToRead;

  @override
  Widget build(BuildContext context) {
    final providerWidget = Text(
      provider?.name ?? '',
      style: R.styles.sBoldStyle.copyWith(color: R.colors.primaryText),
      overflow: TextOverflow.ellipsis,
    );
    final publishedWidget = Text(
      timeAgo(datePublished, DateFormat.yMMMMd()),
      style: R.styles.sStyle.copyWith(color: R.colors.primaryText),
    );
    final timeToReadWidget = Text(
      timeToRead,
      style: R.styles.sStyle.copyWith(color: R.colors.primaryText),
      textAlign: TextAlign.left,
      maxLines: 1,
    );

    buildSpacer() =>
        Text('•', style: R.styles.sStyle.copyWith(color: R.colors.primaryText));

    addPadding(Widget child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit0_5),
          child: child,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (provider?.favicon != null)
          Thumbnail.networkImage(
            provider!.favicon.toString(),
            errorWidgetBuilder: (context, _, s) => Icon(
              Icons.web,
              color: R.colors.icon,
            ),
          ),
        SizedBox(
          width: R.dimen.unit0_5,
        ),
        addPadding(providerWidget),
        buildSpacer(),
        addPadding(publishedWidget),
        buildSpacer(),
        if (timeToRead.isNotEmpty)
          Expanded(child: addPadding(timeToReadWidget)),
      ],
    );
  }
}

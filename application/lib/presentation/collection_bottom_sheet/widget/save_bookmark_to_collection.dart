import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/widget/bottom_sheet.dart';

class SaveBookmarkToCollection with BottomSheetMixin {
  final UniqueId bookmarkId;

  const SaveBookmarkToCollection({required this.bookmarkId});

  @override
  Widget get body => _SaveBookmarkToCollectionBody(bookmarkId: bookmarkId);

  @override
  Widget get header => const _SaveBookmarkToCollectionHeader();
}

class _SaveBookmarkToCollectionBody extends StatefulWidget {
  final UniqueId bookmarkId;

  const _SaveBookmarkToCollectionBody({Key? key, required this.bookmarkId})
      : super(key: key);

  @override
  __SaveBookmarkToCollectionBodyState createState() =>
      __SaveBookmarkToCollectionBodyState();
}

class __SaveBookmarkToCollectionBodyState
    extends State<_SaveBookmarkToCollectionBody> {
  @override
  Widget build(BuildContext context) {
    return Text(
      (widget.bookmarkId.toString() + '\n') * 80,
      style: const TextStyle(fontSize: 10),
    );
  }
}

class _SaveBookmarkToCollectionHeader extends StatelessWidget {
  const _SaveBookmarkToCollectionHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Center(
        child: Text(
          'Save To ',
          style: TextStyle(fontSize: 13),
        ),
      );
}

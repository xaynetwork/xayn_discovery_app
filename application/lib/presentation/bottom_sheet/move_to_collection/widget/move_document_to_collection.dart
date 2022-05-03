import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_image.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/select_item_list.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class MoveDocumentToCollectionBottomSheet extends BottomSheetBase {
  MoveDocumentToCollectionBottomSheet({
    Key? key,
    required Document document,
    required DocumentProvider? provider,
    FeedType? feedType,
    UniqueId? initialSelectedCollectionId,
  }) : super(
          key: key,
          body: _MoveDocumentToCollection(
            document: document,
            provider: provider,
            initialSelectedCollectionId: initialSelectedCollectionId,
            feedType: feedType,
          ),
        );
}

class _MoveDocumentToCollection extends StatefulWidget {
  final Document document;
  final DocumentProvider? provider;
  final UniqueId? initialSelectedCollectionId;
  final FeedType? feedType;

  const _MoveDocumentToCollection({
    Key? key,
    required this.document,
    required this.provider,
    this.feedType,
    this.initialSelectedCollectionId,
  }) : super(key: key);

  @override
  _MoveDocumentToCollectionState createState() =>
      _MoveDocumentToCollectionState();
}

class _MoveDocumentToCollectionState extends State<_MoveDocumentToCollection>
    with
        BottomSheetBodyMixin,
        CollectionCardManagersMixin,
        OverlayMixin<_MoveDocumentToCollection> {
  late final MoveToCollectionManager _manager = di.get();

  @override
  OverlayManager get overlayManager => _manager.overlayManager;

  @override
  void initState() {
    _manager.updateInitialSelectedCollection(
      bookmarkId: widget.document.documentUniqueId,
      initialSelectedCollectionId: widget.initialSelectedCollectionId,
    );

    super.initState();
  }

  @override
  void dispose() {
    _manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocBuilder<MoveToCollectionManager, MoveToCollectionState>(
      bloc: _manager,
      builder: (_, state) {
        if (state.shouldClose) {
          closeBottomSheet(context);
        }

        if (state.collections.isNotEmpty) {
          final selectedCollection = state.collections
              .firstWhereOrNull((c) => c.id == state.selectedCollectionId);
          return SelectItemList<Collection>(
            items: state.collections,
            onSelectItem: (c) => _manager.updateSelectedCollection(c.id),
            getTitle: (c) => c.name,
            getImage: (c) => buildCollectionImage(managerOf(c.id)),
            preSelectedItems:
                selectedCollection == null ? {} : {selectedCollection},
          );
        }

        return const SizedBox.shrink();
      },
    );

    final header = BottomSheetHeader(
      headerText: R.strings.bottomSheetSaveTo,
      actionWidget: AppGhostButton.icon(
        R.assets.icons.plus,
        onPressed: _showAddCollectionBottomSheet,
        contentPadding: EdgeInsets.zero,
      ),
    );

    final footer = BottomSheetFooter(
      onCancelPressed: () {
        _manager.onCancelPressed();
        closeBottomSheet(context);
      },
      setup: BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetApply,
          onPressed: () => _manager.onApplyToDocumentPressed(
            document: widget.document,
            provider: widget.provider,
            feedType: widget.feedType,
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Flexible(child: body),
        footer,
      ],
    );
  }

  void _showAddCollectionBottomSheet() {
    closeBottomSheet(context);
    showAppBottomSheet(
      context,
      builder: (buildContext) => CreateOrRenameCollectionBottomSheet(
        onApplyPressed: (collection) => _onAddCollectionSheetClosed(
          buildContext,
          collection.id,
        ),
      ),
    );
  }

  void _onAddCollectionSheetClosed(
          BuildContext context, UniqueId newCollectionId) =>
      showAppBottomSheet(
        context,
        builder: (_) => MoveDocumentToCollectionBottomSheet(
          document: widget.document,
          provider: widget.provider,
          initialSelectedCollectionId: newCollectionId,
          feedType: widget.feedType,
        ),
      );
}

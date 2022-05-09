import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin CollectionManagerFlowMixin<T> on OverlayManagerMixin<T> {
  void showMoveDocumentToCollectionBottomSheet(
    Document document, {
    DocumentProvider? provider,
    FeedType? feedType,
    UniqueId? initialSelectedCollectionId,
  }) {
    void onCollectionAdded(Collection collection) =>
        showMoveDocumentToCollectionBottomSheet(
          document,
          provider: provider,
          feedType: feedType,
          initialSelectedCollectionId: collection.id,
        );

    void onAddCollectionPressed() => showOverlay(
          OverlayData.bottomSheetCreateOrRenameCollection(
            onApplyPressed: onCollectionAdded,
          ),
        );

    final moveDocumentToCollectionSheet =
        OverlayData.bottomSheetMoveDocumentToCollection(
      document: document,
      provider: provider,
      feedType: feedType,
      initialSelectedCollectionId: initialSelectedCollectionId,
      onAddCollectionPressed: onAddCollectionPressed,
    );

    showOverlay(moveDocumentToCollectionSheet);
  }

  void showMoveBookmarkToCollectionBottomSheet(
    UniqueId bookmarkId, {
    void Function()? onClose,
    UniqueId? initialSelectedCollectionId,
  }) {
    void onCollectionAdded(Collection collection) =>
        showMoveBookmarkToCollectionBottomSheet(
          bookmarkId,
          onClose: onClose,
          initialSelectedCollectionId: collection.id,
        );

    void onAddCollectionPressed() => showOverlay(
          OverlayData.bottomSheetCreateOrRenameCollection(
            onApplyPressed: onCollectionAdded,
            onSystemPop: onClose,
          ),
        );

    final moveBookmarkToCollectionSheet =
        OverlayData.bottomSheetMoveBookmarkToCollection(
      bookmarkId: bookmarkId,
      onSystemPop: onClose,
      initialSelectedCollection: initialSelectedCollectionId,
      onAddCollectionPressed: onAddCollectionPressed,
      showBarrierColor: onClose == null,
    );

    showOverlay(moveBookmarkToCollectionSheet);
  }

  void showMoveBookmarksToCollectionBottomSheet(
    List<UniqueId> bookmarkIds, {
    required UniqueId collectionIdToRemove,
    void Function()? onClose,
    UniqueId? initialSelectedCollectionId,
  }) {
    void onCollectionAdded(Collection collection) =>
        showMoveBookmarksToCollectionBottomSheet(
          bookmarkIds,
          collectionIdToRemove: collectionIdToRemove,
          onClose: onClose,
          initialSelectedCollectionId: collection.id,
        );

    void onAddCollectionPressed() => showOverlay(
          OverlayData.bottomSheetCreateOrRenameCollection(
            onApplyPressed: onCollectionAdded,
            onSystemPop: onClose,
          ),
        );

    final moveBookmarksToCollectionSheet =
        OverlayData.bottomSheetMoveBookmarksToCollection(
      bookmarksIds: bookmarkIds,
      collectionIdToRemove: collectionIdToRemove,
      onClose: onClose,
      initialSelectedCollection: initialSelectedCollectionId,
      onAddCollectionPressed: onAddCollectionPressed,
    );

    showOverlay(moveBookmarksToCollectionSheet);
  }
}

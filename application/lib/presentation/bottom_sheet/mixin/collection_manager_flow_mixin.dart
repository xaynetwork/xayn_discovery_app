import 'package:flutter/foundation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin CollectionManagerFlowMixin<T> on OverlayManagerMixin<T> {
  /// Starts a flow for bookmarking/un-bookmarking a document or moving it
  /// to a different collection
  ///
  /// Triggers bottom sheet with [OverlayData.bottomSheetMoveDocumentToCollection]
  ///
  /// Handles adding a collection flow and recalling [startBookmarkDocumentFlow]
  /// with an initial collection id when a new collection is created
  ///
  @protected
  void startBookmarkDocumentFlow(
    Document document, {
    DocumentProvider? provider,
    FeedType? feedType,
    UniqueId? initialSelectedCollectionId,
  }) {
    void onCollectionAdded(Collection collection) => startBookmarkDocumentFlow(
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

  /// Starts a flow for moving a single bookmark
  ///
  /// Triggers bottom sheet with [OverlayData.bottomSheetCreateOrRenameCollection]
  ///
  /// Handles adding a collection flow and recalling [startMoveBookmarkFlow]
  /// with an initial collection id when a new collection is created
  ///
  @protected
  void startMoveBookmarkFlow(
    UniqueId bookmarkId, {
    VoidCallback? onClose,
    UniqueId? initialSelectedCollectionId,
    bool showBarrierColor = true,
  }) {
    void onCollectionAdded(Collection collection) => startMoveBookmarkFlow(
          bookmarkId,
          onClose: onClose,
          initialSelectedCollectionId: collection.id,
          showBarrierColor: showBarrierColor,
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
      showBarrierColor: showBarrierColor,
    );

    showOverlay(moveBookmarkToCollectionSheet);
  }

  /// Starts a flow for moving multiple bookmarks while removing a collection
  ///
  /// Triggers bottom sheet with [OverlayData.bottomSheetMoveBookmarksToCollection]
  ///
  /// Handles adding a collection flow and recalling [startMoveBookmarksFlow]
  /// with an initial collection id when a new collection is created
  ///
  @protected
  void startMoveBookmarksFlow(
    List<UniqueId> bookmarkIds, {
    required UniqueId collectionIdToRemove,
    VoidCallback? onClose,
    UniqueId? initialSelectedCollectionId,
  }) {
    void onCollectionAdded(Collection collection) => startMoveBookmarksFlow(
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

  /// Starts a flow of opening an options menu for a bookmark
  ///
  /// Triggers bottom sheet with [OverlayData.bottomSheetBookmarksOptions]
  ///
  /// Handles moving a bookmark
  ///
  @protected
  void startBookmarkOptionsFlow({
    required UniqueId bookmarkId,
    required VoidCallback onClose,
  }) =>
      showOverlay(
        OverlayData.bottomSheetBookmarksOptions(
          bookmarkId: bookmarkId,
          onClose: onClose,
          onMovePressed: () => startMoveBookmarkFlow(
            bookmarkId,
            onClose: onClose,
            showBarrierColor: false,
          ),
        ),
      );
}

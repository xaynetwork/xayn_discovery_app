import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

extension DocumentExtension on Document {
  UniqueId get documentUniqueId => documentId.uniqueId;

  UniqueId get toBookmarkId => Bookmark.generateUniqueIdFromUri(resource.url);
}

extension DocumentIdUtils on DocumentId {
  UniqueId get uniqueId => UniqueId.fromTrustedString(toString());
}

extension DocumentFeedbackExtension on UserReaction {
  bool get isNeutral => this == UserReaction.neutral;

  bool get isRelevant => this == UserReaction.positive;

  bool get isIrrelevant => this == UserReaction.negative;
}

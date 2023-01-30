import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/news_resource.dart';
import 'package:xayn_discovery_app/domain/model/legacy/stack_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';

class Document {
  final DocumentId documentId;
  final UserReaction userReaction;
  final NewsResource resource;
  final StackId stackId;

  const Document({
    required this.documentId,
    required this.userReaction,
    required this.resource,
    required this.stackId,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
      documentId: DocumentId.fromValue(json['documentId']),
      userReaction: UserReaction.values.firstWhere(
          (it) => it.name == json['userReaction'],
          orElse: () => UserReaction.neutral),
      resource: NewsResource.fromJson(json['resource']),
      stackId: StackId.fromValue(
        (json['stackId']),
      ));

  Map<String, dynamic> toJson() => {
        'documentId': documentId.value,
        'userReaction': userReaction.name,
        'resource': resource.toJson(),
        'stackId': stackId.value,
      };
}

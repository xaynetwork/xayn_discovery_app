import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

enum DocumentFilterType {
  source,
  topic,
}

class DocumentFilter extends Equatable implements DbEntity {
  final String _filter;
  final DocumentFilterType _type;
  @override
  final UniqueId id;

  const DocumentFilter._({
    required String filter,
    required DocumentFilterType type,
    required this.id,
  })  : _type = type,
        _filter = filter;

  factory DocumentFilter.fromSource(String url) {
    final uri =
        Uri.parse(url.startsWith(RegExp('http[s]?://')) ? url : "https://$url");
    if (uri.host.isEmpty) {
      throw "Must provide a valid host name '$url' can not be parsed";
    }
    return DocumentFilter._(
        filter: uri.host,
        type: DocumentFilterType.source,
        id: UniqueId.fromTrustedString("source:${uri.host}"));
  }

  factory DocumentFilter.fromTopic(String topic) => DocumentFilter._(
      filter: topic,
      type: DocumentFilterType.topic,
      id: UniqueId.fromTrustedString("topic:$topic"));

  T fold<T>(T Function(String host) source, T Function(String topic) topic) {
    switch (_type) {
      case DocumentFilterType.source:
        return source(_filter);
      case DocumentFilterType.topic:
        return topic(_filter);
    }
  }

  @override
  List<Object?> get props => [id, _filter, _type];
}

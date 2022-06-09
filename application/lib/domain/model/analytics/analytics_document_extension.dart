import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const resourceKey = 'resource';
const sourceDomainKey = 'sourceDomain';

extension AnalyticsDocumentExtension on Document {
  /// Drop sensitive [WebResource] properties from Jsonified [Document] for privacy reasons
  Map<String, dynamic> toAnalyticsJson() =>
      toJson()..update(resourceKey, (_) => resource.toAnalyticsJson());
}

extension on NewsResource {
  /// Drop all properties except [SourceDomain] from Jsonified [NewsResource] for privacy reasons
  Map<String, dynamic> toAnalyticsJson() =>
      toJson()..removeWhere((key, _) => key != sourceDomainKey);
}

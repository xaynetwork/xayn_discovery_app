import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as xayn;

part 'web_resource.freezed.dart';
part 'web_resource.g.dart';

/// Mock implementation which implements [xayn.WebResource].
/// This will be deprecated once the real discovery engine is available.
@freezed
class WebResource with _$WebResource implements xayn.WebResource {
  const WebResource._();

  const factory WebResource({
    required Uri displayUrl,
    required String snippet,
    required String title,
    required Uri url,
  }) = _WebResource;

  factory WebResource.fromJson(Map<String, dynamic> json) =>
      _$WebResourceFromJson(json);
}

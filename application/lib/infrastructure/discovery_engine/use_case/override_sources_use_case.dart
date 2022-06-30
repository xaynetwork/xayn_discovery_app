import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class OverrideSourcesUseCase
    extends UseCase<OverrideSourcesPayload, EngineEvent> {
  final DiscoveryEngine _engine;

  OverrideSourcesUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(OverrideSourcesPayload param) async* {
    yield await _engine.overrideSources(
      trustedSources: param.trustedSources,
      excludedSources: param.excludedSources,
    );
  }
}

@immutable
class OverrideSourcesPayload {
  final Set<Source> trustedSources;
  final Set<Source> excludedSources;

  const OverrideSourcesPayload({
    required this.trustedSources,
    required this.excludedSources,
  });
}

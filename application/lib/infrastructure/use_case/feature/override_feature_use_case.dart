import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';

@injectable
class OverrideFeatureUseCase extends UseCase<OverrideFeatureParam, FeatureMap> {
  OverrideFeatureUseCase();

  @override
  Stream<FeatureMap> transaction(OverrideFeatureParam param) async* {
    final FeatureMap result = Map.from(param.featureMap);
    result[param.feature] = param.isEnabled;
    yield result;
  }

  @override
  Stream<OverrideFeatureParam> transform(
          Stream<OverrideFeatureParam> incoming) =>
      incoming.distinct();
}

class OverrideFeatureParam {
  final FeatureMap featureMap;
  final Feature feature;
  final bool isEnabled;

  const OverrideFeatureParam({
    required this.featureMap,
    required this.feature,
    required this.isEnabled,
  });
}

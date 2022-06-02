import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class IncrementSurveyShownUseCase extends UseCase<None, None> {
  final AppStatusRepository _repository;

  IncrementSurveyShownUseCase(this._repository);

  @override
  Stream<None> transaction(param) async* {
    final appStatus = _repository.appStatus;
    final cta = appStatus.cta;
    final surveyBannerData = appStatus.cta.surveyBannerData;
    final updatedSurveyBannerData = surveyBannerData.copyWith(
        numberOfTimesShown: surveyBannerData.numberOfTimesShown + 1);
    final updatedCta = cta.copyWith(surveyBannerData: updatedSurveyBannerData);
    final updatedAppStatus = appStatus.copyWith(
      cta: updatedCta,
    );
    _repository.save(updatedAppStatus);
    yield none;
  }
}

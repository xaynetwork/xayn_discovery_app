import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class HandleSurveyBannerClickedUseCase extends UseCase<None, None> {
  final AppStatusRepository appStatusRepository;

  HandleSurveyBannerClickedUseCase(this.appStatusRepository);
  @override
  Stream<None> transaction(None param) async* {
    /// Get the current status of the data
    final appStatus = appStatusRepository.appStatus;
    final cta = appStatus.cta;
    final surveyBanner = cta.surveyBanner;

    /// Update the status of the data
    final updatedCta = cta.copyWith(surveyBanner: surveyBanner.clicked());
    final updatedAppStatus = appStatus.copyWith(cta: updatedCta);
    appStatusRepository.save(updatedAppStatus);

    yield none;
  }
}

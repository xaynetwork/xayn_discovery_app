import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockUrlOpener urlOpener;
  late MockAnalyticsService analyticsService;
  late MockMarketingAnalyticsService marketingAnalyticsService;

  const mockUrl =
      'https://www.msn.com/en-us/news/world/biden-says-nord-stream-2-won-t-go-forward-if-russia-invades-ukraine-but-german-chancellor-demurs/ar-AATzYRX';

  setUp(() {
    urlOpener = MockUrlOpener();
    analyticsService = MockAnalyticsService();
    marketingAnalyticsService = MockMarketingAnalyticsService();

    di.registerLazySingleton<UrlOpener>(() => urlOpener);
    di.registerLazySingleton<SendAnalyticsUseCase>(() => SendAnalyticsUseCase(
          analyticsService,
          marketingAnalyticsService,
        ));

    when(analyticsService.send(any)).thenAnswer((_) => Future.value());
    when(urlOpener.openUrl(any)).thenReturn(null);
  });

  group('Open External Url Mixin', () {
    blocTest<_TestBloc, bool>(
      'WHEN open url EXPECT url opener use case to be triggered',
      build: () => _TestBloc(),
      act: (bloc) => bloc.openExternalUrl(
        url: mockUrl,
        currentView: CurrentView.reader,
      ),
      verify: (manager) {
        verifyInOrder([
          urlOpener.openUrl(mockUrl),
          analyticsService.send(any),
        ]);
        verifyNoMoreInteractions(urlOpener);
      },
    );
  });
}

class _TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, OpenExternalUrlMixin<bool> {
  _TestBloc() : super(false);
}

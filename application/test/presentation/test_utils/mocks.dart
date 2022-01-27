import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/get_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/save_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_stored_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/save_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Please, keep those alphabetically sorted.
/// It is easier to support end expand
@GenerateMocks([
  ActiveSearchNavActions,
  AppManager,
  AppVersionToMapMapper,
  BugReportingService,
  BuildContext,
  CreateDefaultCollectionUseCase,
  CreateOrGetDefaultCollectionUseCase,
  DbEntityMapToFeedMarketMapper,
  DiscoveryEngine,
  Document,
  ExtractLogUseCase,
  FeatureManager,
  FeedMarketToDbEntityMapMapper,
  FeedSettingsManager,
  FeedSettingsMapper,
  FeedSettingsNavActions,
  FeedSettingsRepository,
  GetAppSessionUseCase,
  GetAppThemeUseCase,
  GetAppVersionUseCase,
  GetSelectedCountriesUseCase,
  GetStoredAppVersionUseCase,
  GetSupportedCountriesUseCase,
  InAppReview,
  IncrementAppSessionUseCase,
  ListenAppThemeUseCase,
  MapToAppVersionMapper,
  PersonalAreaManager,
  PersonalAreaNavActions,
  SaveAppThemeUseCase,
  SaveCurrentAppVersion,
  SaveSelectedCountriesUseCase,
  SettingsNavActions,
  SettingsScreenManager,
  ShareUriUseCase,
  UrlOpener,
  AppImageCacheManager,
])
class Mocks {
  Mocks._();
}

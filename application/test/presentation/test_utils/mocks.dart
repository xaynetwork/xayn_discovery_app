import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
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
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@GenerateMocks([
  AppManager,
  FeatureManager,
  Document,
  GetAppThemeUseCase,
  ListenAppThemeUseCase,
  SettingsNavActions,
  PersonalAreaNavActions,
  FeedSettingsNavActions,
  FeedSettingsManager,
  SettingsScreenManager,
  ActiveSearchNavActions,
  PersonalAreaManager,
  DiscoveryEngine,
  BuildContext,
  IncrementAppSessionUseCase,
  MapToAppVersionMapper,
  AppVersionToMapMapper,
  GetAppVersionUseCase,
  GetStoredAppVersionUseCase,
  SaveCurrentAppVersion,
  GetAppSessionUseCase,
  InAppReview,
  GetSupportedCountriesUseCase,
  CreateOrGetDefaultCollectionUseCase,
  SaveAppThemeUseCase,
  BugReportingService,
  ExtractLogUseCase,
  UrlOpener,
  ShareUriUseCase,
  CreateDefaultCollectionUseCase
])
class Mocks {
  Mocks._();
}

import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/domain/repository/feed_type_markets_repository.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/payment_flow_error_mapper_to_error_msg_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchasable_product_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchase_event_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_marketing_analytics_use_case.dart';
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
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_management_url_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/request_code_redemption_sheet_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/restore_subscription_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_background_color_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_size_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_style_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/get_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/listen_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/save_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Please, keep those alphabetically sorted.
/// It is easier to support end expand
@GenerateMocks([
  ActiveSearchNavActions,
  AppDiscoveryEngine,
  AppImageCacheManager,
  AppManager,
  AppVersionToMapMapper,
  AreMarketsOutdatedUseCase,
  BookmarksScreenNavActions,
  BugReportingService,
  BuildContext,
  GetSubscriptionStatusUseCase,
  CreateDefaultCollectionUseCase,
  CreateOrGetDefaultCollectionUseCase,
  DbEntityMapToFeedMarketMapper,
  Document,
  ExtractLogUseCase,
  FeatureManager,
  FeedMarketToDbEntityMapMapper,
  FeedSettingsManager,
  FeedSettingsMapper,
  FeedSettingsNavActions,
  FeedSettingsRepository,
  FeedTypeMarketsRepository,
  GetAppSessionUseCase,
  GetAppThemeUseCase,
  GetAppVersionUseCase,
  GetSelectedCountriesUseCase,
  GetStoredAppVersionUseCase,
  GetSubscriptionDetailsUseCase,
  GetSupportedCountriesUseCase,
  GetTtsPreferenceUseCase,
  InAppReview,
  IncrementAppSessionUseCase,
  ListenAppThemeUseCase,
  ListenTtsPreferenceUseCase,
  MapToAppVersionMapper,
  PaymentFlowErrorToErrorMessageMapper,
  PaymentService,
  PersonalAreaManager,
  PersonalAreaNavActions,
  PurchasableProductMapper,
  PurchasesErrorCodeToPaymentFlowErrorMapper,
  PurchaseSubscriptionUseCase,
  SaveAppThemeUseCase,
  SaveCurrentAppVersion,
  SaveSelectedCountriesUseCase,
  SaveTtsPreferenceUseCase,
  SettingsNavActions,
  SettingsScreenManager,
  ShareUriUseCase,
  UrlOpener,
  AppSettingsRepository,
  EditReaderModeSettingsManager,
  ReaderModeSettingsMapper,
  ReaderModeSettingsRepository,
  ListenReaderModeSettingsUseCase,
  SaveReaderModeFontStyleUseCase,
  SaveReaderModeFontSizeParamUseCase,
  SaveReaderModeBackgroundColorUseCase,
  RequestCodeRedemptionSheetUseCase,
  AppStatusRepository,
  ListenSubscriptionStatusUseCase,
  RenameDefaultCollectionUseCase,
  HapticFeedbackMediumUseCase,
  RestoreSubscriptionUseCase,
  PaymentScreenNavActions,
  GetSubscriptionManagementUrlUseCase,
  SendAnalyticsUseCase,
  SendMarketingAnalyticsUseCase,
  PurchaseEventMapper,
])
class Mocks {
  Mocks._();
}

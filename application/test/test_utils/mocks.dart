import 'package:amplitude_flutter/amplitude.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/domain/repository/document_repository.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/domain/repository/feed_type_markets_repository.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/payment_flow_error_mapper_to_error_msg_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchasable_product_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchase_event_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_marketing_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_collection_and_bookmark_changes_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_initial_identity_params_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/get_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/save_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_stored_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/save_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collection_card_data_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/onboarding_completed_use_case.dart';
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
import 'package:xayn_discovery_app/infrastructure/util/app_image_cache_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/country_feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/new_personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Please, keep those alphabetically sorted.
/// It is easier to support end expand
@GenerateMocks([
  Amplitude,
  ActiveSearchNavActions,
  AnalyticsService,
  AppDiscoveryEngine,
  AppImageCacheManager,
  AppManager,
  AppSettingsMapper,
  AppSettingsRepository,
  AppsflyerSdk,
  AppStatusRepository,
  AppThemeToIntMapper,
  AppVersionToMapMapper,
  AreMarketsOutdatedUseCase,
  BookmarkErrorsEnumMapper,
  BookmarksScreenNavActions,
  BookmarksRepository,
  Box,
  BugReportingService,
  BuildContext,
  ChangeDocumentFeedbackUseCase,
  Client,
  CollectionErrorsEnumMapper,
  CollectionsRepository,
  CollectionsScreenNavActions,
  ConnectivityUseCase,
  CountryFeedSettingsManager,
  CreateBookmarkFromDocumentUseCase,
  CreateCollectionUseCase,
  CreateDefaultCollectionUseCase,
  CreateOrGetDefaultCollectionUseCase,
  CrudExplicitDocumentFeedbackUseCase,
  DateTimeHandler,
  DbEntityMapToFeedMarketMapper,
  DiscoveryCardManager,
  Document,
  DocumentRepository,
  EditReaderModeSettingsManager,
  ExtractLogUseCase,
  FeatureManager,
  FeedMarketToDbEntityMapMapper,
  FeedRepository,
  FeedSettingsMapper,
  FeedSettingsRepository,
  FeedTypeMarketsRepository,
  FetchSessionUseCase,
  FileHandler,
  GetAllBookmarksUseCase,
  GetAllCollectionsUseCase,
  GetAppSessionUseCase,
  GetAppThemeUseCase,
  GetAppVersionUseCase,
  GetBookmarkUseCase,
  GetSelectedCountriesUseCase,
  GetStoredAppVersionUseCase,
  GetSubscriptionDetailsUseCase,
  GetSubscriptionManagementUrlUseCase,
  GetSubscriptionStatusUseCase,
  GetSupportedCountriesUseCase,
  HapticFeedbackMediumUseCase,
  HiveExplicitDocumentFeedbackRepository,
  InAppReview,
  IncrementAppSessionUseCase,
  IntToAppThemeMapper,
  IsBookmarkedUseCase,
  ListenAppThemeUseCase,
  ListenBookmarksUseCase,
  ListenCollectionCardDataUseCase,
  ListenCollectionsUseCase,
  ListenReaderModeSettingsUseCase,
  ListenSubscriptionStatusUseCase,
  Logger,
  LoggerHandler,
  MapToAppVersionMapper,
  NewPersonalAreaNavActions,
  MoveBookmarkUseCase,
  OnBoardingCompletedUseCase,
  OnBoardingManager,
  OnBoardingNavActions,
  PackageInfo,
  PaymentFlowErrorToErrorMessageMapper,
  PaymentScreenNavActions,
  PaymentService,
  PersonalAreaManager,
  PersonalAreaNavActions,
  PurchasableProductMapper,
  PurchaseEventMapper,
  PurchaseSubscriptionUseCase,
  PurchasesErrorCodeToPaymentFlowErrorMapper,
  ReaderModeSettingsMapper,
  ReaderModeSettingsRepository,
  RemoveBookmarkUseCase,
  RemoveBookmarksUseCase,
  RemoveCollectionUseCase,
  RenameCollectionUseCase,
  RenameDefaultCollectionUseCase,
  RequestCodeRedemptionSheetUseCase,
  RestoreSubscriptionUseCase,
  SaveAppThemeUseCase,
  SaveCurrentAppVersion,
  SaveReaderModeBackgroundColorUseCase,
  SaveReaderModeFontSizeParamUseCase,
  SaveReaderModeFontStyleUseCase,
  SaveSelectedCountriesUseCase,
  SendAnalyticsUseCase,
  SendMarketingAnalyticsUseCase,
  SetInitialIdentityParamsUseCase,
  SetIdentityParamUseCase,
  SetCollectionAndBookmarksChangesIdentityParam,
  SettingsNavActions,
  SettingsScreenManager,
  ShareHandler,
  ShareUriUseCase,
  UniqueIdHandler,
  UpdateSessionUseCase,
  UrlOpener,
])
class Mocks {
  Mocks._();
}

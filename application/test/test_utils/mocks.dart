import 'dart:ui' as ui;

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
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
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/add_source_to_excluded_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/add_source_to_trusted_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_available_sources_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_excluded_sources_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_trusted_sources_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/remove_source_from_excluded_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/remove_source_from_trusted_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/inline_card_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/onboarding_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/payment_flow_error_mapper_to_error_msg_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchasable_product_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchase_event_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/local_notifications_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/remote_notifications_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_marketing_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_collection_and_bookmark_changes_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_experiments_identity_params_use_case.dart';
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
import 'package:xayn_discovery_app/infrastructure/use_case/deep_link/retrieve_deep_link_data_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/can_display_inline_cards.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/can_display_country_selection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/inline_card_injection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/are_local_notifications_allowed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/can_display_push_notifications_card_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/handle_push_notifications_card_clicked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/listen_push_notifications_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/can_display_source_selection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/can_display_survey_banner_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/handle_survey_banner_clicked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/handle_survey_banner_shown_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/listen_survey_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/topic/can_display_topic_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/mark_onboarding_type_completed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/need_to_show_onboarding_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_management_url_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/request_code_redemption_sheet_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/restore_subscription_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/get_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/listen_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/save_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/toggle_push_notifications_state_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_background_color_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_size_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_style_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_id/get_user_id_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/app_image_cache_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/collection_card/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/country/manager/country_feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/inline_card/manager/inline_card_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Please, keep those alphabetically sorted.
/// It is easier to support end expand
@GenerateMocks([
  Mixpanel,
  People,
  AddSourceToExcludedListUseCase,
  AddSourceToTrustedListUseCase,
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
  ConnectivityObserver,
  CountryFeedSettingsManager,
  CreateBookmarkFromDocumentUseCase,
  CreateCollectionUseCase,
  CreateDefaultCollectionUseCase,
  CreateOrGetDefaultCollectionUseCase,
  CrudExplicitDocumentFeedbackUseCase,
  DateTimeHandler,
  DbEntityMapToFeedMarketMapper,
  DbEntityMapToOnboardingStatusMapper,
  DbEntityMapToSurveyInLineCardMapper,
  DbEntityMapToCountrySelectionInLineCardMapper,
  DbEntityMapToSourceSelectionInLineCardMapper,
  DiscoveryCardManager,
  Document,
  DocumentRepository,
  EditReaderModeSettingsManager,
  EngineEventsUseCase,
  ExtractLogUseCase,
  FeatureManager,
  FeedMarketToDbEntityMapMapper,
  FeedRepository,
  FeedSettingsMapper,
  FeedSettingsRepository,
  FeedTypeMarketsRepository,
  FetchSessionUseCase,
  FileHandler,
  File,
  GetAllBookmarksUseCase,
  GetAllCollectionsUseCase,
  GetAppSessionUseCase,
  GetAppThemeUseCase,
  GetAppVersionUseCase,
  GetAvailableSourcesListUseCase,
  GetBookmarkUseCase,
  GetExcludedSourcesListUseCase,
  GetSelectedCountriesUseCase,
  GetStoredAppVersionUseCase,
  GetSubscriptionDetailsUseCase,
  GetSubscriptionManagementUrlUseCase,
  GetSubscriptionStatusUseCase,
  GetSupportedCountriesUseCase,
  GetTrustedSourcesListUseCase,
  HandleSurveyBannerClickedUseCase,
  HandleSurveyBannerShownUseCase,
  HapticFeedbackMediumUseCase,
  HiveExplicitDocumentFeedbackRepository,
  HiveAppSettingsRepository,
  InAppReview,
  ui.Image,
  IncrementAppSessionUseCase,
  IntToAppThemeMapper,
  IsBookmarkedUseCase,
  CanDisplaySurveyBannerUseCase,
  ListenAppThemeUseCase,
  ListenBookmarksUseCase,
  ListenCollectionCardDataUseCase,
  ListenCollectionsUseCase,
  ListenReaderModeSettingsUseCase,
  ListenSubscriptionStatusUseCase,
  ListenSurveyConditionsStatusUseCase,
  Logger,
  LoggerHandler,
  MapToAppVersionMapper,
  MarkOnboardingTypeCompletedUseCase,
  NeedToShowOnboardingUseCase,
  MoveBookmarkUseCase,
  OnboardingStatusToDbEntityMapMapper,
  OverlayManager,
  PackageInfo,
  PaymentFlowErrorToErrorMessageMapper,
  PaymentScreenNavActions,
  PaymentService,
  PersonalAreaNavActions,
  PurchasableProductMapper,
  PurchaseEventMapper,
  PurchaseSubscriptionUseCase,
  PurchasesErrorCodeToPaymentFlowErrorMapper,
  PlatformBrightnessProvider,
  RatingDialogManager,
  ReaderModeSettingsMapper,
  ReaderModeSettingsRepository,
  RemoveBookmarkUseCase,
  RemoveBookmarksUseCase,
  RemoveCollectionUseCase,
  RemoveSourceFromExcludedListUseCase,
  RemoveSourceFromTrustedListUseCase,
  RenameCollectionUseCase,
  RenameDefaultCollectionUseCase,
  RequestCodeRedemptionSheetUseCase,
  RestoreSubscriptionUseCase,
  RetrieveDeepLinkDataUseCase,
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
  SourcesScreenNavActions,
  InLineCardMapper,
  UniqueIdHandler,
  UpdateSessionUseCase,
  UrlOpener,
  UserInteractionsRepository,
  DeepLinkManager,
  MarketingAnalyticsService,
  CountryFeedSettingsNavActions,
  LocalNotificationsService,
  RemoteNotificationsService,
  DiscoveryFeedManager,
  SetExperimentsIdentityParamsUseCase,
  GetPushNotificationsStatusUseCase,
  SavePushNotificationsStatusUseCase,
  InLineCardInjectionUseCase,
  TogglePushNotificationsStatusUseCase,
  ListenPushNotificationsConditionsStatusUseCase,
  ListenPushNotificationsStatusUseCase,
  CanDisplayPushNotificationsCardUseCase,
  CanDisplayInLineCardsUseCase,
  CanDisplaySourceSelectionUseCase,
  CanDisplayCountrySelectionUseCase,
  InLineCardManager,
  HandlePushNotificationsCardClickedUseCase,
  DbEntityMapToPushNotificationsInLineCardMapper,
  SaveUserInteractionUseCase,
  GetUserIdUseCase,
  DbEntityMapToTopicsInLineCardMapper,
  CanDisplayTopicsUseCase,
  AreLocalNotificationsAllowedUseCase,
])
class Mocks {
  Mocks._();
}

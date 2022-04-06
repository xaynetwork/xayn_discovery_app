import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/subscription_type_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_collection_and_bookmark_changes_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_initial_identity_params_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/save_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// Manages the state for the material app.
///
/// It it used to initialise the App with initial data like AppTheme.
/// And also listen for changes to AppTheme.
@lazySingleton
class AppManager extends Cubit<AppState> with UseCaseBlocHelper<AppState> {
  AppManager(
    this._listenAppThemeUseCase,
    this._incrementAppSessionUseCase,
    this._createOrGetDefaultCollectionUseCase,
    this._renameDefaultCollectionUseCase,
    this._setInitialIdentityParamsUseCase,
    this._setIdentityParamUseCase,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._setCollectionAndBookmarksChangesIdentityParam,
    AppSettingsRepository appSettingsRepository,
  ) : super(AppState(appTheme: appSettingsRepository.settings.appTheme)) {
    _init();
  }

  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final IncrementAppSessionUseCase _incrementAppSessionUseCase;
  final SetInitialIdentityParamsUseCase _setInitialIdentityParamsUseCase;
  final SetIdentityParamUseCase _setIdentityParamUseCase;
  final CreateOrGetDefaultCollectionUseCase
      _createOrGetDefaultCollectionUseCase;
  final RenameDefaultCollectionUseCase _renameDefaultCollectionUseCase;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final SetCollectionAndBookmarksChangesIdentityParam
      _setCollectionAndBookmarksChangesIdentityParam;
  late final UseCaseValueStream<AppTheme> _appThemeHandler;
  late final UseCaseValueStream<SubscriptionStatus>
      _listenSubscriptionStatusHandler;

  bool _initDone = false;

  void _init() async {
    scheduleComputeState(() async {
      await _incrementAppSessionUseCase.call(none);
      await _createOrGetDefaultCollectionUseCase
          .call(R.strings.defaultCollectionNameReadLater);
      _appThemeHandler = consume(_listenAppThemeUseCase, initialData: none);
      _listenSubscriptionStatusHandler = consume(
        _listenSubscriptionStatusUseCase,
        initialData: PurchasableIds.subscription,
      ).transform(
        (out) => out.doOnData(_setSubscriptionStatusAnalyticsEvent),
      );

      _setAnalyticsEvents();
      final subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);
      _setSubscriptionStatusAnalyticsEvent(subscriptionStatus);

      _initDone = true;
    });
    _addListener();
  }

  Future<void> maybeUpdateDefaultCollectionName() =>
      _renameDefaultCollectionUseCase
          .call(R.strings.defaultCollectionNameReadLater);

  @override
  Future<AppState?> computeState() async {
    if (!_initDone) return null;
    return fold2(_appThemeHandler, _listenSubscriptionStatusHandler).foldAll(
        (appTheme, _, __) => AppState(appTheme: appTheme ?? state.appTheme));
  }

  void _setAnalyticsEvents() {
    _setInitialIdentityParamsUseCase.call(none);
  }

  void _setSubscriptionStatusAnalyticsEvent(
      SubscriptionStatus subscriptionStatus) {
    final param =
        SubscriptionTypeIdentityParam(subscriptionStatus.subscriptionType);
    _setIdentityParamUseCase.call(param);
  }

  void _addListener() {
    _setCollectionAndBookmarksChangesIdentityParam.call(none);
  }
}

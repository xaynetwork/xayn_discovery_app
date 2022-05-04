import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/mark_onboarding_type_completed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/need_to_show_onboarding_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/payment/util/observe_subscription_window_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';

import 'personal_area_state.dart';

abstract class PersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onSettingsNavPressed();

  void onCollectionPressed(UniqueId collectionId);
}

@lazySingleton
class PersonalAreaManager extends Cubit<PersonalAreaState>
    with
        UseCaseBlocHelper<PersonalAreaState>,
        OverlayManagerMixin<PersonalAreaState>,
        OpenExternalUrlMixin<PersonalAreaState>,
        ObserveSubscriptionWindowMixin<PersonalAreaState>
    implements PersonalAreaNavActions {
  final GetAllCollectionsUseCase _getAllCollectionsUseCase;
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final PersonalAreaNavActions _navActions;
  final DateTimeHandler _dateTimeHandler;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final FeatureManager _featureManager;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final UniqueIdHandler _uniqueIdHandler;
  final NeedToShowOnboardingUseCase _needToShowOnboardingUseCase;
  final MarkOnboardingTypeCompletedUseCase _markOnboardingTypeCompletedUseCase;

  PersonalAreaManager(
    this._getAllCollectionsUseCase,
    this._listenCollectionsUseCase,
    this._hapticFeedbackMediumUseCase,
    this._navActions,
    this._dateTimeHandler,
    this._featureManager,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._uniqueIdHandler,
    this._needToShowOnboardingUseCase,
    this._markOnboardingTypeCompletedUseCase,
  ) : super(PersonalAreaState.initial()) {
    _init();
  }

  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler =
      consume(_listenCollectionsUseCase, initialData: none);
  late final UseCaseValueStream<SubscriptionStatus> _subscriptionStatusHandler =
      consume(
    _listenSubscriptionStatusUseCase,
    initialData: PurchasableIds.subscription,
  );
  late SubscriptionStatus _subscriptionStatus;
  List<ListItemModel> _items = [];
  late final _contactItem =
      ListItemModel.contact(id: _uniqueIdHandler.generateUniqueId());
  String? _useCaseError;

  void _init() {
    scheduleComputeState(() async {
      // read values
      _items = (await _getAllCollectionsUseCase.singleOutput(none))
          .collections
          .map(
            (e) => ListItemModel.collection(
              id: e.id,
              collection: e,
            ),
          )
          .toList()
        ..add(_contactItem);

      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);

      _maybeAddOrUpdateTrialBannerToItems();
    });
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<PersonalAreaState?> computeState() async {
    String errorMsg;
    if (_useCaseError != null) {
      return state.copyWith(errorMsg: _useCaseError);
    }

    return fold2(
      _collectionsHandler,
      _subscriptionStatusHandler,
    ).foldAll(
      (usecaseOut, subscriptionStatus, errorReport) {
        if (errorReport.exists(_collectionsHandler)) {
          final error = errorReport.of(_collectionsHandler)!.error;

          errorMsg = error.toString();

          /// TODO missing error handling
          return state.copyWith(
            errorMsg: errorMsg,
          );
        }

        final newTimestamp = _dateTimeHandler.getDateTimeNow();
        if (usecaseOut != null) {
          _updateItemsWithNewCollections(usecaseOut.collections);
        }
        if (subscriptionStatus != null) {
          _subscriptionStatus = subscriptionStatus;
          _maybeAddOrUpdateTrialBannerToItems();
        }

        return PersonalAreaState.populated(
          _items,
          newTimestamp,
        );
      },
    );
  }

  void _updateItemsWithNewCollections(List<Collection> collections) {
    final List<ListItemModel> newCollectionItems = collections
        .map(
          (e) => ListItemModel.collection(
            id: e.id,
            collection: e,
          ),
        )
        .toList()
      ..add(_contactItem);
    _items.first.map(
      payment: (_) => _items.replaceRange(1, _items.length, newCollectionItems),
      collection: (_) => _items = newCollectionItems,
      contact: (_) => _items = newCollectionItems,
    );
  }

  void _maybeAddOrUpdateTrialBannerToItems() {
    final trialEndDate = _subscriptionStatus.trialEndDate;
    if (_featureManager.isPaymentEnabled &&
        _subscriptionStatus.isFreeTrialActive &&
        trialEndDate != null) {
      _items.first.map(
        collection: (_) => _items.insert(
          0,
          ListItemModel.payment(
            id: _uniqueIdHandler.generateUniqueId(),
            trialEndDate: trialEndDate,
          ),
        ),
        payment: (data) => _items.first = data.copyWith(
          trialEndDate: trialEndDate,
        ),
        contact: (data) => {},
      );
    }
  }

  @override
  void onCollectionPressed(UniqueId collectionId) =>
      _navActions.onCollectionPressed(collectionId);

  @override
  void onHomeNavPressed() => _navActions.onHomeNavPressed();

  @override
  void onActiveSearchNavPressed() => _navActions.onActiveSearchNavPressed();

  @override
  void onSettingsNavPressed() => _navActions.onSettingsNavPressed();

  void checkIfNeedToShowOnboarding() async {
    const type = OnboardingType.collectionsManage;
    final show = await _needToShowOnboardingUseCase.singleOutput(type);
    if (!show) return;
    final data = OverlayData.bottomSheetOnboarding(type, () {
      _markOnboardingTypeCompletedUseCase.call(type);
    });
    showOverlay(data);
  }
}

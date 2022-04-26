import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/payment/util/observe_subscription_window_mixin.dart';

import 'new_personal_area_state.dart';

abstract class NewPersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onSettingsNavPressed();

  void onCollectionPressed(UniqueId collectionId);
}

@injectable
class NewPersonalAreaManager extends Cubit<NewPersonalAreaState>
    with
        UseCaseBlocHelper<NewPersonalAreaState>,
        ObserveSubscriptionWindowMixin<NewPersonalAreaState>
    implements NewPersonalAreaNavActions {
  final GetAllCollectionsUseCase _getAllCollectionsUseCase;
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final NewPersonalAreaNavActions _navActions;
  final DateTimeHandler _dateTimeHandler;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final FeatureManager _featureManager;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final UniqueIdHandler _uniqueIdHandler;

  NewPersonalAreaManager(
    this._getAllCollectionsUseCase,
    this._listenCollectionsUseCase,
    this._hapticFeedbackMediumUseCase,
    this._navActions,
    this._dateTimeHandler,
    this._featureManager,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._uniqueIdHandler,
  ) : super(NewPersonalAreaState.initial()) {
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
          .toList();

      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);

      _maybeUpdateTrialBannerToItems();
    });
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<NewPersonalAreaState?> computeState() async {
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
          _maybeUpdateTrialBannerToItems();
        }

        return NewPersonalAreaState.populated(
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
        .toList();
    _items.first.map(
      payment: (_) => _items.replaceRange(1, _items.length, newCollectionItems),
      collection: (_) => _items = newCollectionItems,
    );
  }

  void _maybeUpdateTrialBannerToItems() {
    final trialEndDate = _subscriptionStatus.trialEndDate;
    if (!_featureManager.isPaymentEnabled || trialEndDate == null) return;
    if (_subscriptionStatus.isFreeTrialActive) {
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
      );
    } else {
      _items.first.map(
        payment: (_) => _items.removeAt(0),
        collection: (item) => item,
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
}

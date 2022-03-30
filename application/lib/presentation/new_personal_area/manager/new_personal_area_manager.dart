import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/list_item_model.dart';

import 'new_personal_area_state.dart';

abstract class NewPersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onSettingsNavPressed();

  void onCollectionPressed(UniqueId collectionId);
}

@injectable
class NewPersonalAreaManager extends Cubit<NewPersonalAreaState>
    with UseCaseBlocHelper<NewPersonalAreaState>
    implements NewPersonalAreaNavActions {
  final CreateCollectionUseCase _createCollectionUseCase;
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final RenameCollectionUseCase _renameCollectionUseCase;
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final CollectionErrorsEnumMapper _collectionErrorsEnumMapper;
  final NewPersonalAreaNavActions _navActions;
  final DateTimeHandler _dateTimeHandler;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final FeatureManager _featureManager;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;

  NewPersonalAreaManager._(
    this._createCollectionUseCase,
    this._removeCollectionUseCase,
    this._renameCollectionUseCase,
    this._listenCollectionsUseCase,
    this._hapticFeedbackMediumUseCase,
    this._collectionErrorsEnumMapper,
    this._navActions,
    this._dateTimeHandler,
    this._featureManager,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._items,
  ) : super(NewPersonalAreaState.initial()) {
    _init();
  }

  @factoryMethod
  static Future<NewPersonalAreaManager> create(
    CreateCollectionUseCase createCollectionUseCase,
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    RemoveCollectionUseCase removeCollectionUseCase,
    RenameCollectionUseCase renameCollectionUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase,
    CollectionErrorsEnumMapper collectionErrorsEnumMapper,
    NewPersonalAreaNavActions navActions,
    DateTimeHandler dateTimeHandler,
    FeatureManager featureManager,
    GetSubscriptionStatusUseCase getSubscriptionStatusUseCase,
    ListenSubscriptionStatusUseCase listenSubscriptionStatusUseCase,
  ) async {
    final items = (await getAllCollectionsUseCase.singleOutput(none))
        .collections
        .map(
          (e) => ListItemModel(
            id: e.id,
            collection: e,
          ),
        )
        .toList();

    return NewPersonalAreaManager._(
      createCollectionUseCase,
      removeCollectionUseCase,
      renameCollectionUseCase,
      listenCollectionsUseCase,
      hapticFeedbackMediumUseCase,
      collectionErrorsEnumMapper,
      navActions,
      dateTimeHandler,
      featureManager,
      getSubscriptionStatusUseCase,
      listenSubscriptionStatusUseCase,
      items,
    );
  }

  late List<ListItemModel> _items;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  late final UseCaseValueStream<SubscriptionStatus> _subscriptionStatusHandler;
  late SubscriptionStatus _subscriptionStatus;
  String? _useCaseError;

  void _init() {
    scheduleComputeState(() async {
      _collectionsHandler =
          consume(_listenCollectionsUseCase, initialData: none);

      // read values
      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);

      _maybeAddOrUpdateTrialBannerToItems();

      // attach listeners
      _subscriptionStatusHandler = consume(
        _listenSubscriptionStatusUseCase,
        initialData: PurchasableIds.subscription,
      );
    });
  }

  Future<Collection?> createCollection({required String collectionName}) async {
    _useCaseError = null;
    Collection? createdCollection;
    final useCaseOut = await _createCollectionUseCase.call(collectionName);

    /// We just need to handle the failure case.
    /// In case of success we will automatically get the updated list of Collections
    /// since we are listening to the repo through the [ListenCollectionsUseCase]
    useCaseOut.last.fold(
      defaultOnError: _defaultOnError,
      matchOnError: {
        On<CollectionUseCaseError>(_matchOnCollectionUseCaseError)
      },
      onValue: (collection) => createdCollection = collection,
    );

    return _useCaseError == null ? createdCollection : null;
  }

  void renameCollection({
    required UniqueId collectionId,
    required String newName,
  }) async {
    _useCaseError = null;
    final param = RenameCollectionUseCaseParam(
      collectionId: collectionId,
      newName: newName,
    );
    final useCaseOut = await _renameCollectionUseCase.call(param);

    /// We just need to handle the failure case.
    /// In case of success we will automatically get the updated list of Collections
    /// since we are listening to the repo through the [ListenCollectionsUseCase]
    useCaseOut.last.fold(
      defaultOnError: _defaultOnError,
      matchOnError: {
        On<CollectionUseCaseError>(_matchOnCollectionUseCaseError)
      },
      onValue: (_) {},
    );
  }

  void removeCollection({
    required UniqueId collectionIdToRemove,
    UniqueId? collectionIdMoveBookmarksTo,
  }) async {
    _useCaseError = null;
    final param = RemoveCollectionUseCaseParam(
      collectionIdToRemove: collectionIdToRemove,
      collectionIdMoveBookmarksTo: collectionIdMoveBookmarksTo,
    );
    final useCaseOut = await _removeCollectionUseCase.call(param);

    /// We just need to handle the failure case.
    /// In case of success we will automatically get the updated list of Collections
    /// since we are listening to the repo through the [ListenCollectionsUseCase]
    useCaseOut.last.fold(
      defaultOnError: _defaultOnError,
      matchOnError: {
        On<CollectionUseCaseError>(_matchOnCollectionUseCaseError)
      },
      onValue: (_) {},
    );
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
          _maybeAddOrUpdateTrialBannerToItems();
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
          (e) => ListItemModel(
            id: e.id,
            collection: e,
          ),
        )
        .toList();
    if (_items.first.isTrialBanner) {
      _items.replaceRange(1, _items.length, newCollectionItems);
    } else {
      _items = newCollectionItems;
    }
  }

  void _maybeAddOrUpdateTrialBannerToItems() {
    if (_featureManager.isPaymentEnabled &&
        _subscriptionStatus.isFreeTrialActive) {
      if (_items.first.isCollection) {
        _items.insert(
          0,
          ListItemModel(
            id: UniqueId(),
            trialEndDate: _subscriptionStatus.trialEndDate,
          ),
        );
      } else {
        _items.first = _items.first
            .copyWith(trialEndDate: _subscriptionStatus.trialEndDate);
      }
    }
  }

  void _defaultOnError(Object e, StackTrace? s) =>
      scheduleComputeState(() => _useCaseError = e.toString());

  void _matchOnCollectionUseCaseError(Object e, StackTrace? s) =>
      scheduleComputeState(
        () => _useCaseError = _collectionErrorsEnumMapper.mapEnumToString(
          e as CollectionUseCaseError,
        ),
      );

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
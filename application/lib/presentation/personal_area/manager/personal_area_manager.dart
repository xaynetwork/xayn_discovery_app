import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/mark_onboarding_type_completed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/need_to_show_onboarding_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/mixin/collection_manager_flow_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

import 'personal_area_state.dart';

abstract class PersonalAreaNavActions {
  void onHomeNavPressed();

  void onSettingsNavPressed();

  void onCollectionPressed(UniqueId collectionId);
}

@lazySingleton
class PersonalAreaManager extends Cubit<PersonalAreaState>
    with
        UseCaseBlocHelper<PersonalAreaState>,
        OverlayManagerMixin<PersonalAreaState>,
        OpenExternalUrlMixin<PersonalAreaState>,
        CollectionManagerFlowMixin<PersonalAreaState>
    implements PersonalAreaNavActions {
  final GetAllCollectionsUseCase _getAllCollectionsUseCase;
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final PersonalAreaNavActions _navActions;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final FeatureManager _featureManager;
  final UniqueIdHandler _uniqueIdHandler;
  final NeedToShowOnboardingUseCase _needToShowOnboardingUseCase;
  final MarkOnboardingTypeCompletedUseCase _markOnboardingTypeCompletedUseCase;

  PersonalAreaManager(
    this._getAllCollectionsUseCase,
    this._listenCollectionsUseCase,
    this._hapticFeedbackMediumUseCase,
    this._navActions,
    this._featureManager,
    this._uniqueIdHandler,
    this._needToShowOnboardingUseCase,
    this._markOnboardingTypeCompletedUseCase,
  ) : super(PersonalAreaState.initial()) {
    _init();
  }

  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler =
      consume(_listenCollectionsUseCase, initialData: none);
  List<ListItemModel> _collectionItems = [];
  late final _contactItem =
      ListItemModel.contact(id: _uniqueIdHandler.generateUniqueId());
  ListItemModel? _paymentItem;
  String? _useCaseError;

  void _init() {
    scheduleComputeState(() async {
      // read values
      _updateItemsWithNewCollections(
          (await _getAllCollectionsUseCase.singleOutput(none)).collections);
    });
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<PersonalAreaState?> computeState() async {
    String errorMsg;
    if (_useCaseError != null) {
      return state.copyWith(errorMsg: _useCaseError);
    }

    return fold(_collectionsHandler).foldAll(
      (usecaseOut, errorReport) {
        if (errorReport.exists(_collectionsHandler)) {
          final error = errorReport.of(_collectionsHandler)!.error;

          errorMsg = error.toString();

          /// TODO missing error handling
          return state.copyWith(
            errorMsg: errorMsg,
          );
        }

        if (usecaseOut != null) {
          _updateItemsWithNewCollections(usecaseOut.collections);
        }

        return PersonalAreaState.populated(
          [
            if (_paymentItem != null) _paymentItem!,
            ..._collectionItems,
            _contactItem,
          ],
        );
      },
    );
  }

  void _updateItemsWithNewCollections(List<Collection> collections) {
    _collectionItems = collections
        .map(
          (e) => ListItemModel.collection(
            id: e.id,
            collection: e,
          ),
        )
        .toList();
  }

  @override
  void onCollectionPressed(UniqueId collectionId) =>
      _navActions.onCollectionPressed(collectionId);

  @override
  void onHomeNavPressed() => _navActions.onHomeNavPressed();

  @override
  void onSettingsNavPressed() => _navActions.onSettingsNavPressed();

  void checkIfNeedToShowOnboarding() async {
    if (!_featureManager.isOnBoardingSheetsEnabled) return;

    const type = OnboardingType.collectionsManage;
    final show = await _needToShowOnboardingUseCase.singleOutput(type);
    if (!show) return;
    final data = OverlayData.bottomSheetOnboarding(type, () {
      _markOnboardingTypeCompletedUseCase.call(type);
    });
    showOverlay(data);
  }

  void onAddCollectionPressed() => showOverlay(
        OverlayData.bottomSheetCreateOrRenameCollection(),
      );

  void onContactPressed() {
    void onXaynSupportEmailTap() =>
        openExternalEmail(Constants.xaynSupportEmail);

    void onXaynPressEmailTap() => openExternalEmail(Constants.xaynPressEmail);

    void onXaynUrlTap() => openExternalUrl(url: Constants.xaynUrl);

    showOverlay(
      OverlayData.bottomSheetContactInfo(
        onXaynSupportEmailTap: onXaynSupportEmailTap,
        onXaynPressEmailTap: onXaynPressEmailTap,
        onXaynUrlTap: onXaynUrlTap,
      ),
    );
  }

  void onCollectionSwipeEdit(Collection collection) => showOverlay(
        OverlayData.bottomSheetCreateOrRenameCollection(
          collection: collection,
        ),
      );

  void onCollectionSwipeRemove(
    Collection collection, {
    VoidCallback? onClose,
    bool showBarrierColor = true,
  }) =>
      showOverlay(
        OverlayData.bottomSheetDeleteCollectionConfirmation(
          collectionId: collection.id,
          showBarrierColor: showBarrierColor,
          onClose: onClose,
          onMovePressed: (bookmarkIds) => startMoveBookmarksFlow(
            bookmarkIds,
            collectionIdToRemove: collection.id,
            onClose: onClose,
          ),
        ),
      );

  void onCollectionLongPress(
    Collection collection,
    VoidCallback onClose,
  ) {
    void onDeletePressed() => onCollectionSwipeRemove(
          collection,
          onClose: onClose,
          showBarrierColor: false,
        );

    void onRenamePressed() => showOverlay(
          OverlayData.bottomSheetCreateOrRenameCollection(
            showBarrierColor: false,
            onSystemPop: onClose,
            collection: collection,
          ),
        );

    showOverlay(
      OverlayData.bottomSheetCollectionOptions(
        collection: collection,
        onClose: onClose,
        onDeletePressed: onDeletePressed,
        onRenamePressed: onRenamePressed,
      ),
    );
  }
}

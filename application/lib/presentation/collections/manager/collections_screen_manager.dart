import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_state.dart';

abstract class CollectionsScreenNavActions {
  void onBackNavPressed();

  void onCollectionPressed(UniqueId collectionId);
}

@injectable
class CollectionsScreenManager extends Cubit<CollectionsScreenState>
    with UseCaseBlocHelper<CollectionsScreenState>
    implements CollectionsScreenNavActions {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final CollectionsScreenNavActions _navActions;
  final DateTimeHandler _dateTimeHandler;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;

  CollectionsScreenManager._(
    this._listenCollectionsUseCase,
    this._hapticFeedbackMediumUseCase,
    this._navActions,
    this._dateTimeHandler,
    this._collections,
  ) : super(CollectionsScreenState.initial()) {
    _init();
  }

  @factoryMethod
  static Future<CollectionsScreenManager> create(
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    HapticFeedbackMediumUseCase hapticFeedbackMediumUseCase,
    CollectionsScreenNavActions navActions,
    DateTimeHandler dateTimeHandler,
  ) async {
    final collections =
        (await getAllCollectionsUseCase.singleOutput(none)).collections;

    return CollectionsScreenManager._(
      listenCollectionsUseCase,
      hapticFeedbackMediumUseCase,
      navActions,
      dateTimeHandler,
      collections,
    );
  }

  late List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  String? _useCaseError;

  void _init() {
    _collectionsHandler = consume(_listenCollectionsUseCase, initialData: none);
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<CollectionsScreenState?> computeState() async {
    String errorMsg;
    if (_useCaseError != null) {
      return state.copyWith(errorMsg: _useCaseError);
    }

    return fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
      if (errorReport.exists(_collectionsHandler)) {
        final error = errorReport.of(_collectionsHandler)!.error;

        errorMsg = error.toString();

        return state.copyWith(
          errorMsg: errorMsg,
        );
      }
      final newTimestamp = _dateTimeHandler.getDateTimeNow();
      if (usecaseOut != null) {
        _collections = usecaseOut.collections;
      }
      return CollectionsScreenState.populated(
        _collections,
        newTimestamp,
      );
    });
  }

  @override
  void onBackNavPressed() => _navActions.onBackNavPressed();

  @override
  void onCollectionPressed(UniqueId collectionId) =>
      _navActions.onCollectionPressed(collectionId);
}

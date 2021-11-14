import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

part 'race_condition_manager.freezed.dart';
part 'race_condition_manager.g.dart';

typedef UpdateHandler = RaceConditionState Function(RaceConditionState state);
typedef SettingsHandler = void Function(UpdateHandler updateHandler);

/// Note:
/// Use below code to test this setup:
/// final RaceConditionManager manager = di.get();
///
///     fakeHiveAdapter.stream.listen((event) => print({
///       'a': event.a,
///       'b': event.b,
///       'c': event.c,
///       'd': event.d,
///     }.toString())); // emits: {a: 2, b: 3, c: 4, d: 5} eventually
///
///     manager.handleUpdateA(1);
///     manager.handleUpdateB(1);
///     manager.handleUpdateC(1);
///     manager.handleUpdateD(1);
///
///     manager.handleUpdateA(2);
///     manager.handleUpdateB(3);
///     manager.handleUpdateC(4);
///     manager.handleUpdateD(5);
///

/// The fake hive box's adapter
final FakeHiveAdapter fakeHiveAdapter = FakeHiveAdapter();

@injectable
class RaceConditionManager extends Cubit<bool> with UseCaseBlocHelper<bool> {
  final UpdateSettingsUseCase updateSettingsUseCase;
  final StoreSettingsUseCase storeSettingsUseCase;

  late final UseCaseSink<UpdateHandler, RaceConditionState> _handleUpdateA;
  late final UseCaseSink<UpdateHandler, RaceConditionState> _handleUpdateB;
  late final UseCaseSink<UpdateHandler, RaceConditionState> _handleUpdateC;

  RaceConditionManager(
    this.updateSettingsUseCase,
    this.storeSettingsUseCase,
  ) : super(false) {
    _init();
  }

  void handleUpdateA(int paramA) =>
      _handleUpdateA((state) => state.copyWith(a: paramA));
  void handleUpdateB(int paramB) =>
      _handleUpdateB((state) => state.copyWith(b: paramB));
  void handleUpdateC(int paramC) =>
      _handleUpdateC((state) => state.copyWith(c: paramC));

  Future<void> _init() async {
    _handleUpdateA = pipe(updateSettingsUseCase)
        .transform((out) => out.followedBy(storeSettingsUseCase));

    _handleUpdateB = pipe(updateSettingsUseCase)
        .transform((out) => out.followedBy(storeSettingsUseCase));

    _handleUpdateC = pipe(updateSettingsUseCase)
        .transform((out) => out.followedBy(storeSettingsUseCase));
  }

  @override
  Future<bool> computeState() async =>
      fold3(_handleUpdateA, _handleUpdateB, _handleUpdateC)
          .foldAll((a, b, c, errorReport) {
        if (errorReport.isNotEmpty) {
          return false;
        }

        return true;
      });
}

@injectable
class UpdateSettingsUseCase extends UseCase<UpdateHandler, RaceConditionState> {
  @override
  Stream<RaceConditionState> transaction(UpdateHandler param) async* {
    yield* fakeHiveAdapter.stream
        .where((state) => state != param(state))
        .map(param);
  }

  /// "Reset" if fakeHiveAdapter had an update during the lifetime of
  /// [UpdateSettingsUseCase]
  @override
  Stream<UpdateHandler> transform(Stream<UpdateHandler> incoming) =>
      incoming.switchMap((it) => fakeHiveAdapter.stream.mapTo(it));
}

@injectable
class StoreSettingsUseCase
    extends UseCase<RaceConditionState, RaceConditionState> {
  @override
  Stream<RaceConditionState> transaction(RaceConditionState param) async* {
    // write success, push stored value
    fakeHiveAdapter.update(param);
    // yield stored value
    yield param;
  }
}

@freezed
class RaceConditionState with _$RaceConditionState {
  const factory RaceConditionState({
    required int a,
    required int b,
    required int c,
    required int d,
  }) = _RaceConditionState;

  factory RaceConditionState.fromJson(Map<String, dynamic> json) =>
      _$RaceConditionStateFromJson(json);
}

/// todo: should be auto-generated
/// unwraps a complex data type,
/// stores individual properties as key/value
/// emits the latest combined [RaceConditionState] always.
class FakeHiveAdapter {
  // RaceConditionState has a, b, c, d properties
  // this is representing the single-storage
  final propertyStoreA = BehaviorSubject.seeded(0);
  final propertyStoreB = BehaviorSubject.seeded(0);
  final propertyStoreC = BehaviorSubject.seeded(0);
  final propertyStoreD = BehaviorSubject.seeded(0);

  Stream<RaceConditionState>? _stream;
  Stream<RaceConditionState> get stream =>
      _stream ??
      Rx.combineLatest4(
          propertyStoreA,
          propertyStoreB,
          propertyStoreC,
          propertyStoreD,
          (int a, int b, int c, int d) =>
              RaceConditionState(a: a, b: b, c: c, d: d));

  void update(RaceConditionState state) {
    // todo: we should really consider doing updates in a transactional way
    final rollbackState = RaceConditionState(
      a: propertyStoreA.value,
      b: propertyStoreB.value,
      c: propertyStoreC.value,
      d: propertyStoreD.value,
    );

    try {
      if (propertyStoreA.value != state.a) propertyStoreA.add(state.a);
      if (propertyStoreB.value != state.b) propertyStoreB.add(state.b);
      if (propertyStoreC.value != state.c) propertyStoreC.add(state.c);
      if (propertyStoreD.value != state.d) propertyStoreD.add(state.d);
    } catch (e) {
      // transaction failed, do rollback
      update(rollbackState);
    }
  }
}

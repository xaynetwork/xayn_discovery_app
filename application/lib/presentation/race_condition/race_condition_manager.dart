import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/concepts/on_failure.dart';
import 'package:xayn_architecture/concepts/use_case.dart';

part 'race_condition_manager.freezed.dart';
part 'race_condition_manager.g.dart';

typedef UpdateHandler = RaceConditionState Function(RaceConditionState state);
typedef SettingsHandler = void Function(UpdateHandler updateHandler);

final fakeHive = BehaviorSubject.seeded(const RaceConditionState(
  a: 0,
  b: 0,
  c: 0,
  d: 0,
));

@injectable
class RaceConditionManager extends Cubit<bool> with UseCaseBlocHelper<bool> {
  final UpdateSettingsUseCase updateSettingsUseCase;
  final StoreSettingsUseCase storeSettingsUseCase;

  late final SettingsHandler _handleUpdateA;
  late final SettingsHandler _handleUpdateB;
  late final SettingsHandler _handleUpdateC;
  late final SettingsHandler _handleUpdateD;

  RaceConditionManager(
    this.updateSettingsUseCase,
    this.storeSettingsUseCase,
  ) : super(false) {
    _init();
  }

  void handleUpdateA(int paramA) =>
      _handleUpdateA((state) => state.copyWith(a: paramA));
  void handleUpdateB(int paramA) =>
      _handleUpdateB((state) => state.copyWith(b: paramA));
  void handleUpdateC(int paramA) =>
      _handleUpdateC((state) => state.copyWith(c: paramA));
  void handleUpdateD(int paramA) =>
      _handleUpdateD((state) => state.copyWith(d: paramA));

  Future<void> _init() async {
    _handleUpdateA = pipe(updateSettingsUseCase)
        .transform((out) => out.followedBy(storeSettingsUseCase))
        .fold(
          onSuccess: (it) => true,
          onFailure: HandleFailure(
            (e, st) {
              print('$e $st');
              return false;
            },
          ),
        );

    _handleUpdateB = pipe(updateSettingsUseCase)
        .transform((out) => out.followedBy(storeSettingsUseCase))
        .fold(
          onSuccess: (it) => true,
          onFailure: HandleFailure(
            (e, st) {
              print('$e $st');
              return false;
            },
          ),
        );

    _handleUpdateC = pipe(updateSettingsUseCase)
        .transform((out) => out.followedBy(storeSettingsUseCase))
        .fold(
          onSuccess: (it) => true,
          onFailure: HandleFailure(
            (e, st) {
              print('$e $st');
              return false;
            },
          ),
        );

    _handleUpdateD = pipe(updateSettingsUseCase)
        .transform((out) => out.followedBy(storeSettingsUseCase))
        .fold(
          onSuccess: (it) => true,
          onFailure: HandleFailure(
            (e, st) {
              print('$e $st');
              return false;
            },
          ),
        );
  }
}

@injectable
class UpdateSettingsUseCase extends UseCase<UpdateHandler, RaceConditionState> {
  @override
  Stream<RaceConditionState> transaction(UpdateHandler param) async* {
    yield* fakeHive.stream.where((state) => state != param(state)).map(param);
  }
}

@injectable
class StoreSettingsUseCase
    extends UseCase<RaceConditionState, RaceConditionState> {
  @override
  Stream<RaceConditionState> transaction(RaceConditionState param) async* {
    // fake io write delay
    await Future.delayed(const Duration(milliseconds: 20));
    // write success, push stored value
    fakeHive.add(param);
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

class RaceConditionStateAndParam {
  final RaceConditionState state;
  final int param;

  const RaceConditionStateAndParam({
    required this.state,
    required this.param,
  });
}

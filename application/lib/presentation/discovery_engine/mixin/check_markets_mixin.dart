import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/check_markets_use_case.dart';

mixin CheckMarketsMixin<T> on UseCaseBlocHelper<T> {
  CheckMarketsUseCase? _useCase;

  @override
  Future<void> close() {
    _useCase = null;

    return super.close();
  }

  Future<void> checkMarkets() async {
    _useCase ??= di.get<CheckMarketsUseCase>();
    final result = await _useCase!(none);

    for (final event in result) {
      event.fold(
          defaultOnError: (e, s) => onError(e, s ?? StackTrace.current),
          onValue: (it) {
            switch (it) {
              case MarketChange.willChange:
                willChangeMarkets();
                break;
              case MarketChange.didChange:
                didChangeMarkets();
                break;
              default:
                break;
            }
          });
    }
  }

  /// Runs right before the Configuration is updated,
  /// Since this is expensive, we can run an action just before this triggers
  @mustCallSuper
  void willChangeMarkets();

  /// Runs right after the Configuration was updated.
  @mustCallSuper
  void didChangeMarkets();
}

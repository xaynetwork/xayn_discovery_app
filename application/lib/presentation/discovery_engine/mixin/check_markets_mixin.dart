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

  void checkMarkets() async {
    _useCase ??= di.get<CheckMarketsUseCase>();
    final result = await _useCase!(none);

    if (result.isNotEmpty) didChangeMarkets();
  }

  @mustCallSuper
  void didChangeMarkets();
}

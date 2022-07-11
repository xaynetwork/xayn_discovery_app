import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:platform/platform.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class RequestCodeRedemptionSheetUseCase extends UseCase<None, None> {
  final PaymentService _paymentService;
  final bool _isIOS;

  RequestCodeRedemptionSheetUseCase(
    this._paymentService,
    Platform platform,
  ) : _isIOS = platform.isIOS;

  @visibleForTesting
  RequestCodeRedemptionSheetUseCase.test(
    this._paymentService,
    this._isIOS,
  );

  @override
  Stream<None> transaction(None param) async* {
    if (!_isIOS) {
      throw UnsupportedError('This useCase can be used only with ios platform');
    }

    await _paymentService.presentCodeRedemptionSheet();
    yield none;
  }
}

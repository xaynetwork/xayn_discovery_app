import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/purchaser_info_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class RestoreSubscriptionUseCase
    extends UseCase<None, PurchasableProductStatus> {
  final PaymentService _paymentService;
  final PurchasesErrorCodeToPaymentFlowErrorMapper _errorMapper;

  RestoreSubscriptionUseCase(
    this._paymentService,
    this._errorMapper,
  );

  @override
  Stream<PurchasableProductStatus> transaction(None param) async* {
    yield PurchasableProductStatus.restorePending;
    try {
      final info = await _paymentService.restore();
      final restored = info.expirationDate?.isAfter(DateTime.now()) ?? false;
      yield restored
          ? PurchasableProductStatus.restored
          : throw PaymentFlowError.noActiveSubscriptionFound;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      throw _errorMapper.map(errorCode);
    }
  }
}

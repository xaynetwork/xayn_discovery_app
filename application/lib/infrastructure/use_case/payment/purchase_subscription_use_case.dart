import 'dart:async';

import 'package:collection/collection.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class PurchaseSubscriptionUseCase
    extends UseCase<PurchasableProductId, PurchasableProductStatus> {
  final PaymentService _paymentService;
  final IAPErrorToPaymentFlowErrorMapper _errorMapper;

  PurchaseSubscriptionUseCase(
    this._paymentService,
    this._errorMapper,
  );

  @override
  Stream<PurchasableProductStatus> transaction(
      PurchasableProductId param) async* {
    final isAvailable = await _paymentService.isAvailable();
    if (!isAvailable) {
      throw PaymentFlowError.storeNotAvailable;
    }
    final response = await _paymentService.queryProductDetails({param});

    if (response.notFoundIDs.contains(param)) {
      throw PaymentFlowError.productNotFound;
    }

    final details = response.productDetails.first;
    _paymentService.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );

    yield* _paymentService.purchaseStream.transform(_getTransformer(param));
  }

  StreamTransformer<List<PurchaseDetails>, PurchasableProductStatus>
      _getTransformer(PurchasableProductId id) =>
          StreamTransformer.fromHandlers(
            handleData: (
              List<PurchaseDetails> purchases,
              EventSink<PurchasableProductStatus> sink,
            ) {
              final subscription = purchases
                  .firstWhereOrNull((element) => element.productID == id);
              if (subscription == null) return;
              late PurchasableProductStatus status;
              switch (subscription.status) {
                case PurchaseStatus.error:
                  throw _errorMapper.map(subscription.error!);
                case PurchaseStatus.pending:
                  status = PurchasableProductStatus.pending;
                  break;
                case PurchaseStatus.purchased:
                  _paymentService.completePurchase(subscription);
                  status = PurchasableProductStatus.purchased;
                  break;
                case PurchaseStatus.restored:
                  _paymentService.completePurchase(subscription);
                  status = PurchasableProductStatus.restored;
                  break;
                case PurchaseStatus.canceled:
                  status = PurchasableProductStatus.canceled;
                  break;
              }
              sink.add(status);
            },
          );
}

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';

@injectable
class ListenSubscriptionPurchaseUseCase
    extends UseCase<None, PurchasableProductStatus> {
  final PaymentService _paymentService;
  final IAPErrorToPaymentFlowErrorMapper _errorMapper;

  ListenSubscriptionPurchaseUseCase(
    this._paymentService,
    this._errorMapper,
  );

  @override
  Stream<PurchasableProductStatus> transaction(None param) async* {
    final transformer = StreamTransformer.fromHandlers(
      handleData: (
        List<PurchaseDetails> purchasedDetails,
        Sink<PurchasableProductStatus> sink,
      ) {
        final subscription = purchasedDetails.firstWhereOrNull(
          (element) => element.productID == PurchasableIds.subscription,
        );
        if (subscription == null) return;

        switch (subscription.status) {
          case PurchaseStatus.pending:
            sink.add(PurchasableProductStatus.pending);
            break;
          case PurchaseStatus.purchased:
            sink.add(PurchasableProductStatus.purchased);
            _paymentService.completePurchase(subscription);
            break;
          case PurchaseStatus.error:
            throw _errorMapper.map(subscription.error!);
          case PurchaseStatus.restored:
            sink.add(PurchasableProductStatus.restored);
            _paymentService.completePurchase(subscription);
            break;
          case PurchaseStatus.canceled:
            sink.add(PurchasableProductStatus.canceled);
            break;
        }
      },
    );
    yield* _paymentService.purchaseStream.transform(transformer);
  }
}

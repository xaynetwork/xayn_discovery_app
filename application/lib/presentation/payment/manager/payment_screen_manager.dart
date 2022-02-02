import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/restore_purchased_subsctiption_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_purchase_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/subscribe_use_case.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';

@injectable
class PaymentScreenManager extends Cubit<PaymentScreenState>
    with UseCaseBlocHelper<PaymentScreenState> {
  final GetSubscriptionDetailsUseCase _getPurchasableProductUseCase;
  final SubscribeUseCase _subscribeUseCase;
  final RestorePurchasedSubscriptionUseCase _restorePurchasedSubscription;
  final ListenSubscriptionPurchaseUseCase _listenSubscriptionPurchaseUseCase;
  late final UseCaseValueStream<ListenSubscriptionPurchaseOutput>
      _purchasableProductStatusChangeHandler;

  PaymentScreenManager(
    this._getPurchasableProductUseCase,
    this._subscribeUseCase,
    this._restorePurchasedSubscription,
    this._listenSubscriptionPurchaseUseCase,
  ) : super(const PaymentScreenState.initial()) {
    _getSubscriptionProduct();
  }

  PurchasableProduct? _subscriptionProduct;
  String? _paymentFlowErrorMsg;

  void subscribe() async {
    final product = _subscriptionProduct;
    if (product == null || !product.canBePurchased) return;

    await _subscribeUseCase.call(none);
  }

  @override
  FutureOr<PaymentScreenState?> computeState() {
    final product = _subscriptionProduct;
    try {
      if (product == null) return super.computeState();
      return fold(_purchasableProductStatusChangeHandler)
          .foldAll((statusUpdate, errorReport) {
        if (errorReport.isNotEmpty) {
          // map error to the human readable message
        }

        final updatedProduct = statusUpdate?.map(
                statusChanged: (statusChanged) =>
                    statusChanged.productId == product.id
                        ? product.copyWith(statusChanged.status)
                        : product,
                error: (error) {
                  if (error.productId == product.id) {
                    _paymentFlowErrorMsg = 'should be mapped here';
                  }
                  return product;
                }) ??
            product;

        return PaymentScreenState.ready(
          product: updatedProduct,
          errorMsg: _paymentFlowErrorMsg,
        );
      });
    } finally {
      // we need this try/finally to prevent same error msg be shown
      // more then 1 time
      _paymentFlowErrorMsg = null;
    }
  }

  void _getSubscriptionProduct() async {
    _getPurchasableProductUseCase
        .call(none)
        .then((results) => results.last.fold(
              defaultOnError: (object, _) {
                if (object is PaymentFlowError) {
                  // map error to the human readable message
                }
              },
              onValue: (PurchasableProduct product) {
                scheduleComputeState(() => _subscriptionProduct = product);
              },
            ));

    _purchasableProductStatusChangeHandler =
        consume(_listenSubscriptionPurchaseUseCase, initialData: none);
    _restorePurchasedSubscription.singleOutput(none);
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/check_subscription_active_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';

@injectable
class PaymentScreenManager extends Cubit<PaymentScreenState>
    with UseCaseBlocHelper<PaymentScreenState> {
  final GetSubscriptionDetailsUseCase _getPurchasableProductUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final CheckSubscriptionActiveUseCase _checkSubscriptionActiveUseCase;
  late final UseCaseSink<PurchasableProductId, PurchasableProductStatus>
      _purchaseSubscriptionHandler = pipe(_purchaseSubscriptionUseCase);

  PaymentScreenManager(
    this._getPurchasableProductUseCase,
    this._purchaseSubscriptionUseCase,
    this._checkSubscriptionActiveUseCase,
  ) : super(const PaymentScreenState.initial()) {
    _getSubscriptionProduct();
  }

  PurchasableProduct? _subscriptionProduct;
  String? _paymentFlowErrorMsg;

  void subscribe() {
    final product = _subscriptionProduct;
    if (product == null || !product.canBePurchased) return;

    _purchaseSubscriptionHandler(PurchasableIds.subscription);
  }

  @override
  FutureOr<PaymentScreenState?> computeState() {
    final product = _subscriptionProduct;
    try {
      if (product == null) return super.computeState();
      return fold(_purchaseSubscriptionHandler)
          .foldAll((final updatedStatus, final errorReport) {
        if (errorReport.isNotEmpty) {
          // map error to the human readable message
          _paymentFlowErrorMsg = 'should be mapped here';
          return PaymentScreenState.ready(
            product: product,
            errorMsg: _paymentFlowErrorMsg,
          );
        }

        return PaymentScreenState.ready(
          product:
              updatedStatus == null ? product : product.copyWith(updatedStatus),
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
    final isAvailable = await _checkSubscriptionActiveUseCase
        .singleOutput(PurchasableIds.subscription);
    _getPurchasableProductUseCase.call(none).then(
          (results) => results.last.fold(
            defaultOnError: (object, _) {
              if (object is PaymentFlowError) {
                // map error to the human readable message
              }
            },
            onValue: (PurchasableProduct product) {
              scheduleComputeState(() => _subscriptionProduct = isAvailable
                  ? product.copyWith(PurchasableProductStatus.restored)
                  : product);
            },
          ),
        );
  }
}

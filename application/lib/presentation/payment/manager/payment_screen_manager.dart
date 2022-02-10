import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/check_subscription_active_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class PaymentScreenManager extends Cubit<PaymentScreenState>
    with UseCaseBlocHelper<PaymentScreenState> {
  final GetSubscriptionDetailsUseCase _getPurchasableProductUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final CheckSubscriptionActiveUseCase _checkSubscriptionActiveUseCase;
  late final UseCaseValueStream<PurchasableProduct>
      _getPurchasableProductHandler = consume(
    _getPurchasableProductUseCase,
    initialData: none,
  );
  late final UseCaseValueStream<bool> _checkSubscriptionActiveHandler = consume(
    _checkSubscriptionActiveUseCase,
    initialData: PurchasableIds.subscription,
  );
  late final UseCaseSink<PurchasableProductId, PurchasableProductStatus>
      _purchaseSubscriptionHandler = pipe(_purchaseSubscriptionUseCase);
  PurchasableProduct? _subscriptionProduct;

  PaymentScreenManager(
    this._getPurchasableProductUseCase,
    this._purchaseSubscriptionUseCase,
    this._checkSubscriptionActiveUseCase,
  ) : super(const PaymentScreenState.initial());

  void subscribe() {
    final product = _subscriptionProduct;

    if (product == null || !product.canBePurchased) return;

    _purchaseSubscriptionHandler(PurchasableIds.subscription);
  }

  @override
  FutureOr<PaymentScreenState?> computeState() async => fold3(
        _getPurchasableProductHandler,
        _purchaseSubscriptionHandler,
        _checkSubscriptionActiveHandler,
      ).foldAll((product, status, isAvailable, errorReport) {
        final errors = <Object>[];

        if (errorReport.isNotEmpty) {
          if (errorReport.exists(_getPurchasableProductHandler)) {
            errors.add(errorReport.of(_getPurchasableProductHandler)!.error);
            _logError(
              'getPurchasableProduct error',
              errorReport.of(_getPurchasableProductHandler)!.error,
            );
          }

          if (errorReport.exists(_purchaseSubscriptionHandler)) {
            errors.add(errorReport.of(_purchaseSubscriptionHandler)!.error);
            _logError(
              'purchaseSubscription error',
              errorReport.of(_purchaseSubscriptionHandler)!.error,
            );
          }

          if (errorReport.exists(_checkSubscriptionActiveHandler)) {
            errors.add(errorReport.of(_checkSubscriptionActiveHandler)!.error);
            _logError(
              'checkSubscriptionActive error',
              errorReport.of(_checkSubscriptionActiveHandler)!.error,
            );
          }
        }

        final subscriptionProduct = product?.copyWith(
          status ??
              (isAvailable == true
                  ? PurchasableProductStatus.restored
                  : product.status),
        );

        // todo subscriptionProduct could be null, and errors not, so we need to maybe make PaymentScreenState.product optional
        if (subscriptionProduct != null) {
          return PaymentScreenState.ready(
            product: subscriptionProduct,
            errorMsg: errors.isNotEmpty
                ? errors.map((e) => e.toString()).join('\r')
                : null,
          );
        }
      });

  void _logError(String prefix, Object error) => logger.e('$prefix: $error');
}

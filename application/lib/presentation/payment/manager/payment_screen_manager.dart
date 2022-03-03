import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/payment_flow_error_mapper_to_error_msg_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/request_code_redemption_sheet_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class PaymentScreenManager extends Cubit<PaymentScreenState>
    with UseCaseBlocHelper<PaymentScreenState> {
  final GetSubscriptionDetailsUseCase _getPurchasableProductUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final RequestCodeRedemptionSheetUseCase requestCodeRedemptionSheetUseCase;
  late final UseCaseValueStream<PurchasableProduct>
      _getPurchasableProductHandler = consume(
    _getPurchasableProductUseCase,
    initialData: none,
  );
  late final UseCaseValueStream<SubscriptionStatus>
      _checkSubscriptionActiveHandler = consume(
    _getSubscriptionStatusUseCase,
    initialData: PurchasableIds.subscription,
  );
  final PaymentFlowErrorToErrorMessageMapper _errorMessageMapper;
  late final UseCaseSink<PurchasableProductId, PurchasableProductStatus>
      _purchaseSubscriptionHandler = pipe(_purchaseSubscriptionUseCase);
  PurchasableProduct? _subscriptionProduct;

  PaymentScreenManager(
    this._getPurchasableProductUseCase,
    this._purchaseSubscriptionUseCase,
    this._getSubscriptionStatusUseCase,
    this.requestCodeRedemptionSheetUseCase,
    this._errorMessageMapper,
  ) : super(const PaymentScreenState.initial());

  void subscribe() {
    final product = _subscriptionProduct;

    if (product == null || !product.canBePurchased) return;
    _purchaseSubscriptionHandler(PurchasableIds.subscription);
  }

  void enterRedeemCode() {
    if (!Platform.isIOS) return;
    requestCodeRedemptionSheetUseCase.call(none);
  }

  @override
  FutureOr<PaymentScreenState?> computeState() async => fold3(
        _getPurchasableProductHandler,
        _purchaseSubscriptionHandler,
        _checkSubscriptionActiveHandler,
      ).foldAll((product, productStatus, subscriptionStatus, errorReport) {
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

        final paymentFlowError =
            errors.firstWhereOrNull((element) => element is PaymentFlowError)
                as PaymentFlowError?;
        final paymentFlowErrorMsg = paymentFlowError == null
            ? null
            : _errorMessageMapper.map(paymentFlowError);

        _subscriptionProduct = getUpdatedProduct(
          _subscriptionProduct ?? product,
          productStatus,
          subscriptionStatus?.isSubscriptionActive,
          paymentFlowError,
        );

        if (_subscriptionProduct == null && paymentFlowErrorMsg != null) {
          return PaymentScreenState.error(errorMsg: paymentFlowErrorMsg);
        } else if (_subscriptionProduct != null) {
          return PaymentScreenState.ready(
            product: _subscriptionProduct!,
            errorMsg: paymentFlowErrorMsg,
          );
        }
      });

  void _logError(String prefix, Object error) => logger.e('$prefix: $error');

  @visibleForTesting
  PurchasableProduct? getUpdatedProduct(
    PurchasableProduct? product,
    PurchasableProductStatus? status,
    bool? isAvailable,
    PaymentFlowError? paymentFlowError,
  ) {
    if (product == null) return null;
    late final PurchasableProductStatus updatedStatus;
    if (paymentFlowError != null) {
      updatedStatus = paymentFlowError.itemAlreadyOwned
          ? PurchasableProductStatus.purchased
          : PurchasableProductStatus.purchasable;
    } else if (isAvailable == true || status?.isPurchased == true) {
      updatedStatus = PurchasableProductStatus.purchased;
    } else {
      updatedStatus = status ?? product.status;
    }
    return product.copyWith(updatedStatus);
  }
}

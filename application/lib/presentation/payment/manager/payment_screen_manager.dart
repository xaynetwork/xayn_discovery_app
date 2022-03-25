import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchase_event_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_marketing_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/request_code_redemption_sheet_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/restore_subscription_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

enum PaymentAction {
  subscribe,
  restore,
}

abstract class PaymentScreenNavActions {
  void onDismiss();
}

@injectable
class PaymentScreenManager extends Cubit<PaymentScreenState>
    with UseCaseBlocHelper<PaymentScreenState>
    implements PaymentScreenNavActions {
  final GetSubscriptionDetailsUseCase _getPurchasableProductUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final RestoreSubscriptionUseCase _restoreSubscriptionUseCase;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final RequestCodeRedemptionSheetUseCase _requestCodeRedemptionSheetUseCase;
  final SendMarketingAnalyticsUseCase _sendMarketingAnalyticsUseCase;
  final PurchaseEventMapper _purchaseEventMapper;

  late final UseCaseValueStream<PurchasableProduct>
      _getPurchasableProductHandler = consume(
    _getPurchasableProductUseCase,
    initialData: none,
  );
  late final UseCaseValueStream<SubscriptionStatus>
      _listenSubscriptionStatusHandler = consume(
    _listenSubscriptionStatusUseCase,
    initialData: PurchasableIds.subscription,
  );
  late final UseCaseSink<PurchasableProductId, PurchasableProductStatus>
      _purchaseSubscriptionHandler = pipe(_purchaseSubscriptionUseCase);
  late final UseCaseSink<None, PurchasableProductStatus>
      _restoreSubscriptionHandler = pipe(_restoreSubscriptionUseCase);
  PurchasableProduct? _subscriptionProduct;

  final PaymentScreenNavActions _paymentScreenNavActions;

  PaymentScreenManager(
    this._paymentScreenNavActions,
    this._getPurchasableProductUseCase,
    this._purchaseSubscriptionUseCase,
    this._restoreSubscriptionUseCase,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._requestCodeRedemptionSheetUseCase,
    this._sendMarketingAnalyticsUseCase,
    this._purchaseEventMapper,
  ) : super(const PaymentScreenState.initial()) {
    _init();
  }

  SubscriptionStatus? _subscriptionStatus;
  PaymentAction? _paymentAction;

  void _init() {
    scheduleComputeState(() async {
      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);
    });
  }

  void subscribe() {
    final product = _subscriptionProduct;

    if (product == null || !product.canBePurchased) return;
    _paymentAction = PaymentAction.subscribe;
    _purchaseSubscriptionHandler(PurchasableIds.subscription);
  }

  void enterRedeemCode() => _requestCodeRedemptionSheetUseCase.call(none);

  void restore() {
    _paymentAction = PaymentAction.restore;
    _restoreSubscriptionHandler(none);
  }

  @override
  FutureOr<PaymentScreenState?> computeState() async => fold4(
        _getPurchasableProductHandler,
        _purchaseSubscriptionHandler,
        _restoreSubscriptionHandler,
        _listenSubscriptionStatusHandler,
      ).foldAll((product, productStatus, restoreStatus, subscriptionStatus,
          errorReport) {
        final errors = <Object>[];

        if (errorReport.isNotEmpty) {
          if (errorReport.exists(_getPurchasableProductHandler)) {
            errors.add(errorReport.of(_getPurchasableProductHandler)!.error);
            _logError(
              'getPurchasableProduct error',
              errorReport.of(_getPurchasableProductHandler)!.error,
            );
          }

          if (errorReport.exists(_purchaseSubscriptionHandler) &&
              _paymentAction == PaymentAction.subscribe) {
            errors.add(errorReport.of(_purchaseSubscriptionHandler)!.error);
            _logError(
              'purchaseSubscription error',
              errorReport.of(_purchaseSubscriptionHandler)!.error,
            );
          }

          if (errorReport.exists(_restoreSubscriptionHandler) &&
              _paymentAction == PaymentAction.restore) {
            errors.add(errorReport.of(_restoreSubscriptionHandler)!.error);
            _logError(
              'restoreSubscription error',
              errorReport.of(_restoreSubscriptionHandler)!.error,
            );
          }

          if (errorReport.exists(_listenSubscriptionStatusHandler)) {
            errors.add(errorReport.of(_listenSubscriptionStatusHandler)!.error);
            _logError(
              'listenSubscriptionStatus error',
              errorReport.of(_listenSubscriptionStatusHandler)!.error,
            );
          }
        }

        if (subscriptionStatus != null) {
          _subscriptionStatus = subscriptionStatus;
        }

        final paymentFlowError =
            errors.firstWhereOrNull((element) => element is PaymentFlowError)
                as PaymentFlowError?;
        _subscriptionProduct = getUpdatedProduct(
          _subscriptionProduct ?? product,
          _paymentAction == PaymentAction.subscribe
              ? productStatus
              : restoreStatus,
          _subscriptionStatus?.isSubscriptionActive,
          paymentFlowError,
        );

        sendPurchaseEventIfNeeded(_subscriptionProduct);

        if (_subscriptionProduct == null && paymentFlowError != null) {
          return PaymentScreenState.error(error: paymentFlowError);
        } else if (_subscriptionProduct != null) {
          return PaymentScreenState.ready(
            product: _subscriptionProduct!,
            error: paymentFlowError,
          );
        }
      });

  void _logError(String prefix, Object error) => logger.e('$prefix: $error');

  @visibleForTesting
  void sendPurchaseEventIfNeeded(PurchasableProduct? product) {
    if (product?.status.isPurchased == true) {
      final event = _purchaseEventMapper.map(product!);
      _sendMarketingAnalyticsUseCase.call(event);
    }
  }

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

  @override
  void onDismiss() => _paymentScreenNavActions.onDismiss();
}

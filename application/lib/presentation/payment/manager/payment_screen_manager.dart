import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:platform/platform.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchase_event_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/subscription_action_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_marketing_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_details_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/purchase_subscription_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/request_code_redemption_sheet_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/restore_subscription_use_case.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';
import 'package:xayn_discovery_app/presentation/payment/redeem_promo_code_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/error_code_extensions.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

enum PaymentAction {
  subscribe,
  restore,
}

abstract class PaymentScreenNavActions {
  void onGoBackToFeed();
}

const _ignoredPaymentErrors = [PaymentFlowError.canceled];

@injectable
class PaywallScreenManager extends PaymentScreenManager
    with RedeemPromoCodeMixin<PaymentScreenState> {
  PaywallScreenManager(
    super.getPurchasableProductUseCase,
    super.purchaseSubscriptionUseCase,
    super.restoreSubscriptionUseCase,
    super.getSubscriptionStatusUseCase,
    super.listenSubscriptionStatusUseCase,
    super.requestCodeRedemptionSheetUseCase,
    super.sendMarketingAnalyticsUseCase,
    super.sendAnalyticsUseCase,
    super.purchaseEventMapper,
    super.featureManager,
    super.platform,
    this._paymentScreenNavActions,
  );

  final PaymentScreenNavActions _paymentScreenNavActions;

  @override
  void _onDismiss() => _paymentScreenNavActions.onGoBackToFeed();

  @override
  void enterRedeemCode() {
    if (_featureManager.isAlternativePromoCodeEnabled) {
      _sendAnalyticsUseCase(
        SubscriptionActionEvent(
          action: SubscriptionAction.promoCode,
        ),
      );

      redeemAlternativeCodeFlow();
    } else {
      super.enterRedeemCode();
    }
  }
}

@injectable
class BottomSheetPaymentScreenManager extends PaymentScreenManager {
  BottomSheetPaymentScreenManager(
    super.getPurchasableProductUseCase,
    super.purchaseSubscriptionUseCase,
    super.restoreSubscriptionUseCase,
    super.getSubscriptionStatusUseCase,
    super.listenSubscriptionStatusUseCase,
    super.requestCodeRedemptionSheetUseCase,
    super.sendMarketingAnalyticsUseCase,
    super.sendAnalyticsUseCase,
    super.purchaseEventMapper,
    super.featureManager,
    super.platform,
  );

  /// This is a speciol case where the manager receives a dismiss callback from the UI
  /// in order to have full control over the screen
  late VoidCallback dismissBottomSheet;
  bool _dismissed = false;

  @override
  void _onDismiss() {
    if (!_dismissed) dismissBottomSheet();
    _dismissed = true;
  }

  @override
  void enterRedeemCode() {
    if (_featureManager.isAlternativePromoCodeEnabled) {
      // this can not happen, because enter enterRedeemCode is not called in the alternative flow
    } else {
      super.enterRedeemCode();
    }
  }
}

abstract class PaymentScreenManager extends Cubit<PaymentScreenState>
    with
        UseCaseBlocHelper<PaymentScreenState>,
        OverlayManagerMixin<PaymentScreenState>,
        ErrorHandlingManagerMixin<PaymentScreenState> {
  final GetSubscriptionDetailsUseCase _getPurchasableProductUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final RestoreSubscriptionUseCase _restoreSubscriptionUseCase;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final RequestCodeRedemptionSheetUseCase _requestCodeRedemptionSheetUseCase;
  final SendMarketingAnalyticsUseCase _sendMarketingAnalyticsUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  final PurchaseEventMapper _purchaseEventMapper;
  final FeatureManager _featureManager;
  final Platform _platform;

  late final UseCaseValueStream<PurchasableProduct>
      _getPurchasableProductHandler = consume(
    _getPurchasableProductUseCase,
    initialData: none,
  );
  late final UseCaseValueStream<SubscriptionStatus>
      _listenSubscriptionStatusHandler = consume(
    _listenSubscriptionStatusUseCase,
    initialData: none,
  );
  late final UseCaseSink<PurchasableProductId, PurchasableProductStatus>
      _purchaseSubscriptionHandler = pipe(_purchaseSubscriptionUseCase);
  late final UseCaseSink<None, PurchasableProductStatus>
      _restoreSubscriptionHandler = pipe(_restoreSubscriptionUseCase);
  PurchasableProduct? _subscriptionProduct;

  PaymentScreenManager(
    this._getPurchasableProductUseCase,
    this._purchaseSubscriptionUseCase,
    this._restoreSubscriptionUseCase,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._requestCodeRedemptionSheetUseCase,
    this._sendMarketingAnalyticsUseCase,
    this._sendAnalyticsUseCase,
    this._purchaseEventMapper,
    this._featureManager,
    this._platform,
  ) : super(const PaymentScreenState.initial()) {
    _init();
  }

  SubscriptionStatus? _subscriptionStatus;
  PaymentAction? _paymentAction;

  void _init() {
    scheduleComputeState(() async {
      _subscriptionStatus =
          await _getSubscriptionStatusUseCase.singleOutput(none);
    });
  }

  void subscribe() {
    _sendAnalyticsUseCase(
      SubscriptionActionEvent(
        action: SubscriptionAction.subscribeNow,
      ),
    );

    final product = _subscriptionProduct;

    if (product == null || !product.canBePurchased) return;
    _paymentAction = PaymentAction.subscribe;
    _purchaseSubscriptionHandler(product.id);
  }

  void restore() {
    _sendAnalyticsUseCase(
      SubscriptionActionEvent(
        action: SubscriptionAction.restore,
      ),
    );

    _paymentAction = PaymentAction.restore;
    _restoreSubscriptionHandler(none);
  }

  void cancel() {
    _sendAnalyticsUseCase(
      SubscriptionActionEvent(
        action: SubscriptionAction.cancel,
      ),
    );
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
          if (_subscriptionStatus?.isFreeTrialActive == false &&
              subscriptionStatus.isFreeTrialActive) {
            _onDismiss();
            return state;
          }
          _subscriptionStatus = subscriptionStatus;
        }

        final paymentFlowError = errors.firstWhereOrNull(
          (it) => it is PaymentFlowError && !_ignoredPaymentErrors.contains(it),
        ) as PaymentFlowError?;

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
          openErrorScreen();
          return state;
        } else if (_subscriptionProduct != null) {
          _maybeHandleError(paymentFlowError);
          final purchasableProduct = _subscriptionProduct!;
          if (purchasableProduct.status.isPurchased ||
              purchasableProduct.status.isRestored) {
            _onDismiss();
          }

          return PaymentScreenState.ready(
            product: _subscriptionProduct!,
          );
        }
      });

  void _logError(String prefix, Object error) => logger.e('$prefix: $error');

  void _maybeHandleError(PaymentFlowError? error) {
    if (error == null) return;
    if (error == PaymentFlowError.itemAlreadyOwned) {
      _onDismiss();
      return;
    }

    late BottomSheetData data;
    if (error == PaymentFlowError.paymentFailed) {
      data = OverlayData.bottomSheetPaymentFailedError();
    } else if (error == PaymentFlowError.noActiveSubscriptionFound) {
      data = OverlayData.bottomSheetNoActiveSubscriptionFoundError();
    } else {
      data = OverlayData.bottomSheetGenericError(
        allowStacking: true,
        errorCode: error.errorCode,
      );
    }

    showOverlay(data);
  }

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

  /// Returns true when the calling experience (i.e. the bottom sheet) should be closed
  void enterRedeemCode() {
    _sendAnalyticsUseCase(
      SubscriptionActionEvent(
        action: SubscriptionAction.promoCode,
      ),
    );

    if (!_platform.isIOS) return;
    _requestCodeRedemptionSheetUseCase.call(none);
  }

  /// leaving the experience
  void _onDismiss();
}

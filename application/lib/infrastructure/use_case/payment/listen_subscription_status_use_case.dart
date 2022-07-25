import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/extensions/customer_info_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class ListenSubscriptionStatusUseCase
    extends UseCase<None, SubscriptionStatus> {
  final PaymentService _paymentService;
  final AppStatusRepository _repository;

  ListenSubscriptionStatusUseCase(
    this._paymentService,
    this._repository,
  );

  CustomerInfo? customerInfo;

  @override
  Stream<SubscriptionStatus> transaction(None param) {
    return MergeStream(
            [_paymentService.customerInfoStream, _repository.watch()])
        .map((object) {
      if (object is CustomerInfo) {
        customerInfo = object;
      }

      final willRenew = customerInfo?.willRenew ?? false;
      final expirationDate = customerInfo?.expirationDate;
      final purchaseDate = customerInfo?.purchaseDate;

      return SubscriptionStatus(
        willRenew: willRenew,
        expirationDate: expirationDate,
        trialEndDate: _repository.appStatus.trialEndDate,
        purchaseDate: purchaseDate,
        isBetaUser: _repository.appStatus.isBetaUser,
      );
    });
  }
}

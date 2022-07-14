import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/extensions/customer_info_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class GetSubscriptionStatusUseCase extends UseCase<None, SubscriptionStatus> {
  final PaymentService _paymentService;
  final AppStatusRepository _repository;

  GetSubscriptionStatusUseCase(
    this._paymentService,
    this._repository,
  );

  /// yield [SubscriptionStatus]
  @override
  Stream<SubscriptionStatus> transaction(None param) async* {
    final customerInfo = await _paymentService.getCustomerInfo();
    final willRenew = customerInfo.willRenew;
    final expirationDate = customerInfo.expirationDate;
    final purchaseDate = customerInfo.purchaseDate;
    yield SubscriptionStatus(
      willRenew: willRenew,
      expirationDate: expirationDate,
      trialEndDate: _repository.appStatus.trialEndDate,
      purchaseDate: purchaseDate,
      isBetaUser: _repository.appStatus.isBetaUser,
    );
  }
}

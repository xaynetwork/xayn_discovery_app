import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/extensions/purchaser_info_extension.dart';
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
    final purchaserInfo = await _paymentService.getPurchaserInfo();
    final willRenew = purchaserInfo.willRenew;
    final expirationDate = purchaserInfo.expirationDate;
    final purchaseDate = purchaserInfo.purchaseDate;
    yield SubscriptionStatus(
      willRenew: willRenew,
      expirationDate: expirationDate,
      trialEndDate: _repository.appStatus.trialEndDate,
      purchaseDate: purchaseDate,
      isBetaUser: _repository.appStatus.isBetaUser,
    );
  }
}

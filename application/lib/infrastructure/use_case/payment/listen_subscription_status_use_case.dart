import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/extensions/purchaser_info_extension.dart';
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

  @override
  Stream<SubscriptionStatus> transaction(None param) {
    return _paymentService.purchaserInfoStream.map((purchaserInfo) {
      final willRenew = purchaserInfo.willRenew;
      final expirationDate = purchaserInfo.expirationDate;
      final purchaseDate = purchaserInfo.purchaseDate;
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

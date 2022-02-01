import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class RestorePurchasedSubscriptionUseCase extends UseCase<None, None> {
  final PaymentService _paymentService;

  RestorePurchasedSubscriptionUseCase(this._paymentService);

  @override
  Stream<None> transaction(None param) async* {
    final isAvailable = await _paymentService.isAvailable();
    if (!isAvailable) {
      throw PaymentFlowError.storeNotAvailable;
    }

    await _paymentService.restorePurchases();
    yield none;
  }
}

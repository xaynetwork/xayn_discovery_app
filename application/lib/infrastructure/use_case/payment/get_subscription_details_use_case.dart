import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchasable_product_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class GetSubscriptionDetailsUseCase extends UseCase<None, PurchasableProduct> {
  final PaymentService _paymentService;
  final PurchasableProductMapper _mapper;

  GetSubscriptionDetailsUseCase(
    this._paymentService,
    this._mapper,
  );

  @override
  Stream<PurchasableProduct> transaction(None param) async* {
    final packages = await _paymentService.getPackages();

    if (packages.isEmpty) {
      throw PaymentFlowError.productNotFound;
    }
    yield _mapper.map(packages.first);
  }
}

import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/models/product_wrapper.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchasable_product_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';

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
    const id = PurchasableIds.subscription;
    final List<Product> products = await _paymentService.getProducts([id]);

    if (products.isEmpty) {
      throw PaymentFlowError.productNotFound;
    }
    yield _mapper.map(products.first);
  }
}

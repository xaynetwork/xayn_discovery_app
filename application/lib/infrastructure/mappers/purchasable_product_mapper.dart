import 'package:in_app_purchase/in_app_purchase.dart' hide PurchaseStatus;
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@lazySingleton
class PurchasableProductMapper
    implements Mapper<ProductDetails, PurchasableProduct> {
  @override
  PurchasableProduct map(ProductDetails input) => PurchasableProduct(
        id: input.id,
        title: input.title,
        description: input.description,
        price: input.price,
        status: PurchasableProductStatus.purchasable,
      );
}

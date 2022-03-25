import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/models/product_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@lazySingleton
class PurchasableProductMapper implements Mapper<Product, PurchasableProduct> {
  @override
  PurchasableProduct map(Product input) => PurchasableProduct(
        id: input.identifier,
        title: input.title,
        description: input.description,
        price: input.priceString,
        currency: input.currencyCode,
        status: PurchasableProductStatus.purchasable,
      );
}

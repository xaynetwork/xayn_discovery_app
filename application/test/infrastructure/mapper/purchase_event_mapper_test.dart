import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchase_event_mapper.dart';

void main() {
  final mapper = PurchaseEventMapper();

  const id = 'id1';
  const price = '123';
  const currency = 'usd';
  const product = PurchasableProduct(
    id: id,
    title: '',
    description: '',
    price: price,
    currency: currency,
    status: PurchasableProductStatus.purchased,
  );

  test(
    'GIVEN a product WHEN map is called THEN verify properties and type match',
    () {
      final result = mapper.map(product);
      expect(result.properties['af_content_id'], equals(id));
      expect(result.properties['af_price'], equals(price));
      expect(result.properties['af_currency'], equals(currency));
      expect(result.type, equals('af_purchase'));
    },
  );
}

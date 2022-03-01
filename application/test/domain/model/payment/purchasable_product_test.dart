import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';

void main() {
  const id = 'productID';
  const title = 'productTitle';
  const description = 'productDescription';
  const price = 'productPrice';
  const statusDefault = PurchasableProductStatus.purchasable;
  const product = PurchasableProduct(
    id: id,
    title: title,
    description: description,
    price: price,
    status: statusDefault,
  );

  test(
    'Verify constructor works correctly',
    () {
      expect(product.id, equals(id));
      expect(product.title, equals(title));
      expect(product.description, equals(description));
      expect(product.price, equals(price));
      expect(product.status, equals(statusDefault));
    },
  );

  test(
    'Verify product is Equatable',
    () {
      expect(product, isA<Equatable>());
      expect(product.props, [
        id,
        title,
        description,
        price,
        statusDefault,
      ]);
    },
  );
  test(
    'Verify copy with works correctly',
    () {
      for (var newStatus in PurchasableProductStatus.values) {
        final copied = product.copyWith(newStatus);

        expect(product.id, equals(id));
        expect(product.title, equals(title));
        expect(product.description, equals(description));
        expect(product.price, equals(price));
        expect(copied.status, equals(newStatus));
      }
    },
  );
  test(
    'WHEN status is purchasable or canceled THEN canBePurchased == true',
    () {
      final canBePurchasedStatuses = [
        PurchasableProductStatus.canceled,
        PurchasableProductStatus.purchasable,
      ];
      for (var newStatus in PurchasableProductStatus.values) {
        final expected = canBePurchasedStatuses.contains(newStatus);
        final copied = product.copyWith(newStatus);

        expect(copied.canBePurchased, equals(expected));
      }
    },
  );

  test(
    'GIVEN PurchasableProductStatus WHEN isPurchased called THEN return true, only when status purchased',
    () async {
      final results = PurchasableProductStatus.values.map((e) => e.isPurchased);
      final expectedResults = [
        false,
        true,
        false,
        false,
        false,
      ];

      expect(results, equals(expectedResults));
    },
  );
}

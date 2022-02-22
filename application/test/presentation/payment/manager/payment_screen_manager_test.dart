import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';

import '../../test_utils/utils.dart';

void main() {
  late PaymentScreenManager manager;
  late MockGetSubscriptionDetailsUseCase getSubscriptionDetailsUseCase;
  late MockPurchaseSubscriptionUseCase purchaseSubscriptionUseCase;
  late MockCheckSubscriptionActiveUseCase checkSubscriptionActiveUseCase;
  late MockPaymentFlowErrorToErrorMessageMapper errorMessageMapper;
  setUp(() {
    getSubscriptionDetailsUseCase = MockGetSubscriptionDetailsUseCase();
    purchaseSubscriptionUseCase = MockPurchaseSubscriptionUseCase();
    checkSubscriptionActiveUseCase = MockCheckSubscriptionActiveUseCase();
    errorMessageMapper = MockPaymentFlowErrorToErrorMessageMapper();
    manager = PaymentScreenManager(
      getSubscriptionDetailsUseCase,
      purchaseSubscriptionUseCase,
      checkSubscriptionActiveUseCase,
      errorMessageMapper,
    );
  });

  group('getUpdatedProduct method', () {
    PurchasableProduct getProduct({
      PurchasableProductStatus? status,
    }) =>
        PurchasableProduct(
          id: 'id',
          title: 'title',
          description: 'description',
          price: 'price',
          status: status ?? PurchasableProductStatus.purchasable,
        );
    final purchasedProduct =
        getProduct().copyWith(PurchasableProductStatus.purchased);
    test(
      'GIVEN nullable product THEN return null',
      () {
        const PurchasableProduct? product = null;
        final result = manager.getUpdatedProduct(product, null, null, null);
        expect(result, isNull);
      },
    );
    test(
      'GIVEN paymentFlowError.itemAlreadyOwned THEN return product with status purchased',
      () {
        final product = getProduct();
        const error = PaymentFlowError.itemAlreadyOwned;
        final result = manager.getUpdatedProduct(product, null, null, error);

        expect(result, equals(purchasedProduct));
      },
    );
    test(
      'GIVEN any other then paymentFlowError.itemAlreadyOwned THEN return product with status purchasable',
      () {
        final product = getProduct();
        final expected = product.copyWith(PurchasableProductStatus.purchasable);

        final results = PaymentFlowError.values
            .where((element) => !element.itemAlreadyOwned)
            .map((e) => manager.getUpdatedProduct(product, null, null, e));

        for (final resultProduct in results) {
          expect(resultProduct, equals(expected));
        }
      },
    );
    test(
      'GIVEN isAvailable = true THEN return product with status purchased',
      () {
        final product = getProduct();
        const isAvailable = true;
        final results = manager.getUpdatedProduct(
          product,
          null,
          isAvailable,
          null,
        );
        expect(results, equals(purchasedProduct));
      },
    );
    test(
      'GIVEN status.isPurchased = true THEN return product with status purchased',
      () {
        final product = getProduct();
        const status = PurchasableProductStatus.purchased;
        final results = manager.getUpdatedProduct(product, status, null, null);
        expect(results, equals(purchasedProduct));
      },
    );
    test(
      'GIVEN any non nullable status THEN return product with that status',
      () {
        final product = getProduct();
        final expectedResults =
            PurchasableProductStatus.values.map((e) => getProduct(status: e));
        final results = PurchasableProductStatus.values.map(
            (status) => manager.getUpdatedProduct(product, status, null, null));

        expect(results, equals(expectedResults));
      },
    );
    test(
      'GIVEN status is null THEN return product with the status from product',
      () {
        final product = getProduct(status: PurchasableProductStatus.pending);
        const PurchasableProductStatus? status = null;
        final result = manager.getUpdatedProduct(product, status, null, null);

        expect(result, equals(product));
      },
    );
  });
}

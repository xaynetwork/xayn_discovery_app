import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';

typedef Extractor<T> = Object? Function(T object);

hasProductTitle(matcher) => HasFeature<PurchasableProduct>(
    matcher, 'PurchasableProduct', 'title', (object) => object.title);

hasProductStatus(matcher) => HasFeature<PurchasableProduct>(
    matcher, 'PurchasableProduct', 'status', (object) => object.status);

withPurchasableProduct(matcher) => WithPurchasableProduct(matcher);

class HasFeature<T> extends CustomMatcher {
  final Extractor<T> extractor;

  HasFeature(
    matcher,
    String object,
    String feature,
    this.extractor,
  ) : super("$object with $feature that is", feature, matcher);

  @override
  featureValueOf(actual) => extractor(actual);
}

/// a matcher that tries to grab a purchasable product
class WithPurchasableProduct extends CustomMatcher {
  WithPurchasableProduct(matcher)
      : super(
            "with purchasable product that is", "purchasable product", matcher);

  @override
  featureValueOf(actual) => actual is PaymentScreenStateReady
      ? actual.product
      : (actual as PurchasableProduct);
}

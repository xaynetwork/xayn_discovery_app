import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_events/purchase_event.dart';

@lazySingleton
class PurchaseEventMapper
    implements Mapper<PurchasableProduct, PurchaseMarketingEvent> {
  @override
  PurchaseMarketingEvent map(PurchasableProduct input) =>
      PurchaseMarketingEvent(
        productIdentifier: input.id,
        price: input.price,
        currency: input.currency,
      );
}

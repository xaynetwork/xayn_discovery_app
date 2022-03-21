import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/purchase_event.dart';

@lazySingleton
class PurchaseEventMapper implements Mapper<PurchasableProduct, PurchaseEvent> {
  @override
  PurchaseEvent map(PurchasableProduct input) => PurchaseEvent(
        input.id,
        input.price,
        input.currency,
      );
}

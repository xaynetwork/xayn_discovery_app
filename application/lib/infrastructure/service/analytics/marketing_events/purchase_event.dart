import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'af_purchase';
const String _kParamPrice = 'af_price';
const String _kParamCurrency = 'af_currency';
const String _kParamContentId = 'af_content_id';

class PurchaseMarketingEvent extends AnalyticsEvent {
  PurchaseMarketingEvent({
    required String productIdentifier,
    required String price,
    required String currency,
  }) : super(_kEventType, properties: {
          _kParamContentId: productIdentifier,
          _kParamPrice: price,
          _kParamCurrency: currency,
        });
}

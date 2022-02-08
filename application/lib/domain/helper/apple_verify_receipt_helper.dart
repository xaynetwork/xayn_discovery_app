import 'package:xayn_discovery_app/domain/model/apple_verify_receipt_credentials.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';

abstract class AppleVerifyReceiptHelper {
  /// Can throw [PaymentFlowError]
  Future<DateTime?> getSubscriptionExpireDate({
    required String serverVerificationData,
    required AppleVerifyReceiptCredentials credentials,
  });
}

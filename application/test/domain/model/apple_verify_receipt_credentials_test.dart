import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/apple_verify_receipt_credentials.dart';

void main() {
  final defaultUrl = Uri.parse('https://xayn.com');
  const defaultPass = 'passWord';
  AppleVerifyReceiptCredentials create({Uri? url, String? password}) =>
      AppleVerifyReceiptCredentials(
        url ?? defaultUrl,
        password ?? defaultPass,
      );
  test(
    'GIVEN credentials THEN verify it extends equatable',
    () {
      final credentials = create();

      expect(credentials, isA<Equatable>());
      expect(credentials.props, [defaultUrl, defaultPass]);
    },
  );
  test(
    'GIVEN custom input params THEN verify params are correct',
    () {
      final customUrl = Uri.parse('https://custom.com');
      const customPass = 'customPass';
      final credentials = create(url: customUrl, password: customPass);

      expect(credentials.password, customPass);
      expect(credentials.url, customUrl);
    },
  );
}

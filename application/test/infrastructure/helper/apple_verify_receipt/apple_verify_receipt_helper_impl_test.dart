import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/apple_verify_receipt_credentials.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/helper/apple_verify_receipt/apple_verify_receipt_helper_impl.dart';

import '../../../presentation/test_utils/utils.dart';

void main() {
  late MockClient client;
  late AppleVerifyReceiptHelperImpl helper;

  const verificationData = 'verificationData';
  const defaultPass = 'defaultPass';
  late final defaultUrl = Uri.parse('https://xayn.com');
  late final defaultCredentials = AppleVerifyReceiptCredentials(
    defaultUrl,
    defaultPass,
  );
  late final responseEmpty = Response(latestReceiptInfo: []);
  const expireDateInMs = 1644253582310;
  late final responseCorrect = Response(
    latestReceiptInfo: [
      ReceiptInfo(expiresDate: expireDateInMs.toString()),
    ],
  );
  const responseWrong = '';
  late final responseWrongExpireDate = Response(
    latestReceiptInfo: [
      ReceiptInfo(expiresDate: 'expireDateInMs.toString()'),
    ],
  );

  setUp(() {
    client = MockClient();
    helper = AppleVerifyReceiptHelperImpl(client);

    when(client.post(defaultUrl, body: anyNamed('body'))).thenAnswer(
      (_) async => http.Response(responseEmpty.asJsonString, 200),
    );
  });

  test(
    'GIVEN credentials WHEN getting subscription expire date THEN verify call client correctly',
    () async {
      await helper.getSubscriptionExpireDate(
        serverVerificationData: verificationData,
        credentials: defaultCredentials,
      );
      final body = InputBody(verificationData, defaultPass);

      verify(client.post(defaultUrl, body: body.asJsonString));
    },
  );

  test(
    'GIVEN correct response WHEN getting subscription expire date THEN return parsed expired date',
    () async {
      when(client.post(defaultUrl, body: anyNamed('body'))).thenAnswer(
        (_) async => http.Response(responseCorrect.asJsonString, 200),
      );
      final expireDate = await helper.getSubscriptionExpireDate(
        serverVerificationData: verificationData,
        credentials: defaultCredentials,
      );

      expect(
        expireDate,
        equals(DateTime.fromMillisecondsSinceEpoch(expireDateInMs)),
      );
    },
  );

  test(
    'GIVEN wrong response WHEN getting subscription expire date THEN throw PaymentFlowError.checkSubscriptionActiveFailed',
    () async {
      when(client.post(defaultUrl, body: anyNamed('body'))).thenAnswer(
        (_) async => http.Response(responseWrong, 200),
      );

      DateTime? expireDate;
      try {
        expireDate = await helper.getSubscriptionExpireDate(
          serverVerificationData: verificationData,
          credentials: defaultCredentials,
        );
      } catch (e, __) {
        expect(expireDate, isNull);
        expect(e, equals(PaymentFlowError.checkSubscriptionActiveFailed));
      }
    },
  );

  test(
    'GIVEN response with wrong expire date WHEN getting subscription expire date THEN throw PaymentFlowError.checkSubscriptionActiveFailed',
    () async {
      when(client.post(defaultUrl, body: anyNamed('body'))).thenAnswer(
        (_) async => http.Response(responseWrongExpireDate.asJsonString, 200),
      );

      DateTime? expireDate;
      try {
        expireDate = await helper.getSubscriptionExpireDate(
          serverVerificationData: verificationData,
          credentials: defaultCredentials,
        );
      } catch (e, __) {
        expect(expireDate, isNull);
        expect(e, equals(PaymentFlowError.checkSubscriptionActiveFailed));
      }
    },
  );

  test(
    'GIVEN response with empty info list WHEN getting subscription expire date THEN return null',
    () async {
      when(client.post(defaultUrl, body: anyNamed('body'))).thenAnswer(
        (_) async => http.Response(responseEmpty.asJsonString, 200),
      );

      final expireDate = await helper.getSubscriptionExpireDate(
        serverVerificationData: verificationData,
        credentials: defaultCredentials,
      );
      expect(expireDate, isNull);
    },
  );
}

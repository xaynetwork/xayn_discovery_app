import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/helper/apple_verify_receipt_helper.dart';
import 'package:http/http.dart' as http;
import 'package:xayn_discovery_app/domain/model/apple_verify_receipt_credentials.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

part 'apple_verify_receipt_helper_impl.g.dart';

@LazySingleton(as: AppleVerifyReceiptHelper)
class AppleVerifyReceiptHelperImpl implements AppleVerifyReceiptHelper {
  final http.Client _client;

  AppleVerifyReceiptHelperImpl(this._client);

  @override
  Future<DateTime?> getSubscriptionExpireDate({
    required String serverVerificationData,
    required AppleVerifyReceiptCredentials credentials,
  }) async {
    final inputBody = InputBody(
      serverVerificationData,
      credentials.password,
    );
    final clientResponse = await _client.post(
      credentials.url,
      body: inputBody.asJsonString,
    );
    try {
      final response = Response.fromJson(clientResponse.body);
      if (response.latestReceiptInfo.isEmpty) {
        return null;
      }
      final info = response.latestReceiptInfo.first;
      final dateInMs = int.parse(info.expiresDate);
      return DateTime.fromMillisecondsSinceEpoch(dateInMs);
    } catch (e, trace) {
      logger.e('Failed to getSubscriptionExpireDate', e, trace);
      throw PaymentFlowError.checkSubscriptionActiveFailed;
    }
  }
}

@JsonSerializable()
class Response {
  @JsonKey(name: 'latest_receipt_info')
  final List<ReceiptInfo> latestReceiptInfo;

  Response({
    required this.latestReceiptInfo,
  });

  factory Response.fromJson(String jsonString) =>
      _$ResponseFromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => _$ResponseToJson(this);

  String get asJsonString => json.encode(toJson());
}

@JsonSerializable()
class ReceiptInfo {
  @JsonKey(name: 'expires_date_ms')
  final String expiresDate;

  ReceiptInfo({
    required this.expiresDate,
  });

  factory ReceiptInfo.fromJson(Map<String, dynamic> json) =>
      _$ReceiptInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptInfoToJson(this);

  String get asJsonString => json.encode(toJson());
}

@JsonSerializable()
class InputBody {
  @JsonKey(name: 'receipt-data')
  final String receiptData;
  @JsonKey(name: 'exclude-old-transactions')
  final bool excludeOldTransactions = true;
  final String password;

  @visibleForTesting
  InputBody(
    this.receiptData,
    this.password,
  );

  Map<String, dynamic> toJson() => _$InputBodyToJson(this);

  String get asJsonString => json.encode(toJson());
}

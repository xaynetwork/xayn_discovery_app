import 'package:equatable/equatable.dart';

/// [url] - request destination, where check will happen.
/// [password] - string, that is required for the request
class AppleVerifyReceiptCredentials extends Equatable {
  final Uri url;
  final String password;

  const AppleVerifyReceiptCredentials(
    this.url,
    this.password,
  );

  @override
  List<Object> get props => [
        url,
        password,
      ];
}

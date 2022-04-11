import 'package:equatable/equatable.dart';

abstract class IdentityParam extends Equatable {
  final String key;
  final dynamic value;

  const IdentityParam(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

abstract class IdentityKeys {
  IdentityKeys._();

  static const String lastSeenDate = 'lastSeenDate';
  static const String numberOfCollections = 'numberOfCollections';
  static const String numberOfBookmarks = 'numberOfBookmarks';
  static const String numberOfTotalSession = 'numberOfTotalSession';
  static const String numberOfActiveSelectedCountries =
      'numberOfActiveSelectedCountries';
  static const String subscriptionType = 'subscriptionType';
}

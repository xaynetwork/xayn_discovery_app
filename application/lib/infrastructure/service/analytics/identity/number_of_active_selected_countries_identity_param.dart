import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

class NumberOfActiveSelectedCountriesIdentityParam extends IdentityParam {
  const NumberOfActiveSelectedCountriesIdentityParam(int numberOfSelectedCountries)
      : super(
          IdentityKeys.numberOfActiveSelectedCountries,
          numberOfSelectedCountries,
        );
}

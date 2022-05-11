import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

extension PackageTypeExtension on PackageType {
  String? get localizedString {
    switch (this) {
      case PackageType.monthly:
        return R.strings.subscriptionDurationMonth;
      case PackageType.unknown:
      case PackageType.custom:
      case PackageType.lifetime:
      case PackageType.annual:
      case PackageType.sixMonth:
      case PackageType.threeMonth:
      case PackageType.twoMonth:
      case PackageType.weekly:
        return null; // We don't support packages with types other than monthly yet.
    }
  }
}

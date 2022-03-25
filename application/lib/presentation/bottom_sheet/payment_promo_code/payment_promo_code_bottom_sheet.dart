import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_informational_body.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// An instructional bottom sheet that is triggered only for Android users
///
class PaymentPromoCodeBottomSheet extends BottomSheetBase {
  PaymentPromoCodeBottomSheet({
    Key? key,
  }) : super(
          key: key,
          body: BottomSheetInformationalBody(
            title: R.strings.paymentPromoCodeAndroidBottomSheetTitle,
            body: R.strings.paymentPromoCodeAndroidBottomSheetBody,
          ),
        );
}

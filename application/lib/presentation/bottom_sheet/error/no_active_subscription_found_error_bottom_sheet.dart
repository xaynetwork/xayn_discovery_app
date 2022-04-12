import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_informational_body.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class NoActiveSubscriptionFoundErrorBottomSheet extends BottomSheetBase {
  NoActiveSubscriptionFoundErrorBottomSheet({
    Key? key,
  }) : super(
          key: key,
          body: BottomSheetInformationalBody(
            title: R.strings.errorGenericHeaderSomethingWentWrong,
            body: R.strings.paymentFlowError.noActiveSubscriptionFound,
          ),
        );
}

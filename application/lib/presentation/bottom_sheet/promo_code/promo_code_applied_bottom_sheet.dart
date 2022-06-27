import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_informational_body.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class PromoCodeAppliedBottomSheet extends BottomSheetBase {
  PromoCodeAppliedBottomSheet({
    Key? key,
    required PromoCode promoCode,
  }) : super(
          key: key,
          body: BottomSheetInformationalBody(
            title: R.strings.promoCodeSuccessResultTitle.format(
                (promoCode.grantedDuration ?? const Duration(days: 0))
                    .inDays
                    .toString()),
            body: R.strings.promoCodeSuccessResultBody,
            illustrationAssetName:
                R.assets.lottie.contextual.subscriptionActive,
          ),
        );
}

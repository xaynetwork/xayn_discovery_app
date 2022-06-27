import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/manager/redeem_promo_code_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/manager/redeem_promo_code_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

extension on RedeemPromoCodeError {
  String get translation {
    switch (this) {
      case RedeemPromoCodeError.unknownPromoCode:
        return R.strings.promoCodeErrorCodeNotFound;
      case RedeemPromoCodeError.expiredPromoCode:
        return R.strings.promoCodeErrorExpired;
    }
  }
}

typedef OnRedeemSuccessful = Function(PromoCode code);

class RedeemPromoCodeBottomSheet extends BottomSheetBase {
  RedeemPromoCodeBottomSheet({
    Key? key,
    VoidCallback? onSystemPop,
    required OnRedeemSuccessful onRedeemSuccessful,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _RedeemPromoCode(
            onRedeemSuccessful: onRedeemSuccessful,
            onSystemPop: onSystemPop,
          ),
        );
}

class _RedeemPromoCode extends StatefulWidget {
  const _RedeemPromoCode({
    Key? key,
    required this.onRedeemSuccessful,
    this.onSystemPop,
  }) : super(key: key);

  final OnRedeemSuccessful onRedeemSuccessful;
  final VoidCallback? onSystemPop;

  @override
  _RedeemPromoCodeState createState() => _RedeemPromoCodeState();
}

class _RedeemPromoCodeState extends State<_RedeemPromoCode>
    with BottomSheetBodyMixin {
  late final RedeemPromoCodeManager _manager = di.get();
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<RedeemPromoCodeManager, RedeemPromoCodeState>(
        bloc: _manager,
        listener: (ct, s) {
          s.mapOrNull(successful: (success) {
            closeBottomSheet(context);
            widget.onRedeemSuccessful(success.code);
          });
        },
        builder: (context, state) {
          final textField = AppTextField(
            autofocus: true,
            controller: _textEditingController,
            onChanged: _manager.onPromoCodeTyped,
            onSubmitted: _manager.redeemPromoCode,
            errorText: state.mapOrNull(error: (e) => e.error.translation),
          );

          final header = Padding(
            padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
            child: BottomSheetHeader(
              headerText: R.strings.promoCodeEnterTitle,
            ),
          );

          final footer = BottomSheetFooter(
            onCancelPressed: () {
              widget.onSystemPop?.call();
              closeBottomSheet(context);
            },
            setup: BottomSheetFooterSetup.row(
              buttonData: BottomSheetFooterButton(
                text: R.strings.promoCodeActionApplyCode,
                onPressed: () =>
                    _manager.redeemPromoCode(_textEditingController.text),
              ),
            ),
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              textField,
              footer,
            ],
          );
        },
      );
}

import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/spans.dart';

class ContactInfoBottomSheet extends BottomSheetBase {
  ContactInfoBottomSheet({
    required VoidCallback onXaynSupportEmailTap,
    required VoidCallback onXaynPressEmailTap,
    required VoidCallback onXaynUrlTap,
    Key? key,
  }) : super(
          key: key,
          body: _ContactInfoBottomSheet(
            onXaynPressEmailTap: onXaynPressEmailTap,
            onXaynSupportEmailTap: onXaynSupportEmailTap,
            onXaynUrlTap: onXaynUrlTap,
          ),
        );
}

class _ContactInfoBottomSheet extends StatelessWidget
    with BottomSheetBodyMixin {
  final VoidCallback onXaynSupportEmailTap, onXaynPressEmailTap, onXaynUrlTap;

  _ContactInfoBottomSheet({
    required this.onXaynSupportEmailTap,
    required this.onXaynPressEmailTap,
    required this.onXaynUrlTap,
  });

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: EdgeInsets.only(bottom: R.dimen.unit2),
      child: BottomSheetHeader(
        headerText: R.strings.settingsContactUs,
      ),
    );

    final closeButton = AppGhostButton.text(
      R.strings.errorClose,
      onPressed: () => closeBottomSheet(context),
      backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        _buildAddressSection(),
        _buildLinksSection(),
        SizedBox(height: R.dimen.unit2),
        closeButton,
      ],
    );
  }

  Widget _buildAddressSection() => Text.rich(
        [
          Constants.xaynName.bold(),
          Constants.xaynAddress.span(),
        ].span(),
      );

  Widget _buildLinksSection() {
    final space = ' '.span();
    final newLine = '\n'.span();
    return Text.rich(
      [
        Uri.parse(Constants.xaynUrl).host.link(onTap: onXaynUrlTap),
        newLine,
        newLine,
        R.strings.contactSectionSupportEmail.bold(),
        space,
        Constants.xaynSupportEmail.link(onTap: () => onXaynSupportEmailTap),
        newLine,
        R.strings.contactSectionForPublishers.bold(),
        space,
        Constants.xaynPressEmail.link(onTap: onXaynPressEmailTap),
        newLine,
        R.strings.contactSectionPhone.bold(),
        space,
        Constants.xaynPressPhone.span(),
      ].span(),
    );
  }
}

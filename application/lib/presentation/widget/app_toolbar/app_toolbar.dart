import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_additional_widget_data.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/model/app_toolbar_icon_model.dart';

import 'app_toolbar_trailing_button.dart';

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  final AppToolbarData appToolbarData;

  /// Widget to show above the toolbar
  final AppToolbarAdditionalWidgetData? additionalWidgetData;

  const AppToolbar({
    Key? key,
    required this.appToolbarData,
    this.additionalWidgetData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = appToolbarData.title;
    final text = Text(title, style: R.styles.lBoldStyle);
    final content = appToolbarData.map(
      titleOnly: (_) => _buildWithTextOnly(text),
      withTrailingIcon: (data) => _buildWithTrailingIcon(
        text: text,
        iconPath: data.iconPath,
        onPressed: data.onPressed,
        iconKey: data.iconkey,
      ),
      withTwoTrailingIcons: (data) => _buildWithTwoTrailingIcons(
        iconModels: data.iconModels,
        text: text,
      ),
    );

    return SafeArea(
      child: additionalWidgetData == null
          ? _buildBaseToolbar(content)
          : _buildToolbarWithAdditionalWidget(content),
    );
  }

  Widget _buildToolbarWithAdditionalWidget(Widget content) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          additionalWidgetData!.widget,
          _buildBaseToolbar(content),
        ],
      );

  Widget _buildBaseToolbar(Widget content) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit3,
          vertical: R.dimen.unit4,
        ),
        child: content,
      );

  Widget _buildWithTextOnly(Text text) => SizedBox(
        child: Container(
          alignment: AlignmentDirectional.centerStart,
          child: text,
        ),
      );

  Widget _buildWithTrailingIcon({
    required Text text,
    required String iconPath,
    VoidCallback? onPressed,
    Key? iconKey,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text,
          AppToolbarTrailingIconButton(
            iconKey: iconKey,
            iconPath: iconPath,
            onPressed: onPressed,
          ),
        ],
      );

  Widget _buildWithTwoTrailingIcons({
    required Text text,
    required List<AppToolbarIconModel> iconModels,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text,
          _buildIconsRow(iconModels: iconModels),
        ],
      );

  Widget _buildIconsRow({
    required List<AppToolbarIconModel> iconModels,
  }) =>
      Row(
        children: [
          AppToolbarTrailingIconButton(
            iconKey: iconModels.first.iconKey,
            iconPath: iconModels.first.iconPath,
            onPressed: iconModels.first.onPressed,
          ),
          SizedBox(width: R.dimen.unit2),
          AppToolbarTrailingIconButton(
            iconKey: iconModels[1].iconKey,
            iconPath: iconModels[1].iconPath,
            onPressed: iconModels[1].onPressed,
          ),
        ],
      );

  @override
  Size get preferredSize => Size.fromHeight(
        additionalWidgetData == null
            ? R.dimen.unit12
            : R.dimen.unit12 * additionalWidgetData!.widgetHeight,
      );
}

class TrailingIcon {
  final String icon;
  final VoidCallback? onPressed;

  TrailingIcon({required this.icon, this.onPressed});
}

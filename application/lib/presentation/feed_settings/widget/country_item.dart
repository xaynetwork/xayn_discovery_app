import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CountryItem extends StatelessWidget {
  final Country country;
  final bool isSelected;
  final VoidCallback onActionPressed;

  const CountryItem({
    Key? key,
    required this.country,
    required this.isSelected,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        _buildFlag(),
        _buildName(),
        const Spacer(),
        _buildIcon(),
      ],
    );
    final decoration = BoxDecoration(
      color: R.colors.settingsCardBackground,
      borderRadius: R.styles.roundBorder,
      border: isSelected
          ? Border.all(
              width: R.dimen.unit0_25,
              color: R.colors.accent,
            )
          : null,
    );
    final container = Container(
      height: R.dimen.iconButtonSize,
      decoration: decoration,
      padding: EdgeInsets.only(left: R.dimen.unit1_5),
      key: country.key,
      child: row,
    );
    return Padding(
      padding: EdgeInsets.only(top: R.dimen.unit),
      child: GestureDetector(onTap: onActionPressed, child: container),
    );
  }

  Widget _buildName() {
    final countryName = Text(
      country.name,
      style: R.styles.mBoldStyle,
    );
    final children = <Widget>[
      countryName,
    ];

    final languageName = country.language;
    if (languageName != null) {
      final language = Text(
        languageName,
        style: R.styles.sStyle.copyWith(
          color: R.colors.secondaryText,
        ),
      );
      children.add(language);
    }

    return Padding(
      padding: EdgeInsets.only(left: R.dimen.unit1_5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildIcon() {
    return SizedBox(
        width: R.dimen.iconButtonSize,
        child: SvgPicture.asset(
          isSelected ? R.assets.icons.cross : R.assets.icons.plus,
          width: R.dimen.unit2,
          height: R.dimen.unit2,
        ));
  }

  Widget _buildFlag() => ClipRRect(
      borderRadius: BorderRadius.circular(3.0),
      child: SvgPicture.asset(
        country.svgFlagAssetPath,
        width: R.dimen.unit3,
        height: R.dimen.unit3,
      ));
}

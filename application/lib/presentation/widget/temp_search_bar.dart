import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// Signature of callbacks that takes search term as input.
typedef SearchCallback = void Function(String);

/// A temporary widget which displays a search input field.
/// Should be removed once the bottom navigation is ready.
class TempSearchBar extends StatelessWidget {
  const TempSearchBar({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  final SearchCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final prefixIcon = SizedBox(
      height: R.dimen.unit2_75,
      child: SvgPicture.asset(R.assets.icons.search),
    );

    final textField = TextField(
      onChanged: (term) => onSearch(term),
      decoration: InputDecoration(
        hintText: 'Search',
        border: InputBorder.none,
        prefixIconConstraints: BoxConstraints(
          minHeight: R.dimen.unit2_75,
        ),
        prefixIcon: prefixIcon,
      ),
    );

    return Container(
      height: R.dimen.unit8,
      decoration: ShapeDecoration(
        color: R.colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: R.styles.roundBorder,
        ),
        shadows: [
          BoxShadow(
            color: R.colors.primaryText.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(R.dimen.unit1_5),
        child: Container(
          child: textField,
          decoration: ShapeDecoration(
            color: R.colors.searchInputFill,
            shape: RoundedRectangleBorder(
              borderRadius: R.styles.roundBorder,
            ),
          ),
        ),
      ),
    );
  }
}

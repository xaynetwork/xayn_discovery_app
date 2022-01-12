import 'package:flutter/cupertino.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

NavBarItemBackButton buildNavBarItemBack({
  required VoidCallback onPressed,
}) =>
    NavBarItemBackButton(
      onPressed: onPressed,
      key: Keys.navBarItemBackBtn,
    );

NavBarItemIconButton buildNavBarItemArrowLeft({
  required VoidCallback onPressed,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.arrowLeft,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemArrowLeft,
    );

NavBarItemIconButton buildNavBarItemLike({
  required VoidCallback onPressed,
  required bool isLiked,
}) =>
    NavBarItemIconButton(
      svgIconPath: isLiked
          ? R.linden.assets.icons.thumbsUpActive
          : R.linden.assets.icons.thumbsUp,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemLike,
    );

NavBarItemIconButton buildNavBarItemDisLike({
  required VoidCallback onPressed,
  required bool isDisLiked,
}) =>
    NavBarItemIconButton(
      svgIconPath: isDisLiked
          ? R.linden.assets.icons.thumbsDownActive
          : R.linden.assets.icons.thumbsDown,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemDisLike,
    );

NavBarItemIconButton buildNavBarItemShare({
  required VoidCallback onPressed,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.share,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemShare,
    );

NavBarItemIconButton buildNavBarItemHome({
  required VoidCallback onPressed,
  bool isActive = false,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.home,
      isHighlighted: isActive,
      onPressed: onPressed,
      key: Keys.navBarItemHome,
    );

NavBarItemIconButton buildNavBarItemSearch({
  required VoidCallback onPressed,
  bool isActive = false,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.search,
      isHighlighted: isActive,
      onPressed: onPressed,
      key: Keys.navBarItemSearch,
    );

NavBarItemEdit buildNavBarItemSearchActive({
  required OnSearchPressed onSearchPressed,
  bool isActive = false,
  String? hint,
}) =>
    NavBarItemEdit(
      svgIconPath: R.linden.assets.icons.search,
      isHighlighted: isActive,
      onSearchPressed: onSearchPressed,
      hint: hint,
      key: Keys.navBarItemSearch,
    );

NavBarItemIconButton buildNavBarItemPersonalArea({
  required VoidCallback onPressed,
  bool isActive = false,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.person,
      isHighlighted: isActive,
      onPressed: onPressed,
      key: Keys.navBarItemPersonalArea,
    );

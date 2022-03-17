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

NavBarItemIconButton buildNavBarItemEditFont({
  required VoidCallback onPressed,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.text,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemEditFontSize,
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
  bool isDisabled = false,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.search,
      isHighlighted: isActive && !isDisabled,
      isDisabled: isDisabled,
      onPressed: onPressed,
      key: Keys.navBarItemSearch,
    );

NavBarItemEdit buildNavBarItemSearchActive({
  required OnSearchPressed onSearchPressed,
  bool isActive = false,
  bool autofocus = true,
  String? hint,
  String? initialText,
}) =>
    NavBarItemEdit(
      svgIconPath: R.linden.assets.icons.search,
      isHighlighted: isActive,
      onSearchPressed: onSearchPressed,
      hint: hint,
      autofocus: autofocus,
      initialText: initialText,
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

NavBarItemIconButton buildNavBarItemBookmark({
  required VoidCallback onPressed,
  required VoidCallback onLongPressed,
  required bool isBookmarked,
}) =>
    NavBarItemIconButton(
      svgIconPath: isBookmarked
          ? R.assets.icons.bookmarkActive
          : R.assets.icons.bookmark,
      isHighlighted: false,
      onPressed: onPressed,
      onLongPressed: onLongPressed,
      key: Keys.navBarItemBookmark,
    );

const configIdSearch = NavBarConfigId('active_search');
const configIdDiscoveryFeed = NavBarConfigId('discovery_feed');
const configIdDiscoveryCardScreen = NavBarConfigId('discovery_card_screen');
const configIdDiscoveryCard = NavBarConfigId('discovery_card');
const configIdPersonalArea = NavBarConfigId('personal_area');

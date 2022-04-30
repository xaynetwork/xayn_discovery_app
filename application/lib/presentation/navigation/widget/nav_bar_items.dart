import 'package:flutter/cupertino.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';

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
      semanticsLabel: Keys.navBarItemArrowLeft.valueKey
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
      semanticsLabel: Keys.navBarItemLike.valueKey
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
      semanticsLabel: Keys.navBarItemDisLike.valueKey
    );

NavBarItemIconButton buildNavBarItemShare({
  required VoidCallback onPressed,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.share,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemShare,
      semanticsLabel: Keys.navBarItemShare.valueKey
    );

NavBarItemIconButton buildNavBarItemEditFont({
  required VoidCallback onPressed,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.text,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemEditFontSize,
      semanticsLabel: Keys.navBarItemEditFontSize.valueKey
    );

NavBarItemIconButton buildNavBarItemHome({
  required VoidCallback onPressed,
  bool isActive = false,
}) =>
    NavBarItemIconButton(
      svgIconPath: isActive
          ? R.linden.assets.icons.homeActive
          : R.linden.assets.icons.home,
      isHighlighted: isActive,
      onPressed: onPressed,
      key: Keys.navBarItemHome,
      semanticsLabel: Keys.navBarItemHome.valueKey
    );

NavBarItemIconButton buildNavBarItemSearch({
  required VoidCallback onPressed,
}) =>
    NavBarItemIconButton(
      svgIconPath: R.linden.assets.icons.search,
      isHighlighted: false,
      onPressed: onPressed,
      key: Keys.navBarItemSearch,
        semanticsLabel: Keys.navBarItemSearch.valueKey
    );

NavBarItemEdit buildNavBarItemSearchActive({
  required OnSearchPressed onSearchPressed,
  bool autofocus = true,
  String? hint,
  String? initialText,
}) =>
    NavBarItemEdit(
      svgIconPath: R.linden.assets.icons.searchActive,
      isHighlighted: true,
      onSearchPressed: onSearchPressed,
      hint: hint,
      autofocus: autofocus,
      initialText: initialText,
      key: Keys.navBarItemSearch,
      semanticsLabel: Keys.navBarItemSearch.valueKey
    );

NavBarItemIconButton buildNavBarItemPersonalArea({
  required VoidCallback onPressed,
  bool isActive = false,
}) =>
    NavBarItemIconButton(
      svgIconPath: isActive
          ? R.linden.assets.icons.personActive
          : R.linden.assets.icons.person,
      isHighlighted: isActive,
      onPressed: onPressed,
      key: Keys.navBarItemPersonalArea,
      semanticsLabel: Keys.navBarItemPersonalArea.valueKey
    );

NavBarItemIconButton buildNavBarItemBookmark({
  required VoidCallback onPressed,
  required VoidCallback onLongPressed,
  required BookmarkStatus bookmarkStatus,
}) =>
    NavBarItemIconButton(
      svgIconPath: bookmarkStatus == BookmarkStatus.bookmarked
          ? R.assets.icons.bookmarkActive
          : R.assets.icons.bookmark,
      isHighlighted: false,
      onPressed: onPressed,
      onLongPressed: onLongPressed,
      key: Keys.navBarItemBookmark,
      semanticsLabel: Keys.navBarItemBookmark.valueKey
    );

const configIdSearch = NavBarConfigId('active_search');
const configIdDiscoveryFeed = NavBarConfigId('discovery_feed');
const configIdDiscoveryCardScreen = NavBarConfigId('discovery_card_screen');
const configIdDiscoveryCard = NavBarConfigId('discovery_card');
const configIdPersonalArea = NavBarConfigId('personal_area');

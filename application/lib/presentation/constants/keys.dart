import 'package:flutter/material.dart';

class Keys {
  Keys._();

  static const Key featureSelectionButton = Key('featureSelectionButton');

  static const Key onBoardingPageOne = Key('onBoardingPageOne');
  static const Key onBoardingPageTwo = Key('onBoardingPageTwo');
  static const Key onBoardingPageThree = Key('onBoardingPageThree');
  static const Key onBoardingPageTapDetector = Key('onBoardingPageTapDetector');

  static const Key personalAreaCardCollections =
      Key('personal_area_card_collections');
  static const Key personalAreaIconSettings =
      Key('personal_area_icon_settings');

  static const Key settingsThemeSystem = Key('settings_theme_item_system');
  static const Key settingsThemeLight = Key('settings_theme_item_light');
  static const Key settingsThemeDark = Key('settings_theme_item_dark');

  static const Key settingsScrollDirectionVertical =
      Key('settings_scroll_direction_vertical');
  static const Key settingsScrollDirectionHorizontal =
      Key('settings_scroll_direction_horizontal');

  static const Key settingsSubscriptionPremium =
      Key('settings_subscription_premium');

  static const Key settingsContactUs = Key('settings_contact_us');
  static const Key settingsAboutXayn = Key('settings_about_xayn');
  static const Key settingsCarbonNeutral = Key('settings_carbon_neutral');
  static const Key settingsImprint = Key('settings_imprint');
  static const Key settingsPrivacyPolicy = Key('settings_privacy_policy');
  static const Key settingsTermsAndConditions =
      Key('settings_terms_and_conditions');
  static const Key settingsHaveFoundBug = Key('settings_have_found_bug');
  static const Key settingsShareBtn = Key('settings_share');
  static const Key settingsToggleTextToSpeechPreference =
      Key('settingsToggleTextToSpeechPreference');
  static const Key settingsCountriesOption = Key('settings_countries_option');
  static const Key settingsSourcesOption = Key('settings_sources_option');

  static const Key navBarItemBackBtn = Key('nav_bar_item_back_btn');
  static const Key navBarItemHome = Key('nav_bar_item_home');
  static const Key navBarItemSearch = Key('nav_bar_item_search');
  static const Key navBarItemPersonalArea = Key('nav_bar_item_personal_area');
  static const Key navBarItemArrowLeft = Key('nav_bar_item_arrow_left');
  static const Key navBarItemLike = Key('nav_bar_item_like');
  static const Key navBarItemDisLike = Key('nav_bar_item_dis_like');
  static const Key navBarItemShare = Key('nav_bar_item_share');
  static const Key navBarItemBookmark = Key('nav_bar_item_bookmark');
  static const Key navBarItemEditFontSize = Key('nav_bar_item_edit_font_size');

  static const Key feedView = Key('feed_view');

  static Key collectionItem(String value) => Key('collectionItem' + value);
  static Key generateCollectionsScreenCardKey(String collectionId) =>
      Key('collections_screen_card' + collectionId);
}

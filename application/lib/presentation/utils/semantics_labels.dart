class SemanticsLabels {
  SemanticsLabels._();

  static const String personalAreaIconPlus = 'personal_area_icon_plus';

  static const String personalAreaIconSettings = 'personal_area_icon_settings';

  static String generateCollectionItemLabel(int index) =>
      'collection_item_$index';

  static String generateBookmarkItemLabel(int index) => 'bookmark_item_$index';
}

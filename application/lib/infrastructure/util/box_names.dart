enum BoxNames {
  appSettings,
  collections,
  bookmarks,
  documents,
  appStatus,
  feed,
  feedSettings,
  feedTypeMarkets,
  explicitDocumentFeedback,
  readerModeSettings,
  userInteractions,
  migrationInfo,
}

extension BoxNamesExtension on BoxNames {
  static List<BoxNames> get valuesWithoutMigrationInfo => BoxNames.values
      .where((value) => value != BoxNames.migrationInfo)
      .toList();
}

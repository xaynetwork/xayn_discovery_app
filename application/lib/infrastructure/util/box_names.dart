enum BoxNames {
  appSettings,
  collections,
  bookmarks,
  documents,
  documentFilters,
  appStatus,
  feed,
  feedSettings,
  feedTypeMarkets,
  explicitDocumentFeedback,
  readerModeSettings,
  migrationInfo,
}

extension BoxNamesExtension on BoxNames {
  static List<BoxNames> get valuesWithoutMigrationInfo => BoxNames.values
      .takeWhile((value) => value != BoxNames.migrationInfo)
      .toList();
}

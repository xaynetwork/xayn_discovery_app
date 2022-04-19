abstract class BoxNames {
  const BoxNames._();

  static const appSettings = 'settings';
  static const collections = 'collections';
  static const bookmarks = 'bookmarks';
  static const documents = 'documents';
  static const documentFilters = 'documentFilters';
  static const appStatus = 'appStatus';
  static const feed = 'feed';
  static const feedSettings = 'feedSettings';
  static const feedTypeMarkets = 'feedTypeMarkets';
  static const explicitDocumentFeedback = 'explicitDocumentFeedback';
  static const readerModeSettings = 'readerModeSettings';
  static const migrationInfo = 'migrationInfo';

  static List<String> valuesWithoutMigrationInfo = [
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
  ];

  static List<String> values = valuesWithoutMigrationInfo..add(migrationInfo);
}

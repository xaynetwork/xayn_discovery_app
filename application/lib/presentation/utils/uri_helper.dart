class UriHelper {
  /// A safe method to parse [Uri]s to protect from potential socket exception
  static Uri safeUri(Uri uri) => Uri.parse(uri.toString());
}

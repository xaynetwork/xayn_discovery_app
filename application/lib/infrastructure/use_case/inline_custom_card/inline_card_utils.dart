class InLineCardUtils {
  /// Since [InLineCardInjection] accounts for the upcoming next card, we account for showing the card next in the feed
  static bool hasExceededSwipeCount(int scrollCount, int scrollThreshold) =>
      scrollCount >= scrollThreshold - 1;
}

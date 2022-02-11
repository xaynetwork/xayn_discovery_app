/// Indicates how exactly a feedback change came to be,
/// for example, tapping on "like" is [implicit],
/// whereas opening a card in a browser, is [explicit].
enum FeedbackContext {
  explicit,
  implicit,
}

/// In conjunction with the heuristic paragraph filters:
/// certain paragraphs may be removed from story mode for
/// various reasons, this enum contains the associated rejection reasons.
enum ParagraphRejectedReason {
  notEnoughWords,
  allUppercase,
  containsMostlyLinks,
}

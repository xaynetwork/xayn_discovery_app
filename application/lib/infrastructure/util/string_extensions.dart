extension StringExtension on String {
  /// Splits a `String` into two parts:
  /// The algorithm will start out in the middle of the `String`,
  /// if the middle character does not match [pattern], then
  /// it moves both to the left and right of that character and
  /// tests if a split can occur on either next one.
  ///
  /// Left and right will keep moving away from the center in either
  /// direction, until a valid split position is found.
  ///
  /// The result is a `List` with 2 items,
  /// - the first part, before the split position
  /// - the remaining part, after the split position
  ///
  /// The character that was at the split position is removed.
  ///
  /// For example:
  /// ```dart
  /// const String paragraph = 'Lorem ipsum dolor si amet.';
  /// print(paragraph.split(RegExp(r'\W')));
  /// // prints: ['Lorem ipsum', 'dolor si amet.']
  /// ```
  ///
  /// If no good split index could be found, that is, no character at all
  /// pass the [pattern] test, then the middle-most position will be
  /// used instead:
  ///
  /// ```dart
  /// const String paragraph = 'abcd';
  /// print(paragraph.split(RegExp(r'\W')));
  /// // prints: ['ab', 'cd']
  /// ```
  List<String> splitEqually(final Pattern pattern,
      {final String indicator = ''}) {
    final index = length ~/ 2;
    var offset = 0;

    maybeAppendIndicator(final String value) => '$value$indicator';
    maybePrependIndicator(final String value) => '$indicator$value';
    toTuple({required String left, required String right}) => [
          maybeAppendIndicator(left),
          maybePrependIndicator(right),
        ];

    while (offset <= index) {
      final leftSplitIndex = index - offset;
      final rightSplitIndex = index + offset;
      final leftChar = leftSplitIndex >= 0 ? this[leftSplitIndex] : null;
      final rightChar = rightSplitIndex < length ? this[rightSplitIndex] : null;

      hasMatch(final String value) => pattern.matchAsPrefix(value) != null;

      if (leftChar != null && hasMatch(leftChar)) {
        return toTuple(
          left: substring(0, leftSplitIndex),
          right: substring(leftSplitIndex + 1, length),
        );
      } else if (rightChar != null && hasMatch(rightChar)) {
        return toTuple(
          left: substring(0, rightSplitIndex),
          right: substring(rightSplitIndex + 1, length),
        );
      }

      offset++;
    }

    return toTuple(
      left: substring(0, index),
      right: substring(index, length),
    );
  }
}

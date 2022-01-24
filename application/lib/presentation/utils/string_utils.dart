extension StringUtils on String {
  bool isUpperCase() => this == toUpperCase();

  String camelCaseToLowerCaseSeparatedBy([String charBetweenWords = '']) {
    var sb = StringBuffer();
    var first = true;
    for (int i = 0; i < runes.length; i++) {
      final rune = runes.elementAt(i);
      var char = String.fromCharCode(rune);
      if (char.isUpperCase() && !first) {
        if (char != charBetweenWords) {
          sb.write(charBetweenWords);
        }
        sb.write(char.toLowerCase());
      } else {
        first = false;
        sb.write(char.toLowerCase());
      }
    }
    return sb.toString();
  }

  String capitalize({bool allWords = false}) {
    if (isEmpty) {
      return '';
    }
    final result = trim();
    if (allWords) {
      var words = result.split(' ');
      var capitalized = [];
      for (var w in words) {
        capitalized.add(w.capitalize());
      }
      return capitalized.join(' ');
    } else {
      return result.substring(0, 1).toUpperCase() +
          result.substring(1).toLowerCase();
    }
  }

  String truncate(int maxLength) =>
      length < maxLength ? this : substring(0, maxLength);
}

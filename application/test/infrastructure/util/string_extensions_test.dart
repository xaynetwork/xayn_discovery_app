import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';

void main() {
  group('split: ', () {
    test('finds the best split position: ', () {
      const value = 'Lorem ipsum dolor si amet.';

      expect(value.splitEqually(RegExp(r'\W')),
          const ['Lorem ipsum', 'dolor si amet.']);
    });

    test('can use split indicator: ', () {
      const value = 'Lorem ipsum dolor si amet.';

      expect(value.splitEqually(RegExp(r'\W'), indicator: '...'),
          const ['Lorem ipsum...', '...dolor si amet.']);
    });

    test('edge case A: ', () {
      const value = 'I abcdefghijklmnopqrstuvwxyz';

      expect(value.splitEqually(RegExp(r'\W')),
          const ['I', 'abcdefghijklmnopqrstuvwxyz']);
    });

    test('edge case B: ', () {
      const value = 'abcdefghijklmnopqrstuvwxyz I';

      expect(value.splitEqually(RegExp(r'\W')),
          const ['abcdefghijklmnopqrstuvwxyz', 'I']);
    });

    test('edge case C: ', () {
      const value = ' abcdefghijklmnopqrstuvwxyz';

      expect(value.splitEqually(RegExp(r'\W')),
          const ['', 'abcdefghijklmnopqrstuvwxyz']);
    });

    test('edge case D: ', () {
      const value = 'abcdefghijklmnopqrstuvwxyz ';

      expect(value.splitEqually(RegExp(r'\W')),
          const ['abcdefghijklmnopqrstuvwxyz', '']);
    });

    test('splits in the middle on negative match (even): ', () {
      const value = 'abcd';

      expect(value.splitEqually(RegExp(r'\W')), const ['ab', 'cd']);
    });

    test('splits in the middle on negative match (uneven): ', () {
      const value = 'abcde';

      expect(value.splitEqually(RegExp(r'\W')), const ['ab', 'cde']);
    });
  });
}

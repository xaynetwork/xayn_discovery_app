import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size_param.dart';

void main() {
  test(
    'GIVEN param THEN verify it is equatable',
    () {
      const param = ReaderModeFontSizeParam(size: 3, height: 4);
      expect(param, isA<Equatable>());
      expect(param.props, equals([3, 4]));
    },
  );
  test(
    'GIVEN values THEN verify they set correctly',
    () {
      const size = 24.0;
      const height = 42.0;

      const param = ReaderModeFontSizeParam(size: size, height: height);
      expect(param.size, equals(size));
      expect(param.height, equals(height));
    },
  );
  test(
    'GIVEN size and height == 0  and below 0 THEN verify exception',
    () {
      expect(
        () => ReaderModeFontSizeParam(size: 0, height: 4),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ReaderModeFontSizeParam(size: 4, height: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ReaderModeFontSizeParam(size: -1, height: 4),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ReaderModeFontSizeParam(size: 4, height: -1),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  test(
    'GIVEN default, min and max params THEN verify they are correct',
    () {
      expect(
        ReaderModeFontSizeParams.defaultValue,
        equals(ReaderModeFontSizeParams.size14),
      );
      expect(
        ReaderModeFontSizeParams.min,
        equals(ReaderModeFontSizeParams.values.first),
      );
      expect(
        ReaderModeFontSizeParams.max,
        equals(ReaderModeFontSizeParams.values.last),
      );
    },
  );

  test(
    'GIVEN list of params THEN verify they sorted by increasing size',
    () {
      var previousSize = 0.0;
      for (final param in ReaderModeFontSizeParams.values) {
        expect(param.size > previousSize, isTrue);
        previousSize = param.size;
      }
    },
  );

  test(
    'GIVEN smallest and biggest params THEN verify they are correct',
    () {
      const smallest = ReaderModeFontSizeParams.size10;
      const biggest = ReaderModeFontSizeParams.size24;
      const delta = 0.00001;

      expect(smallest.isSmallest, isTrue);
      expect(
        ReaderModeFontSizeParam(
          size: smallest.size - delta,
          height: smallest.height,
        ).isSmallest,
        isTrue,
      );
      expect(
        ReaderModeFontSizeParam(
          size: smallest.size + delta,
          height: smallest.height,
        ).isSmallest,
        isFalse,
      );

      expect(biggest.isBiggest, isTrue);
      expect(
        ReaderModeFontSizeParam(
          size: biggest.size + delta,
          height: biggest.height,
        ).isBiggest,
        isTrue,
      );
      expect(
        ReaderModeFontSizeParam(
          size: biggest.size - delta,
          height: biggest.height,
        ).isBiggest,
        isFalse,
      );
    },
  );

  test(
    'GIVEN param WHEN asking for smaller THEN return correct value',
    () {
      const param = ReaderModeFontSizeParams.size12;
      expect(
        param.smaller,
        equals(ReaderModeFontSizeParams.size10),
      );
      expect(
        ReaderModeFontSizeParams.min,
        equals(ReaderModeFontSizeParams.min),
      );
    },
  );

  test(
    'GIVEN param WHEN asking for bigger THEN return correct value',
    () {
      const param = ReaderModeFontSizeParams.size12;
      expect(
        param.bigger,
        equals(ReaderModeFontSizeParams.size14),
      );
      expect(
        ReaderModeFontSizeParams.max,
        equals(ReaderModeFontSizeParams.max),
      );
    },
  );
}

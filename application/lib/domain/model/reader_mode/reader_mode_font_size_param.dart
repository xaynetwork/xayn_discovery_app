import 'package:equatable/equatable.dart';

class ReaderModeFontSizeParam extends Equatable {
  final double size;
  final double height;

  const ReaderModeFontSizeParam({
    required this.size,
    required this.height,
  })  : assert(size > 0, 'Size should be positive'),
        assert(height > 0, 'Height should be positive');

  @override
  List<Object> get props => [
        size,
        height,
      ];

  bool get isSmallest => size <= ReaderModeFontSizeParams.min.size;

  bool get isBiggest => size >= ReaderModeFontSizeParams.max.size;

  ReaderModeFontSizeParam get smaller =>
      ReaderModeFontSizeParams.values.lastWhere(
        (element) => element.size < size,
        orElse: () => this,
      );

  ReaderModeFontSizeParam get bigger =>
      ReaderModeFontSizeParams.values.firstWhere(
        (element) => element.size > size,
        orElse: () => this,
      );
}

class ReaderModeFontSizeParams {
  ReaderModeFontSizeParams._();

  static const values = [
    size10,
    size12,
    size14,
    size16,
    size18,
    size22,
    size24,
  ];

  static const size10 = ReaderModeFontSizeParam(size: 10, height: 18);
  static const size12 = ReaderModeFontSizeParam(size: 12, height: 20);
  static const size14 = ReaderModeFontSizeParam(size: 14, height: 24);
  static const size16 = ReaderModeFontSizeParam(size: 16, height: 28);
  static const size18 = ReaderModeFontSizeParam(size: 18, height: 30);
  static const size22 = ReaderModeFontSizeParam(size: 22, height: 32);
  static const size24 = ReaderModeFontSizeParam(size: 24, height: 34);

  static const defaultValue = size14;
  static final min = values.first;
  static final max = values.last;
}

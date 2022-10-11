import 'dart:math' as math;

void main() {
  final size = 7;
  final random = math.Random();
  final dates = List.generate(size,
      (_) => DateTime.fromMicrosecondsSinceEpoch(random.nextInt(4294967296)));
  final result = cartesianProduct(dates, dates);
  final test = result.where((it) => it.i < it.j).map((it) =>
      it.entryA.millisecondsSinceEpoch - it.entryB.millisecondsSinceEpoch).toList();

  print(test);

  ///
  ///
  ///

  triangleNumber(int length) => length * (length - 1) ~/ 2;

  final combo = <int>[];
  final tn = triangleNumber(size);
  var primaryIndex = 0;
  var take = size - 1;
  var took = 0;

  for (var i = 0; i < tn; i++) {
    if (took == take) {
      take--;
      took = 0;
      primaryIndex++;
    }

    took++;

    print({
      'primaryIndex': primaryIndex,
      'took': took,
      'take': take,
    });

    final secondaryIndex = primaryIndex + took;
    final entryA = dates[primaryIndex];
    final entryB = dates[secondaryIndex];

    combo.add(entryA.millisecondsSinceEpoch - entryB.millisecondsSinceEpoch);
  }

  print(combo);
}

List<CartesianProductResult<S, T>> cartesianProduct<S, T>(
    List<S> listA, List<T> listB) {
  final resultList = <CartesianProductResult<S, T>>[];

  for (var i = 0, len = listA.length; i < len; i++) {
    final entryA = listA[i];

    for (var j = 0, len = listB.length; j < len; j++) {
      final entryB = listB[j];

      resultList
          .add(CartesianProductResult(i, j, entryA: entryA, entryB: entryB));
    }
  }

  return resultList;
}

class CartesianProductResult<S, T> {
  final int i, j;
  final S entryA;
  final T entryB;

  const CartesianProductResult(
    this.i,
    this.j, {
    required this.entryA,
    required this.entryB,
  });
}

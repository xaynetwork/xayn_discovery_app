import 'package:flutter_test/flutter_test.dart';

import '../../../test_utils/fakes.dart';

void main() {
  test(
    'GIVEN Map<String, dynamic> WHEN toSerializableMap() called THEN all nested properties should be strings',
    () {
      final nonStringizedMap = {
        'isBool': true,
        'isString': 'string',
        'document': fakeDocument.toJson()
      };

      expect(nonStringizedMap['isBool'], isInstanceOf<bool>());
      expect(
          ((nonStringizedMap['document'] as Map)['documentId'] as Map)['value'],
          isInstanceOf<List>());
      expect(((nonStringizedMap['document'] as Map)['resource'] as Map)['rank'],
          isInstanceOf<int>());
      expect(
          ((nonStringizedMap['document'] as Map)['resource'] as Map)['score'],
          isInstanceOf<double>());
    },
  );
}

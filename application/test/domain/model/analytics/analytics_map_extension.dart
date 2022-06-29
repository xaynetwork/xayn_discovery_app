import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_map_extension.dart';

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

      final stringizedMap = nonStringizedMap.toAnalyticsMap();

      expect(nonStringizedMap['isBool'], isInstanceOf<bool>());
      expect(
          ((nonStringizedMap['document'] as Map)['documentId'] as Map)['value'],
          isInstanceOf<List>());
      expect(((nonStringizedMap['document'] as Map)['resource'] as Map)['rank'],
          isInstanceOf<int>());
      expect(
          ((nonStringizedMap['document'] as Map)['resource'] as Map)['score'],
          isInstanceOf<double>());

      expect(stringizedMap['isBool'], isInstanceOf<String>());
      expect(stringizedMap['isString'], isInstanceOf<String>());
      expect(
          stringizedMap['document.documentId.value'], isInstanceOf<String>());
      expect(stringizedMap['document.resource.rank'], isInstanceOf<String>());
      expect(stringizedMap['document.resource.score'], isInstanceOf<String>());
    },
  );
}

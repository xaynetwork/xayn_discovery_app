import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_filter_mapper.dart';

main() {
  setUp(() async {});

  final filters = [
    DocumentFilter.fromSource('xayn.com'),
    DocumentFilter.fromSource('http://cnn.com'),
    DocumentFilter.fromTopic('Sports'),
  ];

  test("Round trip conversation ", () async {
    final mapper = DocumentFilterMapper();

    final writtenFilters = filters.map(mapper.toMap).toList();

    expect(filters, writtenFilters.map(mapper.fromMap).toList());
  });
}

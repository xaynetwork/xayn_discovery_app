import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';

import 'listen_bookmarks_use_case_test.mocks.dart';

@GenerateMocks([BookmarksRepository])
void main() {
  late MockBookmarksRepository bookmarksRepository;
  late ListenBookmarksUseCase listenBookmarksUseCase;

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    listenBookmarksUseCase = ListenBookmarksUseCase(bookmarksRepository);
  });

  
}

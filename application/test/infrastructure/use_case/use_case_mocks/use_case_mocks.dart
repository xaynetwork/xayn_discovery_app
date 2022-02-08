import 'package:mockito/annotations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/domain/repository/document_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';

@GenerateMocks([
  BookmarksRepository,
  UniqueIdHandler,
  DateTimeHandler,
  CollectionsRepository,
  FileHandler,
  ShareHandler,
  LoggerHandler,
  AppSettingsRepository,
  PackageInfo,
  DocumentRepository,
  IsBookmarkedUseCase,
  CreateBookmarkFromDocumentUseCase,
  RemoveBookmarkUseCase,
])
void main() {}

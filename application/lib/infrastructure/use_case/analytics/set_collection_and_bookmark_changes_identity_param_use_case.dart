import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_bookmarks_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_collections_identity_param.dart';

@injectable
class SetCollectionAndBookmarksChangesIdentityParam
    extends UseCase<None, None> {
  final CollectionsRepository _collectionsRepository;
  final BookmarksRepository _bookmarksRepository;
  final AnalyticsService _analyticsService;

  SetCollectionAndBookmarksChangesIdentityParam(
    this._collectionsRepository,
    this._bookmarksRepository,
    this._analyticsService,
  );

  @override
  Stream<None> transaction(None param) async* {
    _updateCollectionsNumber();
    _updateBookmarksNumber();

    _collectionsRepository.watch().listen((event) {
      _updateCollectionsNumber();
    });

    _bookmarksRepository.watch().listen((event) {
      _updateBookmarksNumber();
    });

    yield none;
  }

  void _updateCollectionsNumber() {
    final numberOfCollections = _collectionsRepository.getAll().length;
    final param = NumberOfCollectionsIdentityParam(numberOfCollections);
    _analyticsService.updateIdentityParam(param);
  }

  void _updateBookmarksNumber() {
    final numberOfBookmarks = _bookmarksRepository.getAll().length;
    final param = NumberOfBookmarksIdentityParam(numberOfBookmarks);
    _analyticsService.updateIdentityParam(param);
  }
}

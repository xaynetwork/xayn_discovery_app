import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

/// Pass DocumentId of a bookmark and listen to repository changes then expect a stream if it was bookmarked or not
@injectable
class ListenIsBookmarkedUseCase extends UseCase<UniqueId, bool> {
  final BookmarksRepository _bookmarksRepository;

  ListenIsBookmarkedUseCase(this._bookmarksRepository);

  @override
  Stream<bool> transaction(UniqueId param) => _bookmarksRepository
          .watch()
          .where((event) => event.id == param)
          .map((_) => _bookmarksRepository.getById(param))
          .map((event) {
        debugPrint('listenIsBookmarked is emitting now: ${event != null}');
        return event != null;
      });
}

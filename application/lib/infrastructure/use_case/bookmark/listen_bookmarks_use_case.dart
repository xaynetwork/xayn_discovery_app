import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

@injectable
class ListenBookmarksUseCase
    extends UseCase<UniqueId, ListenBookmarksUseCaseOut> {
  final BookmarksRepository _bookmarksRepository;

  ListenBookmarksUseCase(this._bookmarksRepository);
  @override
  Stream<ListenBookmarksUseCaseOut> transaction(UniqueId param) =>
      _bookmarksRepository.watch().map(
            (_) => ListenBookmarksUseCaseOut(
              _bookmarksRepository.getByCollectionId(param),
            ),
          );
}

class ListenBookmarksUseCaseOut extends Equatable {
  final List<Bookmark> bookmarks;

  const ListenBookmarksUseCaseOut(this.bookmarks);

  @override
  List<Object?> get props => bookmarks;
}

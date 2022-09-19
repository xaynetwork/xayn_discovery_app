import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

@singleton
class UserInteractionsMapper extends BaseDbEntityMapper<UserInteractions> {
  @override
  UserInteractions? fromMap(Map? map) {
    if (map == null) return null;
    final numberOfScrolls = map[UserInteractionsFields.numberOfScrolls] as int?;
    final numberOfScrollsPerSession =
        map[UserInteractionsFields.numberOfScrollsPerSession] as int?;
    final numberOfArticlesRead =
        map[UserInteractionsFields.numberOfArticlesRead] as int?;
    final numberOfArticlesBookmarked =
        map[UserInteractionsFields.numberOfArticlesBookmarked] as int?;
    final numberOfArticlesLikedOrDisliked =
        map[UserInteractionsFields.numberOfArticlesLikedOrDisliked] as int?;
    final numberOfSourcesExcluded =
        map[UserInteractionsFields.numberOfSourcesExcluded] as int?;
    final numberOfCountriesChanged =
        map[UserInteractionsFields.numberOfCountriesChanged] as int?;
    final numberOfSearches =
        map[UserInteractionsFields.numberOfSearches] as int?;

    return UserInteractions(
      numberOfScrolls: numberOfScrolls ?? 0,
      numberOfScrollsPerSession: numberOfScrollsPerSession ?? 0,
      numberOfArticlesRead: numberOfArticlesRead ?? 0,
      numberOfArticlesBookmarked: numberOfArticlesBookmarked ?? 0,
      numberOfArticlesLikedOrDisliked: numberOfArticlesLikedOrDisliked ?? 0,
      numberOfSourcesExcluded: numberOfSourcesExcluded ?? 0,
      numberOfCountriesChanged: numberOfCountriesChanged ?? 0,
      numberOfSearches: numberOfSearches ?? 0,
    );
  }

  @override
  DbEntityMap toMap(UserInteractions entity) => {
        UserInteractionsFields.numberOfScrolls: entity.numberOfScrolls,
        UserInteractionsFields.numberOfScrollsPerSession:
            entity.numberOfScrollsPerSession,
        UserInteractionsFields.numberOfArticlesRead:
            entity.numberOfArticlesRead,
        UserInteractionsFields.numberOfArticlesBookmarked:
            entity.numberOfArticlesBookmarked,
        UserInteractionsFields.numberOfArticlesLikedOrDisliked:
            entity.numberOfArticlesLikedOrDisliked,
        UserInteractionsFields.numberOfSourcesExcluded:
            entity.numberOfSourcesExcluded,
        UserInteractionsFields.numberOfCountriesChanged:
            entity.numberOfCountriesChanged,
      };
}

abstract class UserInteractionsFields {
  UserInteractionsFields._();

  static const int numberOfScrolls = 0;
  static const int numberOfArticlesRead = 1;
  static const int numberOfArticlesBookmarked = 2;
  static const int numberOfArticlesLikedOrDisliked = 3;
  static const int numberOfSourcesExcluded = 4;
  static const int numberOfCountriesChanged = 5;
  static const int numberOfSearches = 6;
  static const int numberOfScrollsPerSession = 7;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'user_interactions.freezed.dart';

/// Object containing different interactions a user might have with the app.
/// It's been introduced in order to show the user the possibility to fill a survey
/// depending upon their interactions with the app
@freezed
class UserInteractions extends DbEntity with _$UserInteractions {
  factory UserInteractions._({
    required UniqueId id,
    required int numberOfScrolls,
    required int numberOfArticlesRead,
    required int numberOfArticlesBookmarked,
    required int numberOfArticlesLikedOrDisliked,
    required int numberOfSourcesExcluded,
    required int numberOfCountriesChanged,
    required int numberOfSearches,
  }) = _UserInteractions;

  factory UserInteractions({
    required int numberOfScrolls,
    required int numberOfArticlesRead,
    required int numberOfArticlesBookmarked,
    required int numberOfArticlesLikedOrDisliked,
    required int numberOfSourcesExcluded,
    required int numberOfCountriesChanged,
    required int numberOfSearches,
  }) =>
      UserInteractions._(
        id: UserInteractions.globalId,
        numberOfScrolls: numberOfScrolls,
        numberOfArticlesRead: numberOfArticlesRead,
        numberOfArticlesBookmarked: numberOfArticlesBookmarked,
        numberOfArticlesLikedOrDisliked: numberOfArticlesLikedOrDisliked,
        numberOfSourcesExcluded: numberOfSourcesExcluded,
        numberOfCountriesChanged: numberOfCountriesChanged,
        numberOfSearches: numberOfSearches,
      );

  factory UserInteractions.initial() => UserInteractions._(
        id: UserInteractions.globalId,
        numberOfScrolls: 0,
        numberOfArticlesRead: 0,
        numberOfArticlesBookmarked: 0,
        numberOfArticlesLikedOrDisliked: 0,
        numberOfSourcesExcluded: 0,
        numberOfCountriesChanged: 0,
        numberOfSearches: 0,
      );

  static const UniqueId globalId =
      UniqueId.fromTrustedString('user_interactions_condition_id');
}

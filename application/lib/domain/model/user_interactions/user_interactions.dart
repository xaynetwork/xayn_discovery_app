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
    required int numberOfScrollsPerSession,
    required int numberOfArticlesRead,
    required int numberOfArticlesBookmarked,
    required int numberOfArticlesLikedOrDisliked,
    required int numberOfSourcesExcluded,
    required int numberOfCountriesChanged,
    required int numberOfSearches,
    required int numberOfSourcesTrusted,
  }) = _UserInteractions;

  factory UserInteractions({
    required int numberOfScrolls,
    required int numberOfScrollsPerSession,
    required int numberOfArticlesRead,
    required int numberOfArticlesBookmarked,
    required int numberOfArticlesLikedOrDisliked,
    required int numberOfSourcesExcluded,
    required int numberOfCountriesChanged,
    required int numberOfSearches,
    required int numberOfSourcesTrusted,
  }) =>
      UserInteractions._(
        id: UserInteractions.globalId,
        numberOfScrolls: numberOfScrolls,
        numberOfScrollsPerSession: numberOfScrollsPerSession,
        numberOfArticlesRead: numberOfArticlesRead,
        numberOfArticlesBookmarked: numberOfArticlesBookmarked,
        numberOfArticlesLikedOrDisliked: numberOfArticlesLikedOrDisliked,
        numberOfSourcesExcluded: numberOfSourcesExcluded,
        numberOfCountriesChanged: numberOfCountriesChanged,
        numberOfSearches: numberOfSearches,
        numberOfSourcesTrusted: numberOfSourcesTrusted,
      );

  factory UserInteractions.initial() => UserInteractions._(
        id: UserInteractions.globalId,
        numberOfScrolls: 0,
        numberOfScrollsPerSession: 0,
        numberOfArticlesRead: 0,
        numberOfArticlesBookmarked: 0,
        numberOfArticlesLikedOrDisliked: 0,
        numberOfSourcesExcluded: 0,
        numberOfCountriesChanged: 0,
        numberOfSearches: 0,
        numberOfSourcesTrusted: 0,
      );

  static const UniqueId globalId =
      UniqueId.fromTrustedString('user_interactions_condition_id');
}

extension UserInteractionsExtension on UserInteractions {
  int get totalNumberOfInteractions =>
      numberOfScrolls +
      numberOfArticlesRead +
      numberOfArticlesBookmarked +
      numberOfArticlesLikedOrDisliked +
      numberOfSourcesExcluded +
      numberOfSourcesTrusted +
      numberOfCountriesChanged +
      numberOfSearches;
}

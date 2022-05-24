import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/user_interactions_mapper.dart';

void main() {
  late UserInteractionsMapper mapper;

  const int numberOfScrolls = 2;
  const int numberOfArticlesRead = 1;
  const int numberOfArticlesBookmarked = 0;
  const int numberOfArticlesLikedOrDisliked = 1;
  const int numberOfSourcesExcluded = 3;
  const int numberOfCountriesChanged = 2;
  const int numberOfSearches = 1;

  setUp(() async {
    mapper = UserInteractionsMapper();
  });

  group(
    'UserInteractionsMapper fromMap',
    () {
      test(
          'WHEN values from the db are not null THEN return the object with those values',
          () {
        final map = {
          UserInteractionsFields.numberOfScrolls: numberOfScrolls,
          UserInteractionsFields.numberOfArticlesRead: numberOfArticlesRead,
          UserInteractionsFields.numberOfArticlesBookmarked:
              numberOfArticlesBookmarked,
          UserInteractionsFields.numberOfArticlesLikedOrDisliked:
              numberOfArticlesLikedOrDisliked,
          UserInteractionsFields.numberOfSourcesExcluded:
              numberOfSourcesExcluded,
          UserInteractionsFields.numberOfCountriesChanged:
              numberOfCountriesChanged,
          UserInteractionsFields.numberOfSearches: numberOfSearches,
        };

        final userInteractions = mapper.fromMap(map);

        expect(
          userInteractions,
          UserInteractions(
            numberOfScrolls: numberOfScrolls,
            numberOfArticlesRead: numberOfArticlesRead,
            numberOfArticlesBookmarked: numberOfArticlesBookmarked,
            numberOfArticlesLikedOrDisliked: numberOfArticlesLikedOrDisliked,
            numberOfSourcesExcluded: numberOfSourcesExcluded,
            numberOfCountriesChanged: numberOfCountriesChanged,
            numberOfSearches: numberOfSearches,
          ),
        );
      });

      test(
        'WHEN one or more values from the db are null THEN return the object with null values set to default values',
        () {
          final map = {
            UserInteractionsFields.numberOfScrolls: null,
            UserInteractionsFields.numberOfArticlesRead: null,
            UserInteractionsFields.numberOfArticlesBookmarked: null,
            UserInteractionsFields.numberOfArticlesLikedOrDisliked: null,
            UserInteractionsFields.numberOfSourcesExcluded: null,
            UserInteractionsFields.numberOfCountriesChanged: null,
            UserInteractionsFields.numberOfSearches: null,
          };

          final userInteractions = mapper.fromMap(map);

          expect(
            userInteractions,
            UserInteractions(
              numberOfScrolls: 0,
              numberOfArticlesRead: 0,
              numberOfArticlesBookmarked: 0,
              numberOfArticlesLikedOrDisliked: 0,
              numberOfSourcesExcluded: 0,
              numberOfCountriesChanged: 0,
              numberOfSearches: 0,
            ),
          );
        },
      );
    },
  );

  group(
    'UserInteractionsMapper toMap',
    () {
      test(
        'toMap',
        () {
          final userInteractions = UserInteractions(
            numberOfScrolls: numberOfScrolls,
            numberOfArticlesRead: numberOfArticlesRead,
            numberOfArticlesBookmarked: numberOfArticlesBookmarked,
            numberOfArticlesLikedOrDisliked: numberOfArticlesLikedOrDisliked,
            numberOfSourcesExcluded: numberOfSourcesExcluded,
            numberOfCountriesChanged: numberOfCountriesChanged,
            numberOfSearches: numberOfSearches,
          );

          final map = mapper.toMap(userInteractions);

          expect(
            map,
            {
              UserInteractionsFields.numberOfScrolls: numberOfScrolls,
              UserInteractionsFields.numberOfArticlesRead: numberOfArticlesRead,
              UserInteractionsFields.numberOfArticlesBookmarked:
                  numberOfArticlesBookmarked,
              UserInteractionsFields.numberOfArticlesLikedOrDisliked:
                  numberOfArticlesLikedOrDisliked,
              UserInteractionsFields.numberOfSourcesExcluded:
                  numberOfSourcesExcluded,
              UserInteractionsFields.numberOfCountriesChanged:
                  numberOfCountriesChanged,
            },
          );
        },
      );
    },
  );
}

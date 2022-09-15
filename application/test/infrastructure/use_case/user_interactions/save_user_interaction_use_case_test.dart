import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/user_interactions_events.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockUserInteractionsRepository userInteractionsRepository;
  late MockCanDisplaySurveyBannerUseCase canDisplaySurveyBannerUseCase;
  late MockCanDisplayPushNotificationsCardUseCase
      canDisplayPushNotificationsCardUseCase;
  late SaveUserInteractionUseCase saveUserInteractionUseCase;

  userInteractionsRepository = MockUserInteractionsRepository();
  canDisplaySurveyBannerUseCase = MockCanDisplaySurveyBannerUseCase();
  canDisplayPushNotificationsCardUseCase =
      MockCanDisplayPushNotificationsCardUseCase();
  saveUserInteractionUseCase = SaveUserInteractionUseCase(
    userInteractionsRepository,
    canDisplaySurveyBannerUseCase,
    canDisplayPushNotificationsCardUseCase,
  );

  final initialUserInteractions = UserInteractions.initial();

  late UserInteractions updatedUserInteractions;

  setUp(
    () {
      when(userInteractionsRepository.userInteractions)
          .thenReturn(initialUserInteractions);
    },
  );

  group(
    'canDisplaySurveyBanner returns false',
    () {
      useCaseTest(
        'WHEN use case called THEN dont expect any interactions with userInteractions repository',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => false);
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.cardScrolled],
        verify: (_) {
          verifyZeroInteractions(userInteractionsRepository);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );

  group(
    'canDisplaySurveyBanner returns true',
    () {
      useCaseTest(
        'WHEN a card has been scrolled THEN increment the related value in the user interactions object',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrolls: initialUserInteractions.numberOfScrolls + 1,
          );
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.cardScrolled],
        verify: (_) {
          verifyInOrder(
            [
              userInteractionsRepository.userInteractions,
              userInteractionsRepository.save(updatedUserInteractions),
            ],
          );
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN an article has been bookmarked THEN increment the related value in the user interactions object',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfArticlesBookmarked:
                initialUserInteractions.numberOfArticlesBookmarked + 1,
          );
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.bookmarkedArticle],
        verify: (_) {
          verifyInOrder(
            [
              userInteractionsRepository.userInteractions,
              userInteractionsRepository.save(updatedUserInteractions),
            ],
          );
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN an article has been liked/disliked THEN increment the related value in the user interactions object',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfArticlesLikedOrDisliked:
                initialUserInteractions.numberOfArticlesLikedOrDisliked + 1,
          );
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.likeOrDislikedArticle],
        verify: (_) {
          verifyInOrder(
            [
              userInteractionsRepository.userInteractions,
              userInteractionsRepository.save(updatedUserInteractions),
            ],
          );
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN an article has been read THEN increment the related value in the user interactions object',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfArticlesRead:
                initialUserInteractions.numberOfArticlesRead + 1,
          );
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.readArticle],
        verify: (_) {
          verifyInOrder(
            [
              userInteractionsRepository.userInteractions,
              userInteractionsRepository.save(updatedUserInteractions),
            ],
          );
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN a search has been executed THEN increment the related value in the user interactions object',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfSearches: initialUserInteractions.numberOfSearches + 1,
          );
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.searchExecuted],
        verify: (_) {
          verifyInOrder(
            [
              userInteractionsRepository.userInteractions,
              userInteractionsRepository.save(updatedUserInteractions),
            ],
          );
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN a country has been changed THEN increment the related value in the user interactions object',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfCountriesChanged:
                initialUserInteractions.numberOfCountriesChanged + 1,
          );
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.changedCountry],
        verify: (_) {
          verifyInOrder(
            [
              userInteractionsRepository.userInteractions,
              userInteractionsRepository.save(updatedUserInteractions),
            ],
          );
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN a source has been excluded THEN increment the related value in the user interactions object',
        setUp: () {
          when(canDisplaySurveyBannerUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfSourcesExcluded:
                initialUserInteractions.numberOfSourcesExcluded + 1,
          );
        },
        build: () => saveUserInteractionUseCase,
        input: [UserInteractionsEvents.excludedSource],
        verify: (_) {
          verifyInOrder(
            [
              userInteractionsRepository.userInteractions,
              userInteractionsRepository.save(updatedUserInteractions),
            ],
          );
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );
}

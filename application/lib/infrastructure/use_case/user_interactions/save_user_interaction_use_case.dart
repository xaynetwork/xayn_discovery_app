import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/survey_banner/is_survey_banner_feature_active_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/user_interactions_events.dart';

import '../../../domain/model/user_interactions/user_interactions.dart';

@injectable
class SaveUserInteractionUseCase extends UseCase<UserInteractionsEvents, None> {
  final UserInteractionsRepository _userInteractionsRepository;
  final IsSurveyBannerFeatureActiveUseCase _isSurveyBannerFeatureActiveUseCase;

  SaveUserInteractionUseCase(
    this._userInteractionsRepository,
    this._isSurveyBannerFeatureActiveUseCase,
  );

  @override
  Stream<None> transaction(UserInteractionsEvents param) async* {
    final isSurveyBannerFeatureEnabled =
        await _isSurveyBannerFeatureActiveUseCase.singleOutput(none);
    if (isSurveyBannerFeatureEnabled) {
      switch (param) {
        case UserInteractionsEvents.cardScrolled:
          _onScrollingEvent();
          break;
        case UserInteractionsEvents.readArticle:
          _onReadArticleEvent();
          break;
        case UserInteractionsEvents.bookmarkedArticle:
          _onBookmarkedArticleEvent();
          break;
        case UserInteractionsEvents.likeOrDislikedArticle:
          _onLikeOrDislikedArticleEvent();
          break;
        case UserInteractionsEvents.excludedSource:
          _onExcludedSource();
          break;
        case UserInteractionsEvents.changedCountry:
          _onChangedCountryEvent();
          break;
        case UserInteractionsEvents.searchExecuted:
          _onSearchExecutedEvent();
          break;
      }
    }

    yield none;
  }

  void _onScrollingEvent() {
    final updatedNumberOfScrolls =
        _getCurrentUserInteractions.numberOfScrolls + 1;
    final updatedUserInteractions = _getCurrentUserInteractions.copyWith(
        numberOfScrolls: updatedNumberOfScrolls);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onReadArticleEvent() {
    final updatedNumberOfArticlesRead =
        _getCurrentUserInteractions.numberOfArticlesRead + 1;
    final updatedUserInteractions = _getCurrentUserInteractions.copyWith(
        numberOfArticlesRead: updatedNumberOfArticlesRead);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onBookmarkedArticleEvent() {
    final updatedNumberOfArticlesBookmarked =
        _getCurrentUserInteractions.numberOfArticlesBookmarked + 1;
    final updatedUserInteractions = _getCurrentUserInteractions.copyWith(
        numberOfArticlesBookmarked: updatedNumberOfArticlesBookmarked);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onLikeOrDislikedArticleEvent() {
    final updatedNumberOfArticlesLikedOrDisliked =
        _getCurrentUserInteractions.numberOfArticlesLikedOrDisliked + 1;
    final updatedUserInteractions = _getCurrentUserInteractions.copyWith(
        numberOfArticlesLikedOrDisliked:
            updatedNumberOfArticlesLikedOrDisliked);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onExcludedSource() {
    final updatedNumberOfSourcesExcluded =
        _getCurrentUserInteractions.numberOfSourcesExcluded + 1;
    final updatedUserInteractions = _getCurrentUserInteractions.copyWith(
        numberOfSourcesExcluded: updatedNumberOfSourcesExcluded);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onChangedCountryEvent() {
    final updatedNumberOfCountriesChanged =
        _getCurrentUserInteractions.numberOfCountriesChanged + 1;
    final updatedUserInteractions = _getCurrentUserInteractions.copyWith(
        numberOfCountriesChanged: updatedNumberOfCountriesChanged);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onSearchExecutedEvent() {
    final updatedNumberOfSearches =
        _getCurrentUserInteractions.numberOfSearches + 1;
    final updatedUserInteractions = _getCurrentUserInteractions.copyWith(
        numberOfSearches: updatedNumberOfSearches);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  UserInteractions get _getCurrentUserInteractions =>
      _userInteractionsRepository.userInteractions;
}

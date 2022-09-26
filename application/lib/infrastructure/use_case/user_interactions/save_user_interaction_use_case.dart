import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions_events.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/can_display_inline_cards.dart';

import '../../../domain/model/user_interactions/user_interactions.dart';

@injectable
class SaveUserInteractionUseCase extends UseCase<UserInteractionsEvents, None> {
  final UserInteractionsRepository _userInteractionsRepository;
  final CanDisplayInLineCardsUseCase _canDisplayInLineCardsUseCase;
  late UserInteractions _userInteractions;

  SaveUserInteractionUseCase(
      this._userInteractionsRepository, this._canDisplayInLineCardsUseCase);

  @override
  Stream<None> transaction(UserInteractionsEvents param) async* {
    final canDisplayInLineCardsUseCase =
        await _canDisplayInLineCardsUseCase.singleOutput(none);

    if (canDisplayInLineCardsUseCase) {
      _userInteractions = _userInteractionsRepository.userInteractions;
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
        case UserInteractionsEvents.removeExcludedSource:
          _onRemoveExcludedSource();
          break;
        case UserInteractionsEvents.removeTrustedSource:
          _onRemoveTrustedSource();
          break;
        case UserInteractionsEvents.trustedSource:
          _onTrustedSource();
          break;
      }
    }

    yield none;
  }

  void _onScrollingEvent() {
    final updatedNumberOfScrolls = _userInteractions.numberOfScrolls + 1;
    final updatedNumberOfScrollsPerSession =
        _userInteractions.numberOfScrollsPerSession + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
      numberOfScrolls: updatedNumberOfScrolls,
      numberOfScrollsPerSession: updatedNumberOfScrollsPerSession,
    );
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onReadArticleEvent() {
    final updatedNumberOfArticlesRead =
        _userInteractions.numberOfArticlesRead + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfArticlesRead: updatedNumberOfArticlesRead);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onBookmarkedArticleEvent() {
    final updatedNumberOfArticlesBookmarked =
        _userInteractions.numberOfArticlesBookmarked + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfArticlesBookmarked: updatedNumberOfArticlesBookmarked);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onLikeOrDislikedArticleEvent() {
    final updatedNumberOfArticlesLikedOrDisliked =
        _userInteractions.numberOfArticlesLikedOrDisliked + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfArticlesLikedOrDisliked:
            updatedNumberOfArticlesLikedOrDisliked);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onExcludedSource() {
    final updatedNumberOfSourcesExcluded =
        _userInteractions.numberOfSourcesExcluded + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfSourcesExcluded: updatedNumberOfSourcesExcluded);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onChangedCountryEvent() {
    final updatedNumberOfCountriesChanged =
        _userInteractions.numberOfCountriesChanged + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfCountriesChanged: updatedNumberOfCountriesChanged);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onSearchExecutedEvent() {
    final updatedNumberOfSearches = _userInteractions.numberOfSearches + 1;
    final updatedUserInteractions =
        _userInteractions.copyWith(numberOfSearches: updatedNumberOfSearches);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onRemoveExcludedSource() {
    final updatedNumberOfSourcesExcluded =
        _userInteractions.numberOfSourcesExcluded - 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfSourcesExcluded: updatedNumberOfSourcesExcluded);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onTrustedSource() {
    final updatedNumberOfSourcesTrusted =
        _userInteractions.numberOfSourcesTrusted + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfSourcesTrusted: updatedNumberOfSourcesTrusted);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onRemoveTrustedSource() {
    final updatedNumberOfSourcesTrusted =
        _userInteractions.numberOfSourcesTrusted - 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfSourcesTrusted: updatedNumberOfSourcesTrusted);
    _userInteractionsRepository.save(updatedUserInteractions);
  }
}

import 'package:injectable/injectable.dart';

abstract class FeedSettingsNavActions {
  void onBackNavPressed();
}

@injectable
class FeedSettingsManager implements FeedSettingsNavActions {
  FeedSettingsManager(this._navActions);

  final FeedSettingsNavActions _navActions;

  @override
  void onBackNavPressed() => _navActions.onBackNavPressed();
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

@freezed

/// Hold session information,
/// Currently, this is limited to the detection of the app startup ([feedBatchRequestCount]),
/// feel free to extend this class when needed.
class Session with _$Session {
  factory Session._({
    // indicates if the news feed was requested already once, in the apps ongoing session.
    required bool didRequestFeed,
  }) = _Session;

  factory Session.start() => Session._(didRequestFeed: false);

  @visibleForTesting
  factory Session.withFeedRequested() => Session._(didRequestFeed: true);
}

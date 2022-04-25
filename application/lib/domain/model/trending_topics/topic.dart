import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';

@freezed

/// Hold session information,
/// Currently, this is limited to the detection of the app startup ([feedBatchRequestCount]),
/// feel free to extend this class when needed.
class Topic with _$Topic {
  factory Topic({
    required String name,
    required Uri image,
    required String query,
  }) = _Topic;

  @override
  String toString() => {
        'name': name,
        'image': image.toString(),
        'query': query,
      }.toString();
}

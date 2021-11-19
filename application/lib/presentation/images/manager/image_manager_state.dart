import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_manager_state.freezed.dart';

@freezed
class ImageManagerState with _$ImageManagerState {
  const ImageManagerState._();

  const factory ImageManagerState({
    Uri? uri,
    @Default(.0) double progress,
    Uint8List? bytes,
    @Default(false) bool hasError,
  }) = _ImageManagerState;

  factory ImageManagerState.initial() => const ImageManagerState();

  factory ImageManagerState.progress({
    required Uri uri,
    required double progress,
  }) =>
      ImageManagerState(
        uri: uri,
        progress: progress,
      );

  factory ImageManagerState.completed({
    required Uri uri,
    required Uint8List bytes,
  }) =>
      ImageManagerState(
        uri: uri,
        progress: 1.0,
        bytes: bytes,
      );

  factory ImageManagerState.error({
    required Uri uri,
  }) =>
      ImageManagerState(
        uri: uri,
        hasError: true,
      );
}

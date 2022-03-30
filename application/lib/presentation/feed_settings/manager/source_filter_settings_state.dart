import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';

part 'source_filter_settings_state.freezed.dart';

@freezed
class SourceFilterSettingsState with _$SourceFilterSettingsState {
  const factory SourceFilterSettingsState({
    @Default({}) Map<DocumentFilter, bool> filters,
    @Default(ErrorObject()) ErrorObject error,
  }) = _SourceFilterSettingsState;
}
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discovery_engine_report_state.freezed.dart';

@freezed
class DiscoveryEngineReportState with _$DiscoveryEngineReportState {
  const DiscoveryEngineReportState._();

  const factory DiscoveryEngineReportState({
    required List<String> inputEvents,
    required List<String> outputEvents,
  }) = _DiscoveryEngineReportState;

  factory DiscoveryEngineReportState.initial() =>
      const DiscoveryEngineReportState(
        inputEvents: ['INPUT'],
        outputEvents: ['OUTPUT'],
      );
}

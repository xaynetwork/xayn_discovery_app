import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/custom_card/custom_card_injection_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/custom_card_manager_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class CustomCardManager extends Cubit<CustomCardManagerState>
    with UseCaseBlocHelper<CustomCardManagerState> {
  final CustomCardInjectionUseCase _customCardInjectionUseCase;
  late final UseCaseSink<Set<Document>, Set<Card>> _customCardInjectionSink =
      pipe(_customCardInjectionUseCase);

  CustomCardManager(this._customCardInjectionUseCase)
      : super(const CustomCardManagerState({}));

  void updateListing(Set<Document> data) => _customCardInjectionSink(data);

  @override
  Future<CustomCardManagerState> computeState() async =>
      fold(_customCardInjectionSink).foldAll(
          (cards, errorReport) => CustomCardManagerState(cards ?? const {}));
}

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';

@lazySingleton
class HapticFeedbackMediumUseCase extends UseCase<None, None> {
  @override
  Stream<None> transaction(None param) async* {
    HapticFeedback.mediumImpact();
    yield none;
  }
}

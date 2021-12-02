import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

abstract class DialogController {
  void showReportBug({
    required VoidCallback onReportPressed,
    required VoidCallback onCancelPressed,
  });
}

@Injectable(as: DialogController)
class DialogControllerImpl implements DialogController {
  @override
  void showReportBug({
    required VoidCallback onReportPressed,
    required VoidCallback onCancelPressed,
  }) async {
    Future.delayed(const Duration(seconds: 2))
        .then((value) => onReportPressed());
  }
}

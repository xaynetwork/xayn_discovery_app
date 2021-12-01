import 'package:instabug_flutter/Instabug.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

class ReportABugUseCase {
  static init() {
    /// This method is called for iOS only
    /// For Android, Instabug is initialized from [CustomFlutterApplication.java]
    Instabug.start(Env.instabugToken, [InvocationEvent.none]);
  }

  static showDialog() => Instabug.show();
}

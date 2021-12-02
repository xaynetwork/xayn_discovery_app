import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:instabug_flutter/Instabug.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

const kInstabugAndroidMethodChannel = 'instabug_android';
const kInstabugAndroidStartMethod = 'startInstabug';
const kInstabugTokenParam = 'token';
const kInstabugInvocationEventParam = 'invocationEvents';

@lazySingleton
class BugReportingService {
  BugReportingService() {
    _init();
  }

  _init() {
    final token = Env.instabugToken;
    final invocationEvents = [InvocationEvent.none];

    if (SafePlatform.isAndroid) {
      _initAndroid(token, invocationEvents);
    } else {
      _initiOS(token, invocationEvents);
    }

    Instabug.setWelcomeMessageMode(WelcomeMessageMode.disabled);
  }

  /// Since we are not using Crash Analytics from Instabug, there is no reason
  /// to start instabug in onCreate method for the Android Application as
  /// stated in their documentation.
  ///
  /// Invoking a channel method async is much preferred since we can easily pass
  /// the token and won't need to pass from BuildConfig
  _initAndroid(
    String token,
    List<InvocationEvent> invocationEvents,
  ) async {
    const MethodChannel _channel = MethodChannel(kInstabugAndroidMethodChannel);
    final List<String> invocationEventsStrings =
        invocationEvents.map((e) => e.toString()).toList(growable: false);
    final params = {
      kInstabugTokenParam: token,
      kInstabugInvocationEventParam: invocationEventsStrings
    };
    await _channel.invokeMethod<Object>(kInstabugAndroidStartMethod, params);
  }

  _initiOS(
    String token,
    List<InvocationEvent> invocationEvents,
  ) =>
      Instabug.start(token, invocationEvents);

  showDialog() => Instabug.show();
}

import 'package:flutter/services.dart';
import 'package:instabug_flutter/Instabug.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

const kInstabugAndroidMethodChannel = 'instabug_android';
const kInstabugAndroidStartMethod = 'startInstabug';
const kInstabugTokenParam = 'token';
const kInstabugInvocationEventParam = 'invocationEvents';

class ReportABugUseCase {
  static init() {
    final token = Env.instabugToken;
    final invocationEvents = [InvocationEvent.none];

    if (SafePlatform.isAndroid) {
      _initAndroidWithoutCrashReporting(token, invocationEvents);
    } else {
      _initiOS(token, invocationEvents);
    }

    Instabug.setWelcomeMessageMode(WelcomeMessageMode.disabled);
  }

  static _initAndroidWithoutCrashReporting(
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

  static _initiOS(
    String token,
    List<InvocationEvent> invocationEvents,
  ) =>
      Instabug.start(token, invocationEvents);

  static showDialog() => Instabug.show();
}

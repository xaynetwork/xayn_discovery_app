import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:instabug_flutter/Instabug.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

const kInstabugAndroidMethodChannel = 'instabug_android';
const kInstabugAndroidStartMethod = 'startInstabug';
const kInstabugTokenParamName = 'token';
const kInstabugInvocationEventsParamName = 'invocationEvents';
const kInstabugToken = Env.instabugToken;
const kInstabugInvocationEvents = [InvocationEvent.none];

@lazySingleton
class BugReportingService {
  BugReportingService() {
    _init();
  }

  _init() {
    if (Platform.isAndroid) {
      _initAndroid(kInstabugToken, kInstabugInvocationEvents);
    } else {
      _initiOS(kInstabugToken, kInstabugInvocationEvents);
    }

    Instabug.setWelcomeMessageMode(WelcomeMessageMode.disabled);
    Instabug.setSdkDebugLogsLevel(IBGSDKDebugLogsLevel.error);
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
      kInstabugTokenParamName: token,
      kInstabugInvocationEventsParamName: invocationEventsStrings
    };
    await _channel.invokeMethod<Object>(kInstabugAndroidStartMethod, params);
  }

  _initiOS(
    String token,
    List<InvocationEvent> invocationEvents,
  ) =>
      Instabug.start(token, invocationEvents);

  void showDialog({
    Brightness? brightness,
    Color? primaryColor,
  }) {
    if (brightness != null) Instabug.setColorTheme(_getTheme(brightness));
    if (primaryColor != null) Instabug.setPrimaryColor(primaryColor);
    Instabug.show();
  }

  ColorTheme _getTheme(Brightness brightness) =>
      brightness == Brightness.dark ? ColorTheme.dark : ColorTheme.light;
}

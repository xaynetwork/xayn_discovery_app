import 'dart:io';
import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:instabug_flutter/CrashReporting.dart';
import 'package:instabug_flutter/Instabug.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

const kInstabugAndroidMethodChannel = 'instabug_android';
const kInstabugAndroidStartMethod = 'startInstabug';
const kInstabugTokenParamName = 'token';
const kInstabugInvocationEventsParamName = 'invocationEvents';
const kInstabugToken = Env.instabugToken;
const kInstabugInvocationEvents = [InvocationEvent.none];

@lazySingleton
class BugReportingService {
  BugReportingService(AppStatusRepository appStatusRepository) {
    _init(userId: appStatusRepository.appStatus.userId.value);
  }

  void _init({required String userId}) {
    Instabug.setUserAttribute(userId, 'userId');
    //init method for Andriod is called natively from CustomFlutterApplication class
    if (Platform.isIOS) {
      _initiOS(kInstabugToken, kInstabugInvocationEvents);
      Instabug.setWelcomeMessageMode(WelcomeMessageMode.disabled);
    }
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

  void reportCrash(Object error, StackTrace stackTrace) =>
      CrashReporting.reportCrash(error, stackTrace);

  void reportHandledCrash(
    dynamic exception, [
    StackTrace? stack,
  ]) =>
      CrashReporting.reportHandledCrash(exception, stack);
}

import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:instabug_flutter/BugReporting.dart';
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
const kUserIdAttributeKey = 'USER_ID';

@lazySingleton
class BugReportingService {
  BugReportingService(AppStatusRepository appStatusRepository) {
    _init(userId: appStatusRepository.appStatus.userId.value);
  }

  void _init({required String userId}) {
    Instabug.start(kInstabugToken, kInstabugInvocationEvents);
    Instabug.setWelcomeMessageMode(WelcomeMessageMode.disabled);
    Instabug.setUserAttribute(userId, kUserIdAttributeKey);
    Instabug.setUserData(userId);
    BugReporting.setInvocationOptions([InvocationOption.emailFieldOptional]);
  }

  void reportBug({
    Brightness? brightness,
    Color? primaryColor,
  }) {
    _setInstabugStyle(brightness, primaryColor);
    BugReporting.show(
      ReportType.bug,
      [InvocationOption.emailFieldOptional],
    );
  }

  void giveFeedback({
    Brightness? brightness,
    Color? primaryColor,
  }) {
    _setInstabugStyle(brightness, primaryColor);
    BugReporting.show(
      ReportType.feedback,
      [InvocationOption.emailFieldOptional],
    );
  }

  void _setInstabugStyle(Brightness? brightness, Color? primaryColor) {
    if (brightness != null) Instabug.setColorTheme(_getTheme(brightness));
    if (primaryColor != null) Instabug.setPrimaryColor(primaryColor);
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

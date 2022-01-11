import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_de.i18n.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:yaml/yaml.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {});

  tearDown(() {
    Strings.reset();
  });

  test('When not initializing Strings default translation is used.', () {
    expect(R.strings.runtimeType, Translations);
  });

  test('When not initialized the default language is English.', () {
    expect(R.strings.settingsAboutXayn, 'About Xayn');
  });

  test('When switching a language the new translations is available.', () {
    final stringDefault = strings.settingsImprint;

    Strings.switchTranslations(
      AppLanguage.german,
    );

    expect(stringDefault, 'Imprint');
    expect(strings.settingsImprint, 'Impressum');
    expect(strings.runtimeType, TranslationsDe);
  });

  group('Translation Linter:', () {
    test('Translation contains unused entries', () async {
      var paths = {
        normalizePath(
            'lib/presentation/constants/translations/translations_de.i18n.yaml'),
      };

      var testFailed = false;
      for (var element in paths) {
        testFailed =
            await _checkIfPathContainsOnlyElementsFromOriginal(element);
      }

      // Just informative check if we have all translations
      for (var element in paths) {
        await _checkIfPathHasCompleteTranslations(element);
      }

      expect(testFailed, false,
          reason:
              'Some translations files contain elements that are not used anymore.');
    });
  });
}

Future<bool> _checkIfPathContainsOnlyElementsFromOriginal(String path) async {
  var originalPath = normalizePath(
      'lib/presentation/constants/translations/translations.i18n.yaml');
  final original = loadYaml(await File(originalPath).readAsString()) as YamlMap;
  final de = loadYaml(await File(path).readAsString()) as YamlMap;
  final originalKeysSet = original.keys.toSet();
  final otherKeysSet = de.keys.toSet();
  var testFailed = false;
  for (var element in otherKeysSet) {
    if (!originalKeysSet.contains(element)) {
      logger.e(
          'error - $path : Has "$element" that does not exist in base translation, please remove it');
      testFailed = true;
    }
  }

  return testFailed;
}

Future<bool> _checkIfPathHasCompleteTranslations(String path) async {
  var originalPath = normalizePath(
      'lib/presentation/constants/translations/translations.i18n.yaml');
  final original = loadYaml(await File(originalPath).readAsString()) as YamlMap;
  final de = loadYaml(await File(path).readAsString()) as YamlMap;
  final originalKeysSet = original.keys.toSet();
  final otherKeysSet = de.keys.toSet();
  var testFailed = false;

  for (var element in originalKeysSet) {
    if (!otherKeysSet.contains(element)) {
      logger.w('warning - $path : "$element" is not yet translated.');
      testFailed = true;
    }
  }

  return testFailed;
}

String normalizePath(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  return '$dir/$name';
}

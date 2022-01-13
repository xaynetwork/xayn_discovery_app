import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';

void main() {
  test('Country names should load localized names of countries', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final namesDe = await AppLanguage.german.countryNames;
    final namesEn = await AppLanguage.english.countryNames;

    expect(namesDe["FR"], "Frankreich");
    expect(namesEn["FR"], "France");
  });
}

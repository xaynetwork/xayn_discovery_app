import 'package:bloc_test/bloc_test.dart';
import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:dart_remote_config/model/dart_remote_config_state.dart';
import 'package:dart_remote_config/model/experimentation_engine_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/manager/redeem_promo_code_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/manager/redeem_promo_code_state.dart';

import '../../../../test_utils/widget_test_utils.dart';

void main() {
  setUp(() async {
    await setupWidgetTest();
  });

  tearDown(() async => await tearDownWidgetTest());

  RedeemPromoCodeManager manager(
      [String input = """
- appVersion: ">3.46.0 <4.0.0"
  promoCodes:
    # 24*60*60*90 = 7,776,000 // 90 Days
    - code: "ACTIVE"
      grantedSku: "extended_test_period"
      grantedDuration: 7776000
"""]) {
    final configs = const RemoteConfigParser().parse(input);
    di.registerFactory<DartRemoteConfigState>(() =>
        DartRemoteConfigState.success(
            experiments: const ExperimentationEngineResult({}, []),
            config: configs.configs.first));
    di.registerFactory<PackageInfo>(() => PackageInfo(
        appName: '', packageName: '', version: '3.47.0', buildNumber: ''));
    return di.get();
  }

  blocTest<RedeemPromoCodeManager, RedeemPromoCodeState>(
    'Redeeming an active promo code marks it as success',
    build: () => manager(),
    act: (m) => m.redeemPromoCode('ACTIVE'),
    wait: const Duration(),
    skip: 1,
    expect: () => [
      isA<RedeemPromoCodeStateSuccess>(),
    ],
  );

  blocTest<RedeemPromoCodeManager, RedeemPromoCodeState>(
    'Redeeming an promo code is case sensitive',
    build: () => manager(),
    act: (m) => m.redeemPromoCode('active'),
    wait: const Duration(),
    skip: 1,
    expect: () => [
      const RedeemPromoCodeState.error(RedeemPromoCodeError.unknownPromoCode),
    ],
  );

  blocTest<RedeemPromoCodeManager, RedeemPromoCodeState>(
    'After receiving an error, typing will reset it.',
    build: () => manager(),
    act: (m) async {
      m.redeemPromoCode('active');
      await Future.delayed(const Duration());
      m.onPromoCodeTyped('activ');
    },
    wait: const Duration(),
    skip: 1,
    expect: () => [
      const RedeemPromoCodeState.error(RedeemPromoCodeError.unknownPromoCode),
      const RedeemPromoCodeState.initial(),
    ],
  );

  blocTest<RedeemPromoCodeManager, RedeemPromoCodeState>(
    'Redeeming an promo code twice will cause an error',
    build: () => manager(),
    setUp: () {
      final repository = di.get<AppStatusRepository>();
      repository
          .save(repository.appStatus.copyWith(usedPromoCodes: {'ACTIVE'}));
    },
    act: (m) async => m.redeemPromoCode('ACTIVE'),
    wait: const Duration(),
    skip: 1,
    expect: () => [
      const RedeemPromoCodeState.error(
          RedeemPromoCodeError.alreadyUsedPromoCode),
    ],
  );

  blocTest<RedeemPromoCodeManager, RedeemPromoCodeState>(
    'Redeeming an promo that is disabled, fails.',
    build: () => manager("""
- appVersion: ">3.46.0 <4.0.0"
  promoCodes:
    # 24*60*60*90 = 7,776,000 // 90 Days
    - code: "ACTIVE"
      enabled: false
      grantedSku: "extended_test_period"
      grantedDuration: 7776000
"""),
    act: (m) => m.redeemPromoCode('ACTIVE'),
    wait: const Duration(),
    skip: 1,
    expect: () => [
      const RedeemPromoCodeState.error(RedeemPromoCodeError.expiredPromoCode),
    ],
  );

  blocTest<RedeemPromoCodeManager, RedeemPromoCodeState>(
    'Redeeming an promo that is expired, fails.',
    build: () => manager("""
- appVersion: ">3.46.0 <4.0.0"
  promoCodes:
    # 24*60*60*90 = 7,776,000 // 90 Days
    - code: "ACTIVE"
      expiresOn: "2022-06-16 20:20:39"
      grantedSku: "extended_test_period"
      grantedDuration: 7776000
"""),
    act: (m) => m.redeemPromoCode('ACTIVE'),
    wait: const Duration(),
    skip: 1,
    expect: () => [
      const RedeemPromoCodeState.error(RedeemPromoCodeError.expiredPromoCode),
    ],
  );
}

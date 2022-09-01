import 'package:bloc_test/bloc_test.dart';
import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/apply_promo_code_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/redeem_promo_code_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/payment_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/list_item_model.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';

import '../../../test_utils/utils.dart';
import '../../../test_utils/widget_test_utils.dart';

/// on were exercised on real live conditions and not just mock responses. This way a
/// we can avoid to write integration tests, and gaining more stable and better covered
/// unit tests. Also they are more readable.
void main() {
  final collection1 = Collection(id: UniqueId(), name: 'default', index: 0);
  final promoCode = PromoCode(
    code: 'ACTIVE',
    grantedDuration: const Duration(days: 10),
    grantedSku: kExtendedTestPeriodSKU,
  );

  PersonalAreaManager manager(
      [String input = """
- appVersion: ">3.46.0 <4.0.0"
  promoCodes:
    # 24*60*60*90 = 7,776,000 // 90 Days
    - code: "ACTIVE"
      grantedSku: "extended_test_period"
      grantedDuration: 7776000
"""]) {
    di.registerFactory<RemoteConfigFetcher>(
        () => StringRemoteConfigFetcher(input));
    di.registerFactory<PackageInfo>(() => PackageInfo(
        appName: '', packageName: '', version: '3.47.0', buildNumber: ''));
    di.get<CollectionsRepository>().save(collection1);
    return di.get();
  }

  setUp(() async => await setupWidgetTest());

  tearDown(() async => await tearDownWidgetTest());

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'The initial values contains just the contacts',
    build: () => manager(),
    wait: const Duration(),
    expect: () => [
      hasItems([isA<ListItemModelContact>()]),
      hasItems([isA<ListItemModelCollection>(), isA<ListItemModelContact>()])
    ],
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'With payment enabled the initial values contains the trial banner and contacts',
    setUp: () =>
        di.get<FeatureManager>().overrideFeature(Feature.payment, true),
    build: () => manager(),
    wait: const Duration(),
    skip: 1,
    expect: () => [
      hasItems([
        isA<ListItemModelPayment>(),
        isA<ListItemModelCollection>(),
        isA<ListItemModelContact>()
      ])
    ],
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
      'When pressing on the trial banner a bottom sheet1 will be shown.',
      setUp: () =>
          di.get<FeatureManager>().overrideFeature(Feature.payment, true),
      build: () => manager(),
      act: (m) => m.onPaymentTrialBannerPressed(),
      wait: const Duration(),
      skip: 1,
      verify: (m) {
        expect(
            (m.overlayManager.state.first as BottomSheetData)
                .builder
                .runtimeType,
            OverlayData.bottomSheetPayment(
                    onRedeemPressed: () {}, onClosePressed: () {})
                .builder
                .runtimeType);
      });

  blocTest<PersonalAreaManager, PersonalAreaState>(
      'Clicking on redeem in the payment bottom sheet1 opens the alt payment sheet1',
      setUp: () {
        di.get<FeatureManager>().overrideFeature(Feature.payment, true);
        di.get<FeatureManager>().overrideFeature(Feature.altPromoCode, true);
      },
      build: () => manager(),
      act: (m) {
        m.onPaymentTrialBannerPressed();

        /// it is a bit tricky to access a anonymous callback, so we first build the
        /// bottom sheet1 and then access the inner object to find the

        extractBottomSheetBody<PaymentBottomSheetBody>(m, 0).onRedeemPressed!();
      },
      wait: const Duration(),
      skip: 1,
      verify: (m) {
        expect(m.overlayManager.state, [
          hasBuilderType(OverlayData.bottomSheetPayment(
                  onRedeemPressed: () {}, onClosePressed: () {})
              .builder
              .runtimeType),
          hasBuilderType(OverlayData.bottomSheetAlternativePromoCode(
            (code) {},
          ).builder.runtimeType),
        ]);
      });

  blocTest<PersonalAreaManager, PersonalAreaState>(
      'Redeeming a promo code will show the confirmation',
      setUp: () {
        di.get<FeatureManager>().overrideFeature(Feature.payment, true);
        di.get<FeatureManager>().overrideFeature(Feature.altPromoCode, true);
      },
      build: () => manager(),
      act: (m) {
        m.onPaymentTrialBannerPressed();

        extractBottomSheetBody<PaymentBottomSheetBody>(m, 0).onRedeemPressed!();

        extractBottomSheetBody<RedeemPromoCodeBottomSheetBody>(m, 1)
            .onRedeemSuccessful(promoCode);
      },
      wait: const Duration(),
      skip: 1,
      verify: (m) {
        expect(m.overlayManager.state, [
          hasBuilderType(OverlayData.bottomSheetPayment(
                  onRedeemPressed: () {}, onClosePressed: () {})
              .builder
              .runtimeType),
          hasBuilderType(OverlayData.bottomSheetAlternativePromoCode(
            (code) {},
          ).builder.runtimeType),
          hasBuilderType(OverlayData.bottomSheetPromoCodeApplied(promoCode)
              .builder
              .runtimeType),
        ]);
      });
}

T extractBottomSheetBody<T>(PersonalAreaManager m, int index) {
  return (m.overlayManager.state[index] as BottomSheetData)
      .builder(MockBuildContext(), null)
      .body as T;
}

hasBuilderType(matcher) => HasFeature<dynamic>(matcher, 'dynamic',
    'builder.runtimeType', (object) => object.builder.runtimeType);

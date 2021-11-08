// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:xayn_architecture/concepts/use_case.dart' as _i7;

import '../../domain/use_case/discovery_feed/discovery_feed.dart' as _i8;
import '../../presentation/discovery_card/manager/discovery_card_manager.dart'
    as _i11;
import '../../presentation/discovery_engine_mock/manager/discovery_engine_manager.dart'
    as _i13;
import '../../presentation/discovery_feed/manager/discovery_feed_manager.dart'
    as _i15;
import '../use_case/discovery_engine/discovery_engine_results_use_case.dart'
    as _i14;
import '../use_case/discovery_feed/bing_call_endpoint_use_case.dart' as _i9;
import '../use_case/discovery_feed/bing_request_builder_use_case.dart' as _i10;
import '../use_case/image_processing/image_palette_use_case.dart' as _i4;
import '../use_case/reader_mode/extract_elements_use_case.dart' as _i3;
import '../use_case/reader_mode/load_html_use_case.dart' as _i5;
import '../use_case/reader_mode/readability_use_case.dart' as _i6;
import '../use_case/reader_mode/reader_mode.dart'
    as _i12; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.factory<_i3.ExtractElementsUseCase<dynamic>>(
      () => _i3.ExtractElementsUseCase<dynamic>());
  gh.factory<_i4.ImagePaletteUseCase<dynamic>>(
      () => _i4.ImagePaletteUseCase<dynamic>());
  gh.factory<_i5.LoadHtmlUseCase<dynamic>>(
      () => _i5.LoadHtmlUseCase<dynamic>());
  gh.factory<_i6.ReadabilityUseCase<dynamic>>(
      () => _i6.ReadabilityUseCase<dynamic>());
  gh.factory<_i7.UseCase<Uri, _i8.ApiEndpointResponse>>(
      () => _i9.InvokeBingUseCase<dynamic>());
  gh.factory<_i7.UseCase<String, Uri>>(
      () => _i10.CreateBingRequestUseCase<dynamic>());
  gh.factory<_i11.DiscoveryCardManager>(() => _i11.DiscoveryCardManager(
      get<_i12.LoadHtmlUseCase<dynamic>>(),
      get<_i12.ReadabilityUseCase<dynamic>>(),
      get<_i12.ExtractElementsUseCase<dynamic>>(),
      get<_i4.ImagePaletteUseCase<dynamic>>()));
  gh.singleton<_i13.DiscoveryEngineManager>(_i13.DiscoveryEngineManager(
      get<_i7.UseCase<String, Uri>>(),
      get<_i7.UseCase<Uri, _i8.ApiEndpointResponse>>()));
  gh.factory<_i14.DiscoveryEngineResultsUseCase>(() =>
      _i14.DiscoveryEngineResultsUseCase(get<_i13.DiscoveryEngineManager>()));
  gh.factory<_i15.DiscoveryFeedManager>(() =>
      _i15.DiscoveryFeedManager(get<_i14.DiscoveryEngineResultsUseCase>()));
  return get;
}

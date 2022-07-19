import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

@lazySingleton
class Start {
  final startAppSdk = StartAppSdk();
//..setTestAdsEnabled(true);
}

class AdCard extends StatefulWidget {
  final VoidCallback onPressed;

  const AdCard({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<AdCard> createState() => _AdCardState();
}

const double _kNoImageSize = 400.0;

class _AdCardState extends State<AdCard> {
  late final ShaderBuilder primaryCardShader =
      ShaderFactory.fromType(ShaderType.static);

  late final startAppSdk = di.get<Start>().startAppSdk;
  StartAppNativeAd? _nativeAd;

  void loadAd() => startAppSdk
          .loadNativeAd(
              prefs: const StartAppAdPreferences(
                  // somehow this is ignored
                  // desiredWidth: R.dimen.screenSize.width.floor(),
                  // desiredHeight: R.dimen.screenSize.height.floor(),
                  ))
          .then((ad) {
        setState(() {
          _nativeAd = ad;
        });
      }).onError<StartAppException>((ex, stackTrace) {
        debugPrint("Error loading Native ad: ${ex.message}");
      }).onError((error, stackTrace) {
        debugPrint("Error loading Native ad: $error");
      });

  @override
  void initState() {
    super.initState();

    loadAd();
  }

  String? get imageUrl => (_nativeAd?.imageUrl?.isNotEmpty == true
          ? _nativeAd?.imageUrl
          : _nativeAd?.secondaryImageUrl)
      ?.replaceAll('_150', '_${R.dimen.screenSize.width.floor()}');

  @override
  Widget build(BuildContext context) {
    if (_nativeAd == null) {
      return const Center(
        child: Text('No Ad'),
      );
    }

    final nativeAd = _nativeAd!;
    return StartAppNative(
        nativeAd, (context, setState, nativeAd) => _buildContent(nativeAd));
  }

  Stack _buildContent(StartAppNativeAd nativeAd) {
    final content = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit4,
          vertical: R.dimen.unit6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: R.dimen.unit2),
            Text(
              nativeAd.title!,
              textAlign: TextAlign.center,
              style: R.styles.xlBoldStyle.copyWith(color: R.colors.brightText),
            ),
            SizedBox(height: R.dimen.unit2),
            Text(
              nativeAd.description ?? '',
              textAlign: TextAlign.center,
              style: R.styles.mStyle.copyWith(color: R.colors.brightText),
            ),
            SizedBox(height: R.dimen.unit2_5),
            _buildCTAButton(text: nativeAd.callToAction!),
            Text(
              'Sponsored',
              textAlign: TextAlign.center,
              style: R.styles.sStyle.copyWith(color: R.colors.brightText),
            ),
          ],
        ));

    return Stack(children: [
      buildImage(R.colors.swipeCardBackgroundDefault),
      content,
    ]);
  }

  Widget _buildCTAButton({required String text}) => SizedBox(
        width: double.maxFinite,
        child: AppRaisedButton.text(
          text: text,
          onPressed: loadAd,
        ),
      );

  Widget buildImage(Color shadowColor) {
    // allow opaque-when-loading, because the card will fade in on load completion.
    buildBackgroundPane({required bool opaque}) =>
        Container(color: opaque ? null : R.colors.swipeCardBackgroundHome);

    getDeterministicNoImage() {
      final deterministicRandom = imageUrl.hashCode % 4;
      // position the animation at 1/3 from the top of the card
      // this is translated by taking the height divided by 3, and then
      // subtracting half of the animation's height
      final topOffset = R.dimen.screenSize.height / 3 - _kNoImageSize / 2;
      late String assetName;
      late Color background;

      switch (deterministicRandom) {
        case 0:
          background = R.colors.noImageBackgroundGreen;
          assetName = R.assets.lottie.contextual.noImageA;
          break;
        case 1:
          background = R.colors.noImageBackgroundPink;
          assetName = R.assets.lottie.contextual.noImageB;
          break;
        case 2:
          background = R.colors.noImageBackgroundPurple;
          assetName = R.assets.lottie.contextual.noImageC;
          break;
        default:
          background = R.colors.noImageBackgroundOrange;
          assetName = R.assets.lottie.contextual.noImageD;
          break;
      }

      return Container(
        alignment: Alignment.topCenter,
        color: background,
        child: Padding(
          padding: EdgeInsets.only(
            // needs to be a double between [.0 and maxFinite]
            // if < 0 then we just use zero
            top: topOffset.clamp(.0, double.maxFinite),
          ),
          child: AnimationPlayer.assetUnrestrictedSize(
            assetName,
            playsFromStart: false,
          ),
        ),
      );
    }

    if (imageUrl == null) return getDeterministicNoImage();

    return CachedImage(
      singleFrameOnly: false,
      uri: Uri.parse(imageUrl!),
      width: R.dimen.screenSize.width.floor(),
      height: R.dimen.screenSize.height.floor(),
      shadowColor: shadowColor,
      loadingBuilder: (_, __) => buildBackgroundPane(opaque: true),
      errorBuilder: (_) => buildBackgroundPane(opaque: false),
      noImageBuilder: (_) => getDeterministicNoImage(),
    );
  }
}

String? cutString(String? input, int length) {
  if (input != null && input.length > length) {
    return '${input.substring(0, length)}...';
  }

  return input;
}

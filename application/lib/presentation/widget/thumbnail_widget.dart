import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.child,
    this.borderRadius,
  }) : super(key: key);
  final Widget child;
  final BorderRadius? borderRadius;

  Thumbnail.icon(
    IconData icon, {
    Key? key,
    Color? iconColor,
    this.borderRadius,
  })  : child = Icon(
          icon,
          color: iconColor ?? R.colors.icon,
          size: R.dimen.iconSize,
        ),
        super(key: key);

  Thumbnail.networkImage(
    String src, {
    Key? key,
    double? width,
    double? height,
    ImageErrorWidgetBuilder? errorWidgetBuilder,
    this.borderRadius,
  })  : child = FadeInImage.memoryNetwork(
          image: src,
          placeholder: _kTransparentPixel,
          width: width ?? R.dimen.unit3,
          height: height ?? R.dimen.unit3,
          imageErrorBuilder: errorWidgetBuilder,
        ),
        super(key: key);

  Thumbnail.memoryImage(
    Uint8List src, {
    Key? key,
    double? width,
    double? height,
    this.borderRadius,
  })  : child = Image.memory(
          src,
          width: width ?? R.dimen.unit3,
          height: height ?? R.dimen.unit3,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        super(key: key);

  Thumbnail.assetImage(
    String src, {
    Key? key,
    double? width,
    double? height,
    Color? color,
    Color? backgroundColor,
    this.borderRadius,
  })  : child = ColoredBox(
          color: backgroundColor ?? R.colors.imageBackground,
          child: SvgPicture.asset(
            src,
            width: width ?? R.dimen.unit3,
            height: height ?? R.dimen.unit3,
            color: color,
            fit: BoxFit.contain,
          ),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(R.dimen.unit0_5),
      child: child,
    );
  }
}

Widget buildThumbnailFromFaviconHost(String host) {
  var defaultThumbnail = Thumbnail.assetImage(
      R.assets.graphics.formsEmptyCollection,
      backgroundColor: R.colors.collectionsScreenCard);

  final image = Image.network(
    'https://$host/favicon.ico',
    width: R.dimen.unit3,
    height: R.dimen.unit3,
    errorBuilder: (context, _, __) => defaultThumbnail,
    loadingBuilder: (_, image, progress) =>
        progress == null ? image : defaultThumbnail,
  );
  return ClipRRect(
    borderRadius: R.styles.roundBorder0_5,
    child: image,
  );
}

final Uint8List _kTransparentPixel = Uint8List.fromList(
  const [
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1f,
    0x15,
    0xc4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0xda,
    0x63,
    0xfc,
    0xcf,
    0xf0,
    0xbf,
    0x1e,
    0x00,
    0x06,
    0x83,
    0x02,
    0x7f,
    0x94,
    0xad,
    0xd0,
    0xeb,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4e,
    0x44,
    0xae,
    0x42,
    0x60,
    0x82,
  ],
);

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
    this.borderRadius,
  })  : child = Image.network(
          src,
          width: width ?? R.dimen.unit3,
          height: height ?? R.dimen.unit3,
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

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

@injectable
class ShareUriUseCase extends UseCase<Uri, Uri> {
  @override
  Stream<Uri> transaction(Uri param) async* {
    final url = param.toString();
    const ipadPosition = Rect.fromLTWH(0, 0, 100, 100);
    Share.share(url, sharePositionOrigin: ipadPosition);
    yield param;
  }
}

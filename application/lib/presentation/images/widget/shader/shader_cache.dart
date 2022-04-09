import 'dart:ui' as ui;

import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';

@lazySingleton
class ShaderCache {
  final _entries = <Uri, ui.Image>{};
  final _refCount = <Uri, int>{};
  final _animationStatus = <Uri, ShaderAnimationStatus>{};

  bool contains(Uri uri) => _entries.containsKey(uri);
  ui.Image? of(Uri uri) => _entries[uri];

  void refCountFor(Uri uri) {
    final cnt = _refCount.putIfAbsent(uri, () => 0);

    _refCount[uri] = cnt + 1;
  }

  void flush(Uri uri) {
    if (_entries.containsKey(uri)) {
      var cnt = _refCount.putIfAbsent(uri, () => 0);

      cnt = _refCount[uri] = cnt - 1;

      if (cnt > 0) return;

      final entry = _entries[uri]!;

      entry.dispose();

      _entries.remove(uri);
      _animationStatus.remove(uri);
    }
  }

  void put(Uri uri, ui.Image image) => _entries[uri] = image;

  ShaderAnimationStatus latestAnimationStatus(Uri uri) =>
      _animationStatus[uri] ?? const ShaderAnimationStatus.start();
  void updateAnimationValue(Uri uri, ShaderAnimationStatus value) =>
      _animationStatus[uri] = value;
}

class ShaderAnimationStatus {
  final double position;
  final ShaderAnimationDirection direction;

  const ShaderAnimationStatus({
    required this.position,
    required this.direction,
  });

  const ShaderAnimationStatus.start()
      : position = .5,
        direction = ShaderAnimationDirection.forward;
}

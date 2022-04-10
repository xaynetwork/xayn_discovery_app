import 'dart:math';
import 'dart:ui' as ui;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';

part 'shader_cache.freezed.dart';

abstract class ShaderCache {
  bool hasImageOf(Uri uri);

  ui.Image? imageOf(Uri uri);
  ShaderAnimationStatus animationStatusOf(Uri uri);

  void register(Uri uri);

  void flush(Uri uri);

  void update(
    Uri uri, {
    ui.Image? image,
    int? refCount,
    ShaderAnimationStatus? animationStatus,
  });
}

@LazySingleton(as: ShaderCache)
class InMemoryShaderCache implements ShaderCache {
  final _entries = <Uri, ShaderCacheEntry>{};

  @override
  bool hasImageOf(Uri uri) => imageOf(uri) != null;

  @override
  ui.Image? imageOf(Uri uri) => _of(uri).image;
  @override
  ShaderAnimationStatus animationStatusOf(Uri uri) => _of(uri).animationStatus;

  @override
  void register(Uri uri) {
    final entry = _of(uri);

    update(uri, refCount: entry.refCount + 1);
  }

  @override
  void flush(Uri uri) {
    if (_entries.containsKey(uri)) {
      final entry = _of(uri);
      final refCount = entry.refCount - 1;

      _entries[uri] = entry.copyWith(refCount: refCount);

      if (refCount > 0) return;

      entry.image?.dispose();

      _entries[uri] = ShaderCacheEntry(
        refCount: 0,
        animationStatus: entry.animationStatus,
      );
    }
  }

  @override
  void update(
    Uri uri, {
    ui.Image? image,
    int? refCount,
    ShaderAnimationStatus? animationStatus,
  }) {
    final entry = _of(uri);

    _entries[uri] = entry.copyWith(
      image: image ?? entry.image,
      refCount: refCount ?? entry.refCount,
      animationStatus: animationStatus ?? entry.animationStatus,
    );
  }

  ShaderCacheEntry _of(Uri uri) =>
      _entries.putIfAbsent(uri, ShaderCacheEntry.initial);
}

@freezed
class ShaderCacheEntry with _$ShaderCacheEntry {
  factory ShaderCacheEntry({
    ui.Image? image,
    required int refCount,
    required ShaderAnimationStatus animationStatus,
  }) = _ShaderCacheEntry;

  factory ShaderCacheEntry.initial() => ShaderCacheEntry(
        refCount: 0,
        animationStatus: ShaderAnimationStatus.random(),
      );
}

@freezed
class ShaderAnimationStatus with _$ShaderAnimationStatus {
  factory ShaderAnimationStatus({
    required double position,
    required ShaderAnimationDirection direction,
  }) = _ShaderAnimationStatus;

  factory ShaderAnimationStatus.random() {
    final random = Random();

    return ShaderAnimationStatus(
      position: random.nextDouble(),
      direction: random.nextBool()
          ? ShaderAnimationDirection.forward
          : ShaderAnimationDirection.reverse,
    );
  }
}

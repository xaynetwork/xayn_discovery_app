import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader_cache.dart';

import '../../../test_utils/utils.dart';

void main() {
  late InMemoryShaderCache cache;
  late Map<Uri, MockImage> images;

  final k0 = Uri.dataFromString('0');
  final k1 = Uri.dataFromString('1');
  final k2 = Uri.dataFromString('2');
  final k3 = Uri.dataFromString('3');

  setUp(() {
    cache = InMemoryShaderCache(maxKeepAnywaySize: 3);
    images = <Uri, MockImage>{};
    for (int i = 0; i < 4; i++) {
      images[Uri.dataFromString('$i')] = MockImage();
    }
  });

  test('Register and get an image will not flush', () {
    cache.register(k0);
    cache.update(k0, image: images[k0]);

    final imageOf = cache.imageOf(k0);

    expect(imageOf, isNotNull);
    verifyNever(imageOf!.dispose());
  });

  test('Register and flush an image will not yet dispose', () {
    cache.register(k0);
    cache.update(k0, image: images[k0]);
    cache.flush(k0);

    final imageOf = cache.imageOf(k0);

    expect(imageOf, isNotNull);
    verifyNever(imageOf!.dispose());
  });

  test('Register and flush 4 images will dispose the oldest image', () {
    cache.register(k0);
    cache.update(k0, image: images[k0]);
    cache.flush(k0);
    cache.register(k1);
    cache.update(k1, image: images[k1]);
    cache.flush(k1);
    cache.register(k2);
    cache.update(k2, image: images[k2]);
    cache.flush(k2);
    cache.register(k3);
    cache.update(k3, image: images[k3]);
    cache.flush(k3);

    expect(cache.imageOf(k0), isNull);
    verify(images[k0]!.dispose());
    expect(cache.imageOf(k1), isNotNull);
    verifyNever(images[k1]!.dispose());
    expect(cache.imageOf(k2), isNotNull);
    verifyNever(images[k2]!.dispose());
    expect(cache.imageOf(k3), isNotNull);
    verifyNever(images[k3]!.dispose());
  });

  test(
      'Exceeding the maxKeepAnywaySize will not dispose when no image is flushed',
      () {
    cache.register(k0);
    cache.update(k0, image: images[k0]);
    cache.register(k1);
    cache.update(k1, image: images[k1]);
    cache.register(k2);
    cache.update(k2, image: images[k2]);
    cache.register(k3);
    cache.update(k3, image: images[k3]);

    for (int i = 0; i < 4; i++) {
      expect(cache.imageOf(Uri.dataFromString('$i')), isNotNull);
      verifyNever(images[Uri.dataFromString('$i')]!.dispose());
    }
  });

  test(
      'Exceeding the maxKeepAnywaySize will dispose the last elements that were flushed',
      () {
    cache.register(k0);
    cache.update(k0, image: images[k0]);
    cache.flush(k0);

    cache.register(k1);
    cache.update(k1, image: images[k1]);
    cache.register(k2);
    cache.update(k2, image: images[k2]);
    cache.register(k3);
    cache.update(k3, image: images[k3]);

    expect(cache.imageOf(k0), isNull);
    verify(images[k0]!.dispose());
    for (int i = 1; i < 4; i++) {
      expect(cache.imageOf(Uri.dataFromString('$i')), isNotNull);
      verifyNever(images[Uri.dataFromString('$i')]!.dispose());
    }
  });

  test(
      'Requesting a dead image before maxKeepAnywaySize is reached will keep it',
      () {
    cache.register(k0);
    cache.update(k0, image: images[k0]);
    cache.flush(k0);

    cache.register(k1);
    cache.update(k1, image: images[k1]);

    cache.register(k2);
    cache.update(k2, image: images[k2]);

    /// adding it to the from of the keep alive list
    expect(cache.imageOf(k0), isNotNull);

    cache.register(k3);
    cache.update(k3, image: images[k3]);

    for (int i = 0; i < 4; i++) {
      expect(cache.imageOf(Uri.dataFromString('$i')), isNotNull);
      verifyNever(images[Uri.dataFromString('$i')]!.dispose());
    }
  });
}

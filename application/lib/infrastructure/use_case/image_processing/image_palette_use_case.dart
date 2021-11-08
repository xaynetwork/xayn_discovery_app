import 'package:flutter/rendering.dart';
import 'package:injectable/injectable.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

@injectable
class ImagePaletteUseCase<T> extends UseCase<Uri, PaletteGenerator> {
  ImagePaletteUseCase();

  @override
  Stream<PaletteGenerator> transaction(Uri param) async* {
    final imageProvider = NetworkImage(param.toString());

    yield await PaletteGenerator.fromImageProvider(imageProvider);
  }
}

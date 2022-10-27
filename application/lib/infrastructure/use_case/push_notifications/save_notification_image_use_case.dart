import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';

const kNotiticationImageFileName = 'notificationImage.jpg';

@injectable
class SaveNotificationImageUseCase extends UseCase<Uri?, String?> {
  final DirectUriUseCase _directUriUseCase;

  SaveNotificationImageUseCase(this._directUriUseCase);

  @override
  Stream<String?> transaction(param) async* {
    if (param == null) {
      yield null;
      return;
    }

    final data = await _getImageData(param);
    if (data == null) {
      yield null;
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$kNotiticationImageFileName';
    final File file = File(filePath);
    await file.writeAsBytes(
      data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      ),
    );
    yield filePath;
  }

  Future<Uint8List?> _getImageData(Uri uri) async {
    final list = await _directUriUseCase.call(uri);
    final last = list.last;
    Object? error;
    late CacheManagerEvent value;
    last.fold(defaultOnError: (e, _) => error = e, onValue: (it) => value = it);
    if (error != null) throw error!;
    return value.bytes;
  }
}

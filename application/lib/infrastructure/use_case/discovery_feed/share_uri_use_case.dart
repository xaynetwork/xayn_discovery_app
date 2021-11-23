import 'package:injectable/injectable.dart';
import 'package:share/share.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

@injectable
class ShareUriUseCase extends UseCase<Uri, void> {
  @override
  Stream<void> transaction(Uri param) async* {
    final url = param.toString();
    Share.share(url);
  }
}

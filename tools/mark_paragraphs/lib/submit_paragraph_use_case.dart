import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

class SubmitParagraphUseCase
    extends UseCase<Map<String, String>, Map<String, String>> {
  final collection = FirebaseFirestore.instance.collection('paragraphs');

  @override
  Stream<Map<String, String>> transaction(Map<String, String> param) async* {
    final ref = await collection.add(param);

    yield Map.from(param)..['documentId'] = ref.id;
  }
}

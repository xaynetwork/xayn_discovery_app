import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mark_paragraphs/auth_use_case.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

class SubmitParagraphUseCase
    extends UseCase<PersonalizedParagraphData, PersistedParagraphData> {
  final collection = FirebaseFirestore.instance.collection('paragraphs');

  @override
  Stream<PersistedParagraphData> transaction(
      PersonalizedParagraphData param) async* {
    final ref = await collection.add({
      'userId': param.userId,
      'paragraph': param.paragraph,
      'isRelevant': param.isRelevant,
      'timestamp': DateTime.now().toIso8601String(),
    });

    yield PersistedParagraphData(
      param.paragraph,
      userId: param.userId,
      documentId: ref.id,
      isRelevant: param.isRelevant,
    );
  }
}

class PersistedParagraphData extends PersonalizedParagraphData {
  final String documentId;

  const PersistedParagraphData(
    String paragraph, {
    required String userId,
    required this.documentId,
    required bool isRelevant,
  }) : super(
          paragraph,
          userId: userId,
          isRelevant: isRelevant,
        );
}

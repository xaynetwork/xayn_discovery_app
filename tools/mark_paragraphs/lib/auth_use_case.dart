import 'package:firebase_auth/firebase_auth.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

class AuthUseCase extends UseCase<ParagraphData, PersonalizedParagraphData> {
  static User? user;

  @override
  Stream<PersonalizedParagraphData> transaction(ParagraphData param) async* {
    if (user == null) {
      final credential = await FirebaseAuth.instance.signInAnonymously();

      user = credential.user;
    }

    if (user != null) {
      yield PersonalizedParagraphData(
        param.paragraph,
        userId: user!.uid,
        isRelevant: param.isRelevant,
      );
    } else {
      throw Exception('Could not sign in into FireBase');
    }
  }
}

class ParagraphData {
  final String paragraph;
  final bool isRelevant;

  const ParagraphData(
    this.paragraph, {
    required this.isRelevant,
  });
}

class PersonalizedParagraphData extends ParagraphData {
  final String userId;

  const PersonalizedParagraphData(
    String paragraph, {
    required this.userId,
    required bool isRelevant,
  }) : super(
          paragraph,
          isRelevant: isRelevant,
        );
}

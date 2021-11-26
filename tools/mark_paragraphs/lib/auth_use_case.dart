import 'package:firebase_auth/firebase_auth.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

class AuthUseCase extends UseCase<String, Map<String, String>> {
  static User? user;

  @override
  Stream<Map<String, String>> transaction(String param) async* {
    if (user == null) {
      final credential = await FirebaseAuth.instance.signInAnonymously();

      user = credential.user;
    }

    if (user != null) {
      yield {
        'userId': user!.uid,
        'text': param,
      };
    } else {
      throw Exception('Could not sign in into FireBase');
    }
  }
}

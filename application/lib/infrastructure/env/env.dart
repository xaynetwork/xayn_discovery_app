import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envify(path: kReleaseMode ? '.env.prod' : '.env.dev')
abstract class Env {
  static const String searchApiBaseUrl = _Env.searchApiBaseUrl;
  static const String searchApiSecretKey = _Env.searchApiSecretKey;
}

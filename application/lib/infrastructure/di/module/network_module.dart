import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

@module
abstract class NetworkModule {
  http.Client get getHttpClient => http.Client();
}

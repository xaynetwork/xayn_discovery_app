import 'package:ntp/ntp.dart';

class RealTime {
  static final RealTime _instance = RealTime._internal();

  factory RealTime() => _instance;

  RealTime._internal();

  DateTime now = DateTime.now();

  Future<void> updateTime() async => now = await NTP.now();
}

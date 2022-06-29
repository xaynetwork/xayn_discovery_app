import 'package:injectable/injectable.dart';
import 'package:ntp/ntp.dart';

@singleton
class RealTime {
  DateTime now = DateTime.now();

  Future<void> updateTime() async => now = await NTP.now();
}

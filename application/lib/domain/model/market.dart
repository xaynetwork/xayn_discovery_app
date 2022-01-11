import 'package:equatable/equatable.dart';

abstract class Market<Locale> extends Equatable {
  String get fullCode;
  String get language;
  String get country;
  bool get isMarketSupported;
  bool get isLanguageSupported;
  Locale get locale;

  @override
  List<Object> get props => [fullCode];
}

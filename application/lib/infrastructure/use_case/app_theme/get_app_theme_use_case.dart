import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/use_case_extension.dart';

@injectable
class FakeAppThemeStorage extends ValueNotifier<AppTheme> {
  static FakeAppThemeStorage? _instance;

  FakeAppThemeStorage._() : super(AppTheme.system);

  factory FakeAppThemeStorage() {
    _instance ??= FakeAppThemeStorage._();
    return _instance!;
  }
}

@injectable
class GetAppThemeUseCase extends UseCase<None, AppTheme> {
  final FakeAppThemeStorage _storage;

  GetAppThemeUseCase(this._storage);

  @override
  Stream<AppTheme> transaction(None param) async* {
    await Future.delayed(const Duration(milliseconds: 42));
    yield _storage.value;
  }
}

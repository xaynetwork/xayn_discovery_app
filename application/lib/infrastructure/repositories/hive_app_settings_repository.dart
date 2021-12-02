import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/box_names.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repositories/hive_repository.dart';

const kSettingsKey = 0;

class HiveAppSettingsRepository extends HiveRepository<AppSettings>
    implements AppSettingsRepository {
  final AppSettingsMapper _mapper;

  HiveAppSettingsRepository({
    required bool isWeb,
  }) : _mapper = const AppSettingsMapper();

  @override
  BaseMapper<AppSettings> get mapper => _mapper;

  @override
  Box<Record> get box => Hive.box<Record>(BoxNames.appSettings);

  @override
  Future<AppSettings> getSettings() async =>
      await getById(AppSettings.globalId()) ?? AppSettings.initial();
}

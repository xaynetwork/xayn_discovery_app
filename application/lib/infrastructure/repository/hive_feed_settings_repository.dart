import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

import 'hive_repository.dart';

typedef GetCurrentLocale = Locale Function();

@LazySingleton(as: FeedSettingsRepository)
class HiveFeedSettingsRepository extends HiveRepository<FeedSettings>
    implements FeedSettingsRepository {
  final FeedSettingsMapper _mapper;
  Box<Record>? _box;

  HiveFeedSettingsRepository(this._mapper);

  @visibleForTesting
  HiveFeedSettingsRepository.test(this._mapper, this._box);

  @override
  Box<Record> get box => _box ??= Hive.box<Record>(BoxNames.feedSettings);

  @override
  BaseDbEntityMapper<FeedSettings> get mapper => _mapper;

  @override
  FeedSettings get settings =>
      getById(FeedSettings.globalId) ?? FeedSettings.initial();
}

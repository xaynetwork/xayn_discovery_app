import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';

@injectable
class CrudFeedSettingsUseCase extends DbEntityCrudUseCase<FeedSettings> {
  CrudFeedSettingsUseCase(FeedSettingsRepository feedSettingsRepository)
      : super(feedSettingsRepository as HiveFeedSettingsRepository);
}

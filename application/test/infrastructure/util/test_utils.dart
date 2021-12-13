import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_adapters.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_constants.dart';

// registers adapters if they are not already registered
void initHiveAdapters() {
  if (!Hive.isAdapterRegistered(hlcAdapterTypeId)) {
    Hive.registerAdapter(HlcAdapter(hlcAdapterTypeId));
  }
  if (!Hive.isAdapterRegistered(hlcCompactAdapterTypeId)) {
    Hive.registerAdapter(
        HlcCompatAdapter(hlcCompactAdapterTypeId, UniqueId().value));
  }
  if (!Hive.isAdapterRegistered(recordAdapterTypeId)) {
    Hive.registerAdapter(RecordAdapter(recordAdapterTypeId));
  }
}

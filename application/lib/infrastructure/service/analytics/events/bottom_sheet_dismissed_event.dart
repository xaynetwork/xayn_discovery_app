import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'bottomSheetDismissed';
const String _kParamBottomSheetView = 'bottomSheetView';

class BottomSheetDismissedEvent extends AnalyticsEvent {
  BottomSheetDismissedEvent({
    required BottomSheetView bottomSheetView,
  }) : super(
          _kEventType,
          properties: {
            _kParamBottomSheetView: bottomSheetView.name,
          },
        );
}

enum BottomSheetView {
  saveToCollection,
  moveMultipleBookmarksToCollection,
  createCollection,
  renameCollection,
  confirmDeletingCollection,
}

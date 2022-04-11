import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/subscription_window_observation.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_subscription_window_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/subscription_window_observation_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

typedef OnSubscriptionObservation = void Function(
    SubscriptionWindowMeasuredObservation observation);

mixin ObserveSubscriptionWindowMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<SubscriptionWindowObservation, None>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void onSubscriptionWindowOpened({
    required SubscriptionWindowCurrentView currentView,
  }) {
    _useCaseSink ??= _getUseCaseSink();

    _useCaseSink!(
      SubscriptionWindowObservation(
        currentView: currentView,
        type: SubscriptionWindowObservationType.open,
      ),
    );
  }

  void onSubscriptionWindowClosed({
    required SubscriptionWindowCurrentView currentView,
  }) =>
      _useCaseSink!(
        SubscriptionWindowObservation(
          currentView: currentView,
          type: SubscriptionWindowObservationType.close,
        ),
      );

  UseCaseSink<SubscriptionWindowObservation, None> _getUseCaseSink() {
    final subscriptionWindowObservationUseCase =
        di.get<SubscriptionWindowObservationUseCase>();
    final subscriptionWindowMeasuredObservationUseCase =
        di.get<SubscriptionWindowMeasuredObservationUseCase>();
    final getSubscriptionStatusUseCase = di.get<GetSubscriptionStatusUseCase>();
    final sendAnalyticsUseCase = di.get<SendAnalyticsUseCase>();

    return pipe(subscriptionWindowObservationUseCase).transform((out) => out
        .distinct(
          (a, b) => a.value.type == b.value.type,
        )
        .pairwise() // combine last and current observation
        .followedBy(subscriptionWindowMeasuredObservationUseCase)
        .where((it) => it.currentView != null && it.duration.inSeconds > 0)
        .doOnData(
          _onObservation(
            sendAnalyticsUseCase: sendAnalyticsUseCase,
            getSubscriptionStatusUseCase: getSubscriptionStatusUseCase,
          ),
        )
        .map((it) => none))
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  void Function(SubscriptionWindowMeasuredObservation) _onObservation({
    required SendAnalyticsUseCase sendAnalyticsUseCase,
    required GetSubscriptionStatusUseCase getSubscriptionStatusUseCase,
  }) =>
      (SubscriptionWindowMeasuredObservation observation) async {
        final currentView = observation.currentView!;
        final subscriptionStatus = await getSubscriptionStatusUseCase
            .singleOutput(PurchasableIds.subscription);
        final daysToSubscribe = subscriptionStatus.trialEndDate
            ?.calculateDifferenceInDays(DateTime.now());
        final purchaseDate = subscriptionStatus.purchaseDate;

        sendAnalyticsUseCase(
          OpenSubscriptionWindowEvent(
            currentView: currentView,
            duration: observation.duration,
            daysToSubscribe: daysToSubscribe,
            subscriptionDate: purchaseDate,
          ),
        );
      };
}

import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

import 'subscription_details_state.dart';

@injectable
class SubscriptionDetailsManager extends Cubit<SubscriptionDetailsState>
    with UseCaseBlocHelper<SubscriptionDetailsState> {
  SubscriptionDetailsManager()
      : super(SubscriptionDetailsState(endDate: subscriptionEndDate));
}

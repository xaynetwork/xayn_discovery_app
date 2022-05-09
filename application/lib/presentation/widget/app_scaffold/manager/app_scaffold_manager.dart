import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/manager/app_scaffold_state.dart';

@lazySingleton
class AppScaffoldManager extends Cubit<AppScaffoldState> {
  final ConnectivityObserver connectivityObserver;

  AppScaffoldManager(this.connectivityObserver)
      : super(
          AppScaffoldState.initial(),
        ) {
    _initListener();
  }

  _initListener() {
    connectivityObserver.onConnectivityChanged.listen(
      (event) {
        emit(
          AppScaffoldState(
            connectivityResult: event,
          ),
        );
      },
    );
  }
}

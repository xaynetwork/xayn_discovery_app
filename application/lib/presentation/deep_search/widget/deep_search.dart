import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/deep_search/manager/deep_search_manager.dart';
import 'package:xayn_discovery_app/presentation/deep_search/manager/deep_search_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

const _deepSearchNavBarConfigId = NavBarConfigId('deepSearchNavBarConfigId');

class DeepSearchScreen extends StatefulWidget {
  const DeepSearchScreen({
    super.key,
    required this.documentId,
  });

  final DocumentId documentId;

  @override
  State<StatefulWidget> createState() => _DeepSearchScreenState();
}

class _DeepSearchScreenState extends State<DeepSearchScreen>
    with
        NavBarConfigMixin,
        OverlayMixin<DeepSearchScreen>,
        OverlayStateMixin<DeepSearchScreen> {
  late final DeepSearchScreenManager _deepSearchScreenManager =
      di.get(param1: widget.documentId);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: BlocBuilder<DeepSearchScreenManager, DeepSearchState>(
          builder: (context, state) {
            if (state is InitState) {
              return const Center(child: Text('Initial state'));
            } else if (state is LoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SearchSuccessState) {
              return Column(
                children: [
                  ...state.results.map(
                    (d) => Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(d.resource.title),
                    ),
                  )
                ],
              );
            } else if (state is SearchFailureState) {
              return const Center(child: Text('Something went wrong'));
            }
            return const Center(child: Text('Wrong state'));
          },
          bloc: _deepSearchScreenManager,
        ),
      ),
    );
  }

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        _deepSearchNavBarConfigId,
        buildNavBarItemBack(
          onPressed: _deepSearchScreenManager.onBackNavPressed,
        ),
      );

  @override
  OverlayManager get overlayManager => _deepSearchScreenManager.overlayManager;
}

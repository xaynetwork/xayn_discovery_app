import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager_state.dart';

import '../../utils/enum_utils.dart';

const kFeatureScreenWaitDuration = Duration(seconds: 3);

class SelectFeatureScreen extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const SelectFeatureScreen({
    Key? key,
    required this.child,
    this.delay = kFeatureScreenWaitDuration,
  }) : super(key: key);

  @override
  _SelectFeatureScreenState createState() => _SelectFeatureScreenState();
}

enum _OverrideState {
  overrideButton,
  overrideList,
  showChild,
}

class _SelectFeatureScreenState extends State<SelectFeatureScreen> {
  late final FeatureManager _featureManager = di.get();
  late final Timer timer;
  var state = _OverrideState.overrideButton;
  Widget? _child;

  @override
  void initState() {
    timer = Timer(widget.delay, onTimerEnd);
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    // should not be closed, cos FeatureManager is singleton
    // _featureManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _OverrideState.overrideButton:
        return _buildOverrideButton();

      case _OverrideState.overrideList:
        return _overrideList(onContinue: continueToNextScreen);

      case _OverrideState.showChild:
        return _child ??= widget.child;
    }
  }

  Widget _buildOverrideButton() {
    final button = MaterialButton(
      key: Keys.featureSelectionButton,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: const Text('Select Features'),
      onPressed: () => setState(() {
        state = _OverrideState.overrideList;
      }),
    );

    return MaterialApp(
      home: Center(
        child: button,
      ),
    );
  }

  Widget _overrideList({required Function() onContinue}) =>
      BlocBuilder<FeatureManager, FeatureManagerState>(
        bloc: _featureManager,
        builder: (context, state) {
          return _FeaturesList(
            featureManager: _featureManager,
            featureMap: state.featureMap,
            onContinue: onContinue,
          );
        },
      );

  void onTimerEnd() =>
      state == _OverrideState.overrideButton ? continueToNextScreen() : null;

  void continueToNextScreen() => setState(
        () => state = _OverrideState.showChild,
      );
}

class _FeaturesList extends StatelessWidget {
  const _FeaturesList({
    Key? key,
    required this.onContinue,
    required this.featureMap,
    required this.featureManager,
  }) : super(key: key);

  final Function() onContinue;
  final FeatureMap featureMap;
  final FeatureManager featureManager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(
        children: [
          Expanded(child: _buildFeaturesList(featureMap)),
          continueButton(),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(FeatureMap features) => ListView.builder(
        itemBuilder: (_, i) {
          final feature = Feature.values[i];
          final isEnabled = features[feature] ?? false;
          return _buildItem(feature, isEnabled);
        },
        itemCount: Feature.values.length,
      );

  Widget _buildItem(Feature feature, bool isEnabled) => MaterialButton(
        color: isEnabled ? Colors.green : Colors.grey,
        onPressed: () => featureManager.flipFlopFeature(feature),
        child: Text(describeEnum(feature)),
      );

  Widget continueButton() => MaterialButton(
        color: Colors.white,
        onPressed: onContinue,
        child: const Text('Continue'),
      );
}

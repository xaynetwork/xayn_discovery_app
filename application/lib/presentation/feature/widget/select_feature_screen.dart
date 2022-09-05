import 'dart:async';

import 'package:dart_remote_config/model/known_experiment_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager_state.dart';

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
  State<SelectFeatureScreen> createState() => _SelectFeatureScreenState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FeatureManager, FeatureManagerState>(
        bloc: _featureManager,
        builder: (context, featureState) => _buildBody(context, featureState),
      );

  Widget _buildBody(BuildContext context, FeatureManagerState featureState) {
    switch (state) {
      case _OverrideState.overrideButton:
        return _buildOverrideButton();

      case _OverrideState.overrideList:
        return _overrideList(
          context: context,
          featureState: featureState,
          onContinue: continueToNextScreen,
        );
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

  Widget _overrideList({
    required BuildContext context,
    required FeatureManagerState featureState,
    required Function() onContinue,
  }) =>
      MaterialApp(
        home: _FeaturesList(
          featureManager: _featureManager,
          featureMap: featureState.featureMap,
          subscribedVariantIds: featureState.subscribedVariantIds,
          onContinue: onContinue,
        ),
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
    required this.subscribedVariantIds,
  }) : super(key: key);

  final Function() onContinue;
  final FeatureMap featureMap;
  final Set<KnownVariantId> subscribedVariantIds;
  final FeatureManager featureManager;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(child: _buildFeaturesList(featureMap)),
          resetFirstStartupButton(),
          setTrialDurationToZero(),
          showSubscribedExperiments(context),
          continueButton(),
        ],
      );

  Widget _buildFeaturesList(FeatureMap features) => ListView.builder(
        itemBuilder: (_, i) {
          final feature = Feature.values[i];
          final isEnabled = features[feature] ?? false;
          return _buildItem(feature, isEnabled);
        },
        itemCount: Feature.values.length,
      );

  Widget _buildItem(Feature feature, bool isEnabled) {
    final dataBuffer = StringBuffer()
      ..writeln(' - owner: ${feature.owner.name}')
      ..write(' - default: ${feature.defaultValue}');
    if (feature.description != null) {
      dataBuffer.write('\n - desc: ${feature.description}');
    }
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          feature.name,
          style: R.styles.textInputText.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          dataBuffer.toString(),
          style: R.styles.textInputText,
        ),
      ],
    );
    final btn = MaterialButton(
      color: isEnabled ? Colors.green : Colors.grey,
      onPressed: () => featureManager.flipFlopFeature(feature),
      child: SizedBox(width: double.infinity, child: child),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: btn,
    );
  }

  void onShowSubscribedExperiments(BuildContext context) {
    final closeButton = IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.pop(context),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Subscribed experiments'),
        content: Text(subscribedVariantIds.join('\n')),
        actions: [closeButton],
      ),
    );
  }

  Widget resetFirstStartupButton() => MaterialButton(
        color: Colors.white,
        onPressed: featureManager.resetFirstAppStartupDate,
        child: const Text('Reset first startup time'),
      );

  Widget setTrialDurationToZero() => MaterialButton(
        color: Colors.white,
        onPressed: featureManager.setTrialDurationToZero,
        child: const Text('Set trial duration to 0'),
      );

  Widget showSubscribedExperiments(BuildContext context) => MaterialButton(
        color: Colors.white,
        onPressed: () => onShowSubscribedExperiments(context),
        child: const Text('Show subscribed experiments'),
      );

  Widget continueButton() => MaterialButton(
        color: Colors.white,
        onPressed: onContinue,
        child: const Text('Continue'),
      );
}

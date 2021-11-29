import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

import '../../utils/enum_utils.dart';

class SelectFeatureScreen extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const SelectFeatureScreen({
    Key? key,
    required this.child,
    this.delay = const Duration(seconds: 3),
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
  var state = _OverrideState.overrideButton;
  Widget? _child;
  late Timer timer;

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

  Widget _buildOverrideButton() => MaterialApp(
        home: Center(
          child: MaterialButton(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: const Text('Select Features'),
            onPressed: () => setState(() {
              state = _OverrideState.overrideList;
            }),
          ),
        ),
      );

  Widget _overrideList({required Function() onContinue}) {
    final featureList = ListView.builder(
      itemBuilder: (c, i) => _buildItem(Feature.values[i]),
      itemCount: Feature.values.length,
    );

    final continueButton = MaterialButton(
      color: Colors.white,
      onPressed: onContinue,
      child: const Text('Continue'),
    );

    return MaterialApp(
      home: Column(
        children: [
          Expanded(child: featureList),
          continueButton,
        ],
      ),
    );
  }

  Widget _buildItem(Feature feature) => MaterialButton(
        color: feature.isEnabled ? Colors.green : Colors.grey,
        onPressed: () => setState(() => feature.invert()),
        child: Text(describeEnum(feature)),
      );

  void onTimerEnd() =>
      state == _OverrideState.overrideButton ? continueToNextScreen() : null;

  void continueToNextScreen() => setState(
        () => state = _OverrideState.showChild,
      );
}

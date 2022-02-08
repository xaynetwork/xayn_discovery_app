import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/trial_expired.dart';

class TrialExpiredScreen extends StatefulWidget {
  const TrialExpiredScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrialExpiredScreenState();
}

class _TrialExpiredScreenState extends State<TrialExpiredScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: TrialExpired(),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_report/manager/discovery_engine_report_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_report/manager/discovery_engine_report_state.dart';

class DiscoveryEngineReportOverlay extends StatefulWidget {
  const DiscoveryEngineReportOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  _DiscoveryEngineReportOverlayState createState() =>
      _DiscoveryEngineReportOverlayState();
}

class _DiscoveryEngineReportOverlayState
    extends State<DiscoveryEngineReportOverlay> {
  bool _showOverlay = true;
  late final DiscoveryEngineReportManager _manager = di.get();

  @override
  void dispose() {
    _manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (_showOverlay) buildOverlayReport(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showOverlay = !_showOverlay),
        child: const Icon(Icons.extension),
      ),
    );
  }

  Widget buildOverlayReport() => LayoutBuilder(
        builder: (_, constraints) => BlocBuilder<DiscoveryEngineReportManager,
            DiscoveryEngineReportState>(
          bloc: _manager,
          builder: (_, state) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverlay(constraints, _buildLogText(state.inputEvents)),
              _buildOverlay(constraints, _buildLogText(state.outputEvents)),
            ],
          ),
        ),
      );

  Widget _buildOverlay(BoxConstraints constraints, Widget child) {
    final spacerWidth = R.dimen.unit;
    final width = (constraints.maxWidth - spacerWidth) / 2;
    final height = constraints.maxHeight / 2;
    final color = R.colors.background.withAlpha(200);
    return Container(
      color: color,
      width: width,
      height: height,
      child: SingleChildScrollView(
        reverse: true,
        child: child,
      ),
    );
  }

  Widget _buildLogText(List<String> text) {
    final separator = '\n${'=' * 20}\n';
    return Text(text.join(separator));
  }
}

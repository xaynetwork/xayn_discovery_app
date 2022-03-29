import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/tts/manager/tts_manager.dart';

class Tts extends StatefulWidget {
  final Widget child;
  final TtsData data;

  const Tts({
    Key? key,
    required this.child,
    required this.data,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TtsState();
}

class _TtsState extends State<Tts> {
  late final TtsManager _manager;

  @override
  void initState() {
    _manager = di.get();

    if (widget.data.enabled) _updateManager();

    super.initState();
  }

  @override
  void dispose() {
    _manager.stop();

    super.dispose();
  }

  @override
  void didUpdateWidget(Tts oldWidget) {
    if (widget.data.enabled != oldWidget.data.enabled ||
        widget.data.html != oldWidget.data.html) {
      _updateManager();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder(
        bloc: _manager,
        builder: (context, state) => widget.child,
      );

  void _updateManager() {
    final html = widget.data.html;

    if (widget.data.enabled && html != null) {
      _manager.start(
        html: html,
        languageCode: widget.data.languageCode,
        uri: widget.data.uri,
      );
    } else {
      _manager.stop();
    }
  }
}

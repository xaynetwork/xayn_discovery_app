import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_state.dart';
import 'package:xayn_readability/xayn_readability.dart';

class ReaderMode extends StatefulWidget {
  final ProcessHtmlResult processHtmlResult;

  const ReaderMode({
    Key? key,
    required this.processHtmlResult,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReaderModeState();
}

class _ReaderModeState extends State {
  late final ReaderModeManager _readerModeManager;

  @override
  void initState() {
    super.initState();

    _readerModeManager = di.get();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderModeManager, ReaderModeState>(
        buildWhen: (a, b) => b.html != null,
        bloc: _readerModeManager,
        builder: (context, state) {
          final html = state.html!;

          return HtmlWidget(
            html,
            textStyle: R.styles.appBodyText,
          );
        });
  }
}

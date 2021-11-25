import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/_tooling/mark_bad_paragraphs/program_manager.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

void main() {
  configureDependencies();

  final unterDenLinden = UnterDenLinden(
    initialLinden: R.linden,
    onLindenUpdated: R.updateLinden,
    child: const App(),
  );

  runApp(unterDenLinden);
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xayn test app',
      theme: UnterDenLinden.getLinden(context).themeData,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final ProgramManager _manager;
  late String _currentParagraph;
  int _currentPage = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    _manager = ProgramManager();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<ProgramManager, ProgramState>(
            bloc: _manager,
            builder: (context, state) {
              final dataset =
                  state.pages.expand((it) => it).toList(growable: false);
              final pages = dataset
                  .map(
                    (it) => Center(
                      child: Padding(
                        padding: EdgeInsets.all(R.dimen.unit5),
                        child: SingleChildScrollView(
                          child: Text(
                            it,
                            style: R.styles.appBodyText,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false);

              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'Paragraph ${_currentPage + 1} of ${dataset.length}', style: R.styles.dialogTitleText,),
                ),
                body: PageView(
                  onPageChanged: (index) => setState(() {
                    _currentPage = index;
                    _currentParagraph = dataset[index];
                  }),
                  children: pages,
                ),

                /// This is for testing purposes only
                /// Should be removed once we have a settings page
                floatingActionButton: FloatingActionButton(
                  onPressed: () =>
                      _manager.handleMarkIrrelevant(_currentParagraph),
                  tooltip: 'Toggle Theme',
                  backgroundColor: R.colors.swipeBackgroundDelete,
                  child: const Icon(Icons.delete),
                ),
              );
            }));
  }
}

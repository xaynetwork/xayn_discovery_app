import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';

void main() {
  configureDependencies();

  final unterDenLinden = UnterDenLinden(
    child: const App(),
    initialLinden: Linden(),
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const DiscoveryFeed();
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'db/db.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter<Email>(EmailAdapter());
  Hive.registerAdapter<Account>(AccountAdapter());
  Hive.registerAdapter<Event>(EventAdapter());
  await Hive.openBox('accounts10');
  await Hive.openBox('events14');
  await Hive.openBox("emails5");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Freebie",
        theme: ThemeData(useMaterial3: true, primaryColor: const Color(0xffb099e1)),
        home: Login());
  }
}

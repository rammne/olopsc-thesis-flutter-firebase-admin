import 'package:admin/admin_panel/admin_panel.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/views/responsive_views/desktop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.grey[350],
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.blue[300],
          selectedIconTheme: IconThemeData(color: Colors.yellow),
          selectedLabelTextStyle: TextStyle(color: Colors.amber[200]),
        ),
        scaffoldBackgroundColor: Colors.blue[100],
      ),
      home: DesktopAdminPanel(),
    );
  }
}

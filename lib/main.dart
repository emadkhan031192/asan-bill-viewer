
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AsanBillApp());
}

class AsanBillApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asan Bill Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0B3D20),
          primary: Color(0xFF0B3D20),
          secondary: Color(0xFFD9E8D0),
          surface: Color(0xFFFEFBF6),
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0B3D20),
          brightness: Brightness.dark,
          primary: Color(0xFF0B3D20),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

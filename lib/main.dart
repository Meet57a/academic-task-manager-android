import 'package:academic_task_manager/pages/home.dart';
import 'package:academic_task_manager/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://gbprvmqfffjuyosrelhy.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdicHJ2bXFmZmZqdXlvc3JlbGh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxODYyNzQsImV4cCI6MjA3NTc2MjI3NH0.Ro068qYCjVYe-bDbeAESmNnQOFNFTetDAKoj85mtWKE",
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Task Manager',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeNotifier>(context).themeMode,
      home: Home(),
    );
  }
}

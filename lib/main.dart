
import 'package:flutter/material.dart';
import 'package:tp_api/views/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tp_api/views/main_screen.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ulfkglswmorpfmxgxjvc.supabase.co', //url supabase
    //key spabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVsZmtnbHN3bW9ycGZteGd4anZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0NDQ1NzEsImV4cCI6MjAyNzAyMDU3MX0.Dj4r6lUN5nfqDduJN2q-bq_fsAV-4a1WaLRxNTIvVKY',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
int id_account = -1;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mqniixfemspedlhgpbud.supabase.co',
    anonKey: 'sb_publishable_EY-narEq2XLAi7d1_JJwNA_pHuC1PFk',
  );

  runApp(const TerritoryApp());
}

class TerritoryApp extends StatelessWidget {
  const TerritoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Territory: Footprint',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: Colors.black87,
      ),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
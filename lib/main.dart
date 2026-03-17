import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'pantallas/home.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const SonarisApp());
}

class SonarisApp extends StatelessWidget {
  const SonarisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ApiService(),
      child: MaterialApp(
        title: 'Sonaris',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF080808),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        home: const PantallaHome(),
      ),
    );
  }
}

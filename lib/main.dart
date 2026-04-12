import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'pantallas/bienvenida.dart';
import 'pantallas/home.dart';
import 'constantes/colores.dart';
import 'services/api_service.dart';
import 'services/turso_service.dart';
import 'services/sesion_service.dart';
import 'services/perfil_service.dart';
import 'services/curso_service.dart';

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
    final turso = TursoService();
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => turso),
        ChangeNotifierProvider(create: (_) => SesionService(turso)),
        ChangeNotifierProvider(create: (_) => PerfilService()),
        ChangeNotifierProvider(create: (_) => CursoService()),
      ],
      child: MaterialApp(
        title: 'Sonaris',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF080808),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        home: const _PantallaInicial(),
      ),
    );
  }
}

class _PantallaInicial extends StatelessWidget {
  const _PantallaInicial();

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionService>();
    if (sesion.cargando) {
      return const Scaffold(
        backgroundColor: Color(0xFF080808),
        body: Center(
          child: CircularProgressIndicator(color: verde, strokeWidth: 2),
        ),
      );
    }
    return sesion.logueado ? const PantallaHome() : const PantallaBienvenida();
  }
}

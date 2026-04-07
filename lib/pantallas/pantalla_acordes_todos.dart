import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';

class PantallaAcordesTodos extends StatefulWidget {
  const PantallaAcordesTodos({super.key});

  @override
  State<PantallaAcordesTodos> createState() => _EstadoPantallaAcordesTodos();
}

class _EstadoPantallaAcordesTodos extends State<PantallaAcordesTodos>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: medio, size: 18),
              ),
            ),
            const Text(
              'Todos los acordes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200, color: blanco),
            ),
          ]),
        ),
        TabBar(
          controller: _tabs,
          indicatorColor: verde,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: verde,
          unselectedLabelColor: medio,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Básico (${acordesBasicos.length})'),
            Tab(text: 'Intermedio (${acordesIntermedios.length})'),
            Tab(text: 'Avanzado (${acordesAvanzados.length})'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _GridAcordes(lista: acordesBasicos),
              _GridAcordes(lista: acordesIntermedios),
              _GridAcordes(lista: acordesAvanzados),
            ],
          ),
        ),
      ]),
    );
  }
}

class _GridAcordes extends StatelessWidget {
  final List<String> lista;
  const _GridAcordes({required this.lista});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: lista.length,
      itemBuilder: (_, i) => _TarjetaAcorde(acorde: lista[i]),
    );
  }
}

class _TarjetaAcorde extends StatelessWidget {
  final String acorde;
  const _TarjetaAcorde({required this.acorde});

  @override
  Widget build(BuildContext context) {
    final data = chordData[acorde];
    final notas = notasAcorde[acorde] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // Nombre
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(acorde,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w200, color: blanco)),
          Text(nombreAcorde[acorde] ?? '',
            style: const TextStyle(fontSize: 9, color: medio),
            textAlign: TextAlign.right,
          ),
        ]),
        const SizedBox(height: 8),
        // Diagrama
        Expanded(
          child: Center(
            child: data == null
                ? const Text('—', style: TextStyle(color: medio))
                : FlutterGuitarChord(
                    baseFret: data.baseFret,
                    chordName: acorde,
                    fingers: data.fingers,
                    frets: data.frets,
                    totalString: 6,
                    tabForegroundColor: fondo,
                    tabBackgroundColor: verde,
                    barColor: verde,
                    labelColor: medio,
                    stringColor: const Color(0xFF333333),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        // Notas
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: notas.map((n) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(n, style: const TextStyle(fontSize: 10, color: blanco)),
          )).toList(),
        ),
      ]),
    );
  }
}

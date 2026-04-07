import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';

class PantallaCatalogoAcordes extends StatefulWidget {
  const PantallaCatalogoAcordes({super.key});

  @override
  State<PantallaCatalogoAcordes> createState() => _EstadoCatalogo();
}

class _EstadoCatalogo extends State<PantallaCatalogoAcordes>
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
        // Encabezado
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(children: [
            const Text('Catálogo',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w200,
                    color: blanco,
                    letterSpacing: 0.5)),
            const Spacer(),
            Text('${acordes.length} acordes',
                style: const TextStyle(fontSize: 11, color: medio)),
          ]),
        ),
        // Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: tarjeta,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabs,
            indicator: BoxDecoration(
              color: verde.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: verde.withOpacity(0.3)),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: verde,
            unselectedLabelColor: medio,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Básico'),
              Tab(text: 'Intermedio'),
              Tab(text: 'Avanzado'),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: lista.length,
      itemBuilder: (_, i) => _TarjetaChord(acorde: lista[i]),
    );
  }
}

class _TarjetaChord extends StatelessWidget {
  final String acorde;
  const _TarjetaChord({required this.acorde});

  @override
  Widget build(BuildContext context) {
    final data = chordData[acorde];
    return GestureDetector(
      onTap: () => _mostrarDetalle(context, acorde),
      child: Container(
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // Nombre
          Row(children: [
            Text(acorde,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: blanco)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(nombreAcorde[acorde] ?? '',
                  style: const TextStyle(fontSize: 9, color: medio),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 8),
          // Diagrama
          Expanded(
            child: Center(
              child: data != null
                  ? FlutterGuitarChord(
                      baseFret: data.baseFret,
                      chordName: acorde,
                      fingers: data.fingers,
                      frets: data.frets,
                      totalString: 6,
                      labelColor: blanco,
                      tabForegroundColor: fondo,
                      tabBackgroundColor: verde,
                      barColor: verde,
                      stringColor: medio,
                    )
                  : const Icon(Icons.music_note, color: medio, size: 40),
            ),
          ),
          const SizedBox(height: 6),
          // Notas
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: (notasAcorde[acorde] ?? []).map((n) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(n,
                  style: const TextStyle(fontSize: 9, color: blanco)),
            )).toList(),
          ),
        ]),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, String acorde) {
    final data = chordData[acorde];
    showModalBottomSheet(
      context: context,
      backgroundColor: tarjeta2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: tenue, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Text(acorde,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w200,
                    color: blanco)),
            const SizedBox(width: 12),
            Text(nombreAcorde[acorde] ?? '',
                style: const TextStyle(fontSize: 14, color: medio)),
          ]),
          const SizedBox(height: 20),
          if (data != null)
            SizedBox(
              height: 200,
              child: FlutterGuitarChord(
                baseFret: data.baseFret,
                chordName: acorde,
                fingers: data.fingers,
                frets: data.frets,
                totalString: 6,
                labelColor: blanco,
                tabForegroundColor: fondo,
                tabBackgroundColor: verde,
                barColor: verde,
                stringColor: medio,
              ),
            ),
          const SizedBox(height: 16),
          // Notas
          Wrap(
            spacing: 8,
            children: (notasAcorde[acorde] ?? []).map((n) => Chip(
              label: Text(n,
                  style: const TextStyle(fontSize: 12, color: blanco)),
              backgroundColor: tarjeta,
              side: BorderSide(color: verde.withOpacity(0.3)),
              padding: EdgeInsets.zero,
            )).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            descripcionAcorde[acorde] ?? '',
            style: const TextStyle(fontSize: 13, color: medio, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}

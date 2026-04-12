// Modelo de datos del curso de guitarra

class MiniEjercicio {
  final String pregunta;
  final List<String> opciones;
  final int respuestaCorrecta; // índice
  const MiniEjercicio({
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
  });
}

class Leccion {
  final String id;
  final String titulo;
  final String contenido;
  final String? imagenAsset; // opcional
  final MiniEjercicio? ejercicio;
  final int xp;

  const Leccion({
    required this.id,
    required this.titulo,
    required this.contenido,
    this.imagenAsset,
    this.ejercicio,
    this.xp = 50,
  });
}

class Capitulo {
  final String id;
  final String numero;
  final String titulo;
  final String descripcion;
  final List<Leccion> lecciones;

  const Capitulo({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.lecciones,
  });
}

// ── Contenido del curso ───────────────────────────────────

const List<Capitulo> capitulosBasico = [
  Capitulo(
    id: 'cap1',
    numero: '1',
    titulo: 'Introducción a la guitarra',
    descripcion: 'Conoce tu instrumento y los conceptos básicos',
    lecciones: [
      Leccion(
        id: 'cap1_l1',
        titulo: '¿Qué es un acorde?',
        xp: 50,
        contenido:
            '''Un acorde es un conjunto de 3 o más notas musicales que suenan al mismo tiempo.

En la guitarra, los acordes se forman presionando varias cuerdas en distintos trastes con los dedos de la mano izquierda, mientras la mano derecha rasguea o puntea las cuerdas.

Los acordes son la base de casi toda la música. Con solo 3 o 4 acordes puedes tocar cientos de canciones.

Existen dos tipos principales:
• Acordes mayores — suenan alegres y brillantes
• Acordes menores — suenan más oscuros y melancólicos''',
        ejercicio: MiniEjercicio(
          pregunta: '¿Cuántas notas mínimo forman un acorde?',
          opciones: ['1 nota', '2 notas', '3 notas', '5 notas'],
          respuestaCorrecta: 2,
        ),
      ),
      Leccion(
        id: 'cap1_l2',
        titulo: 'Partes de la guitarra',
        xp: 50,
        contenido: '''Antes de tocar, es importante conocer tu instrumento:

🎸 Clavijero — donde se afilan las cuerdas para afinar
🎸 Mástil — la parte larga donde colocas los dedos
🎸 Trastes — las divisiones metálicas del mástil
🎸 Cuerpo — la caja de resonancia que amplifica el sonido
🎸 Boca — el agujero por donde sale el sonido
🎸 Puente — donde se anclan las cuerdas en el cuerpo

Las 6 cuerdas de la guitarra, de la más gruesa a la más delgada, son:
E - A - D - G - B - e''',
        ejercicio: MiniEjercicio(
          pregunta: '¿Cuántas cuerdas tiene una guitarra estándar?',
          opciones: ['4', '5', '6', '7'],
          respuestaCorrecta: 2,
        ),
      ),
      Leccion(
        id: 'cap1_l3',
        titulo: 'Cómo leer un diagrama',
        xp: 50,
        contenido:
            '''Un diagrama de acorde es un mapa visual que te muestra dónde colocar los dedos.

📊 Cómo interpretarlo:

• Las líneas VERTICALES representan las 6 cuerdas (de izquierda a derecha: E A D G B e)
• Las líneas HORIZONTALES representan los trastes
• Los CÍRCULOS numerados indican qué dedo usar (1=índice, 2=medio, 3=anular, 4=meñique)
• La X arriba de una cuerda significa que NO se toca
• El O arriba de una cuerda significa que se toca al aire (sin presionar)

La línea gruesa en la parte superior representa la cejuela (el inicio del mástil).''',
        ejercicio: MiniEjercicio(
          pregunta: '¿Qué significa una X en la parte superior de un diagrama?',
          opciones: [
            'Tocar esa cuerda fuerte',
            'No tocar esa cuerda',
            'Tocar al aire',
            'Usar el dedo 4',
          ],
          respuestaCorrecta: 1,
        ),
      ),
    ],
  ),
  Capitulo(
    id: 'cap2',
    numero: '2',
    titulo: 'Postura y técnica',
    descripcion: 'Aprende la posición correcta para tocar',
    lecciones: [
      Leccion(
        id: 'cap2_l1',
        titulo: 'Posición de la mano izquierda',
        xp: 50,
        contenido:
            '''La posición correcta de la mano es fundamental para tocar sin dolor y con buen sonido.

✅ Consejos clave:

• El PULGAR va detrás del mástil, aproximadamente a la altura del dedo medio
• Los dedos deben estar CURVADOS, como si sostuvieras una pelota pequeña
• Presiona las cuerdas cerca del traste, pero sin pisarlo directamente
• Mantén la MUÑECA relajada y ligeramente hacia afuera
• Los dedos que no usas deben estar cerca de las cuerdas, listos para actuar

❌ Errores comunes:
• Doblar la muñeca hacia adentro
• Presionar con la yema plana en lugar de la punta del dedo
• Tensar el hombro o el brazo''',
        ejercicio: MiniEjercicio(
          pregunta: '¿Dónde debe ir el pulgar de la mano izquierda?',
          opciones: [
            'Encima del mástil',
            'Detrás del mástil',
            'Sobre las cuerdas',
            'No importa la posición',
          ],
          respuestaCorrecta: 1,
        ),
      ),
      Leccion(
        id: 'cap2_l2',
        titulo: 'Tu primer acorde: A Mayor',
        xp: 100,
        contenido:
            '''¡Es hora de tocar tu primer acorde! El acorde A (LA Mayor) es uno de los más fáciles.

🎸 Cómo formarlo:

1. Coloca el dedo 1 (índice) en la cuerda D, traste 2
2. Coloca el dedo 2 (medio) en la cuerda G, traste 2  
3. Coloca el dedo 3 (anular) en la cuerda B, traste 2

Los tres dedos van en el mismo traste, uno al lado del otro.

✅ Cuerdas que se tocan: A D G B e (la cuerda E grave NO se toca)
✅ Cuerdas al aire: A y e

💡 Consejo: Asegúrate de que cada nota suene clara. Si alguna suena apagada, ajusta la posición del dedo.''',
        ejercicio: MiniEjercicio(
          pregunta: '¿En qué traste se forma el acorde A Mayor?',
          opciones: ['Traste 1', 'Traste 2', 'Traste 3', 'Traste 4'],
          respuestaCorrecta: 1,
        ),
      ),
    ],
  ),
];

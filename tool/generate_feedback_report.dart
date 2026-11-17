import 'dart:io';

/// Herramienta Administrativa y de Análisis Operativo para ColimaNight
/// ============================================================================
/// ESTA HERRAMIENTA ES ESTRICTAMENTE PRIVADA Y DE USO EXCLUSIVO PARA:
/// 1. El Fundador / Administrador de la plataforma ColimaNight.
/// 2. La Gerencia de los 22 establecimientos de Colima y Villa de Álvarez.
///
/// NUNCA SE DESPLIEGA NI SE EXPONE EN LA APLICACIÓN PÚBLICA PARA CLIENTES.
/// ============================================================================

void main(List<String> args) async {
  print('================================================================');
  print('🍸 COLIMANIGHT — MOTOR PRIVADO DE ANÁLISIS Y FEEDBACK DE SERVICIO');
  print('================================================================');
  print('Generando informe confidencial de calidad y fricciones operativas...\n');

  // Muestra de datos estructurados para auditoría y estudio
  final feedbackRecords = [
    {
      'venueId': 'guachi_ignacio_sandoval',
      'venueName': 'El Guachi',
      'category': 'slow_service',
      'subCategory': 'Fila de barra / lentitud',
      'note': 'Demora de más de 20 minutos para pedir en la barra este',
      'timestamp': '2026-11-08T23:45:00Z',
      'hour': 23,
    },
    {
      'venueId': 'guachi_ignacio_sandoval',
      'venueName': 'El Guachi',
      'category': 'slow_service',
      'subCategory': 'Fila de barra / lentitud',
      'note': 'Falta de personal en la barra principal a la medianoche',
      'timestamp': '2026-11-09T00:15:00Z',
      'hour': 0,
    },
    {
      'venueId': 'guachi_ignacio_sandoval',
      'venueName': 'El Guachi',
      'category': 'other',
      'subCategory': 'Clima / Ventilación',
      'note': 'Mucho calor en la zona central',
      'timestamp': '2026-11-09T00:30:00Z',
      'hour': 0,
    },
    {
      'venueId': 'costa_sandoval',
      'venueName': 'Cervecería de la Costa - Sandoval',
      'category': 'slow_service',
      'subCategory': 'Demora en alimentos',
      'note': 'Cocina demoró 35 min con las entradas',
      'timestamp': '2026-11-08T21:40:00Z',
      'hour': 21,
    },
    {
      'venueId': 'dmt_rock_bar',
      'venueName': 'DMT Rock Bar',
      'category': 'other',
      'subCategory': 'Higiene y Sanitarios',
      'note': 'Baños sucios sin insumos a la 1 AM',
      'timestamp': '2026-11-09T01:10:00Z',
      'hour': 1,
    },
    {
      'venueId': 'low_social_club',
      'venueName': 'Low Social Club',
      'category': 'other',
      'subCategory': 'Música y Acústica',
      'note': 'Música con saturación excesiva en bocinas laterales',
      'timestamp': '2026-11-09T01:30:00Z',
      'hour': 1,
    },
  ];

  // Agrupación por establecimiento
  final Map<String, List<Map<String, dynamic>>> byVenue = {};
  for (final record in feedbackRecords) {
    final vId = record['venueId'] as String;
    byVenue.putIfAbsent(vId, () => []).add(record);
  }

  final buffer = StringBuffer();
  buffer.writeln('# 🔒 INFORME CONFIDENCIAL DE CALIDAD Y FEEDBACK DE SERVICIO');
  buffer.writeln('**Plataforma:** ColimaNight — Inteligencia Operativa Nocturna');
  buffer.writeln('**Fecha de Generación:** ${DateTime.now().toIso8601String().split('T').first}');
  buffer.writeln('**Clasificación:** ESTRICTAMENTE CONFIDENCIAL (Solo Gerencia & Administración)');
  buffer.writeln('**Aviso de Privacidad:** Este documento y sus métricas NO son de acceso público.');
  buffer.writeln('\n---\n');

  buffer.writeln('## 1. Resumen Ejecutivo de la Conurbación');
  buffer.writeln('- **Total de Registros de Calidad Procesados:** ${feedbackRecords.length}');
  buffer.writeln('- **Establecimientos con Métricas Registradas:** ${byVenue.keys.length}');
  buffer.writeln('- **Categoría Predominante:** Servicio Lento en Barras y Cocina (50%)');
  buffer.writeln('- **Ventana de Mayor Fricción Operativa:** 23:00 hrs a 01:30 hrs');
  buffer.writeln('\n---\n');

  buffer.writeln('## 2. Diagnóstico Detallado por Establecimiento');

  byVenue.forEach((venueId, records) {
    final venueName = records.first['venueName'];
    buffer.writeln('### 📍 $venueName (`$venueId`)');
    buffer.writeln('- **Total de Observaciones Registradas:** ${records.length}');

    final categoryCounts = <String, int>{};
    final hourCounts = <int, int>{};

    for (final r in records) {
      final sub = r['subCategory'] as String;
      categoryCounts[sub] = (categoryCounts[sub] ?? 0) + 1;
      final h = r['hour'] as int;
      hourCounts[h] = (hourCounts[h] ?? 0) + 1;
    }

    buffer.writeln('- **Desglose de Puntos de Fricción:**');
    categoryCounts.forEach((cat, count) {
      buffer.writeln('  - $cat: $count mención(es)');
    });

    buffer.writeln('- **Horarios Críticos:**');
    hourCounts.forEach((hour, count) {
      buffer.writeln('  - ${hour.toString().padLeft(2, '0')}:00 hrs: $count reporte(s)');
    });

    buffer.writeln('- **Recomendación Operativa para la Gerencia:**');
    if (categoryCounts.containsKey('Fila de barra / lentitud')) {
      buffer.writeln('  > 💡 *Sugerencia:* Reforzar personal de apoyo en barra auxiliar entre 23:30 y 00:30 los fines de semana.');
    } else if (categoryCounts.containsKey('Higiene y Sanitarios')) {
      buffer.writeln('  > 💡 *Sugerencia:* Programar rondín de abastecimiento de sanitarios a las 00:00 y 01:00 hrs.');
    } else {
      buffer.writeln('  > 💡 *Sugerencia:* Monitorear balance acústico y temperatura ambiental en horas pico.');
    }
    buffer.writeln('');
  });

  buffer.writeln('---\n');
  buffer.writeln('## 3. Próximas Líneas de Estudio y Optimización');
  buffer.writeln('1. **Correlación Aforo vs. Demora:** Comparar la telemetría de presencia (80m) con los reportes de lentitud para predecir a qué porcentaje de aforo se colapsa cada barra.');
  buffer.writeln('2. **Benchmarking Anónimo:** Proporcionar a cada dueño un puntaje relativo frente al promedio de su zona (ej. Corredor Sandoval vs. Tercer Anillo) sin revelar datos de competidores.');

  final outputDir = Directory('docs/reports');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final outputFile = File('docs/reports/informe_calidad_operativa_privado.md');
  await outputFile.writeAsString(buffer.toString());

  print('✅ Informe confidencial generado exitosamente en:');
  print('   ${outputFile.path}\n');
  print('Resumen rápido del reporte:');
  print('----------------------------------------------------------------');
  print(buffer.toString());
}

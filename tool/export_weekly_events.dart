import 'dart:convert';
import 'dart:io';

void main() async {
  stdout.writeln('================================================================');
  stdout.writeln(' 🚀 EXPORTADOR Y COMPILADOR DE CARTELERA • COLIMANIGHT');
  stdout.writeln('================================================================');

  final studioDataFile = File('tool/studio/data/curated_events.json');
  final assetsDataFile = File('assets/data/curated_events.json');

  if (await studioDataFile.exists()) {
    final content = await studioDataFile.readAsString();
    await assetsDataFile.parent.create(recursive: true);
    await assetsDataFile.writeAsString(content);
    stdout.writeln('✓ Sincronizado assets/data/curated_events.json desde Studio.');
  } else if (await assetsDataFile.exists()) {
    stdout.writeln('✓ Utilizando datos existentes de assets/data/curated_events.json.');
  } else {
    stdout.writeln('! No se encontraron eventos previos, inicializando archivo vacío.');
    await assetsDataFile.parent.create(recursive: true);
    await assetsDataFile.writeAsString('{}');
  }

  // Leer estadísticas de eventos para informar en consola
  try {
    final raw = await assetsDataFile.readAsString();
    final Map<String, dynamic> data = jsonDecode(raw);
    int totalEvents = 0;
    data.forEach((_, list) {
      if (list is List) totalEvents += list.length;
    });
    stdout.writeln('ℹ Total de publicaciones a compilar: $totalEvents');
  } catch (e) {
    stdout.writeln('! Advertencia leyendo JSON: $e');
  }

  stdout.writeln('');
  stdout.writeln('Compilando Flutter Web para GitHub Pages (carpeta docs/)...');
  stdout.writeln('Comando: flutter build web --release --base-href /ColimaNight/ --output docs');

  final stopwatch = Stopwatch()..start();
  final result = await Process.run(
    'flutter',
    ['build', 'web', '--release', '--base-href', '/ColimaNight/', '--output', 'docs'],
    runInShell: true,
  );

  stopwatch.stop();

  if (result.exitCode == 0) {
    stdout.writeln('✓ Compilación completada con éxito en ${stopwatch.elapsed.inSeconds}s.');
    stdout.writeln('✓ Carpeta docs/ actualizada con la cartelera oficial.');
    stdout.writeln('');
    stdout.writeln('Para publicar en internet (GitHub Pages), ejecuta:');
    stdout.writeln('  git add docs assets/data tool/studio/data');
    stdout.writeln('  git commit -m "chore: update weekly cartelera"');
    stdout.writeln('  git push');
    stdout.writeln('');
    stdout.writeln('Tu sitio web estará actualizado en: https://kevmxsr.github.io/ColimaNight/');
  } else {
    stderr.writeln('✕ Error durante la compilación de Flutter Web:');
    stderr.writeln(result.stderr);
    exitCode = 1;
  }
}

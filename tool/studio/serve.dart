import 'dart:convert';
import 'dart:io';

void main() async {
  const port = 8088;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  final studioDir = Directory('tool/studio');
  final eventsFile = File('tool/studio/data/curated_events.json');
  final assetsFile = File('assets/data/curated_events.json');

  stdout.writeln('');
  stdout.writeln('================================================================');
  stdout.writeln(' 🍸 COLIMANIGHT CURATION STUDIO (PORTAL PRIVADO)');
  stdout.writeln('================================================================');
  stdout.writeln(' Servidor local activo en: http://localhost:$port/');
  stdout.writeln(' PIN Maestro de Acceso:   2026');
  stdout.writeln(' Archivo de datos:        tool/studio/data/curated_events.json');
  stdout.writeln(' Presiona Ctrl+C para detener el servidor.');
  stdout.writeln('================================================================');
  stdout.writeln('');

  await for (final HttpRequest request in server) {
    // CORS headers para permitir requests del navegador
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;

    // API: Leer eventos curados
    if (path == '/api/events' && request.method == 'GET') {
      request.response.headers.contentType = ContentType.json;
      if (await eventsFile.exists()) {
        final content = await eventsFile.readAsString();
        request.response.write(content.isNotEmpty ? content : '{}');
      } else {
        request.response.write('{}');
      }
      await request.response.close();
      continue;
    }

    // API: Guardar eventos curados
    if (path == '/api/events' && request.method == 'POST') {
      try {
        final body = await utf8.decoder.bind(request).join();
        // Validar que sea JSON válido
        final parsed = jsonDecode(body);
        final prettyJson = const JsonEncoder.withIndent('  ').convert(parsed);

        // Guardar en data local del studio
        await eventsFile.parent.create(recursive: true);
        await eventsFile.writeAsString(prettyJson);

        // Replicar en assets/data de la app
        await assetsFile.parent.create(recursive: true);
        await assetsFile.writeAsString(prettyJson);

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'success': true, 'message': 'Eventos guardados exitosamente.'}));
      } catch (e) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
      }
      await request.response.close();
      continue;
    }

    // API: Disparar compilación para GitHub Pages
    if (path == '/api/deploy' && request.method == 'POST') {
      try {
        stdout.writeln('[Studio] Ejecutando exportación y compilación para GitHub Pages...');
        final result = await Process.run(
          'dart',
          ['run', 'tool/export_weekly_events.dart'],
          runInShell: true,
        );

        request.response.headers.contentType = ContentType.json;
        if (result.exitCode == 0) {
          request.response.write(jsonEncode({'success': true, 'output': result.stdout.toString()}));
        } else {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write(jsonEncode({'success': false, 'error': result.stderr.toString()}));
        }
      } catch (e) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
      }
      await request.response.close();
      continue;
    }

    // API: Subir flyer / captura de pantalla desde el dispositivo o portapapeles
    if (path == '/api/upload' && request.method == 'POST') {
      try {
        final body = await utf8.decoder.bind(request).join();
        final Map<String, dynamic> data = jsonDecode(body);
        final String venueId = (data['venueId'] ?? 'general').toString();
        final String rawBase64 = (data['data'] ?? '').toString();

        if (rawBase64.isEmpty) {
          throw Exception('No se recibieron datos de imagen.');
        }

        final commaIdx = rawBase64.indexOf(',');
        final base64Payload = commaIdx != -1 ? rawBase64.substring(commaIdx + 1) : rawBase64;
        final bytes = base64Decode(base64Payload);

        String ext = 'jpg';
        if (rawBase64.startsWith('data:image/png')) {
          ext = 'png';
        } else if (rawBase64.startsWith('data:image/webp')) {
          ext = 'webp';
        } else if (data['filename'] != null && data['filename'].toString().contains('.')) {
          final candidate = data['filename'].toString().split('.').last.toLowerCase();
          if (['jpg', 'jpeg', 'png', 'webp'].contains(candidate)) {
            ext = candidate == 'jpeg' ? 'jpg' : candidate;
          }
        }

        final safeVenue = venueId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
        final filename = 'flyer_${safeVenue}_${DateTime.now().millisecondsSinceEpoch}.$ext';

        // 1. Guardar en carpeta oficial de assets de la aplicación Flutter
        final assetFlyer = File('assets/images/venues/flyers/$filename');
        await assetFlyer.parent.create(recursive: true);
        await assetFlyer.writeAsBytes(bytes);

        // 2. Guardar en tool/studio/uploads/ para previsualización inmediata en el navegador
        final studioUpload = File('tool/studio/uploads/$filename');
        await studioUpload.parent.create(recursive: true);
        await studioUpload.writeAsBytes(bytes);

        stdout.writeln('📸 [Studio Upload] Flyer guardado: assets/images/venues/flyers/$filename (${bytes.length ~/ 1024} KB)');

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({
          'success': true,
          'filename': filename,
          'assetPath': 'assets/images/venues/flyers/$filename',
          'previewUrl': '/uploads/$filename',
        }));
      } catch (e) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
      }
      await request.response.close();
      continue;
    }

    // Servir uploads del Studio
    if (path.startsWith('/uploads/')) {
      final uploadFileName = path.replaceFirst('/uploads/', '');
      final uploadFile = File('tool/studio/uploads/$uploadFileName');
      if (await uploadFile.exists()) {
        if (uploadFileName.endsWith('.png')) {
          request.response.headers.contentType = ContentType('image', 'png');
        } else if (uploadFileName.endsWith('.webp')) {
          request.response.headers.contentType = ContentType('image', 'webp');
        } else {
          request.response.headers.contentType = ContentType('image', 'jpeg');
        }
        await uploadFile.openRead().pipe(request.response);
        continue;
      }
    }

    // Servir assets directos
    if (path.startsWith('/assets/')) {
      final assetFile = File(path.substring(1));
      if (await assetFile.exists()) {
        final lower = path.toLowerCase();
        if (lower.endsWith('.png')) {
          request.response.headers.contentType = ContentType('image', 'png');
        } else if (lower.endsWith('.webp')) {
          request.response.headers.contentType = ContentType('image', 'webp');
        } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
          request.response.headers.contentType = ContentType('image', 'jpeg');
        }
        await assetFile.openRead().pipe(request.response);
        continue;
      }
    }

    // Servir archivos estáticos del Studio (index.html, app.js, etc.)
    var filePath = path == '/' ? 'index.html' : path.substring(1);
    final targetFile = File('${studioDir.path}/$filePath');

    if (await targetFile.exists()) {
      if (filePath.endsWith('.html')) {
        request.response.headers.contentType = ContentType.html;
      } else if (filePath.endsWith('.js')) {
        request.response.headers.contentType = ContentType('application', 'javascript', charset: 'utf-8');
      } else if (filePath.endsWith('.css')) {
        request.response.headers.contentType = ContentType('text', 'css', charset: 'utf-8');
      } else if (filePath.endsWith('.json')) {
        request.response.headers.contentType = ContentType.json;
      } else if (filePath.endsWith('.png')) {
        request.response.headers.contentType = ContentType('image', 'png');
      } else if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
        request.response.headers.contentType = ContentType('image', 'jpeg');
      } else if (filePath.endsWith('.webp')) {
        request.response.headers.contentType = ContentType('image', 'webp');
      }
      await targetFile.openRead().pipe(request.response);
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('404 Not Found en ColimaNight Studio');
      await request.response.close();
    }
  }
}

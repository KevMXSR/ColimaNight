import 'dart:io';

void main() async {
  const port = 8080;
  final webDir = Directory('build/web');

  if (!webDir.existsSync()) {
    print('❌ Directorio build/web no encontrado. Ejecuta primero: flutter build web --release');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('========================================================');
  print('🍸 Servidor Local de ColimaNight iniciado con éxito!');
  print('📡 Acceso local en PC:        http://localhost:$port');

  try {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) {
          print('📱 Acceso móvil (misma Wi-Fi): http://${addr.address}:$port');
        }
      }
    }
  } catch (_) {}

  print('Presiona Ctrl+C para detener el servidor.');
  print('========================================================');

  await for (final HttpRequest request in server) {
    var path = request.uri.path;

    // Normalizar si la solicitud incluye el prefijo del repositorio /ColimaNight/
    if (path.startsWith('/ColimaNight/')) {
      path = path.substring('/ColimaNight'.length);
    } else if (path == '/ColimaNight') {
      path = '/';
    }

    if (path.isEmpty || path == '/') {
      path = '/index.html';
    }

    final sanitizedPath = path.replaceAll('..', '');
    var file = File('${webDir.path}$sanitizedPath');

    // SPA fallback: Solo reescribir a index.html si es una ruta de navegación (sin extensión de archivo)
    final hasFileExtension = sanitizedPath.contains('.') && !sanitizedPath.endsWith('.html');
    if (!file.existsSync() || file.statSync().type == FileSystemEntityType.directory) {
      if (!hasFileExtension) {
        file = File('${webDir.path}/index.html');
      }
    }

    if (file.existsSync() && file.statSync().type == FileSystemEntityType.file) {
      final ext = file.path.split('.').last.toLowerCase();
      final mime = _getMimeType(ext);
      request.response.headers.contentType = ContentType.parse(mime);
      request.response.headers.add('Cache-Control', 'no-cache, no-store, must-revalidate');
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
      request.response.headers.add('Cross-Origin-Opener-Policy', 'same-origin');
      request.response.headers.add('Cross-Origin-Embedder-Policy', 'require-corp');

      if (request.method == 'HEAD') {
        request.response.headers.contentLength = file.lengthSync();
        await request.response.close();
      } else {
        await file.openRead().pipe(request.response);
      }
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.text;
      request.response.write('404 Not Found: $path');
      await request.response.close();
    }
  }
}

String _getMimeType(String ext) {
  switch (ext) {
    case 'html':
      return 'text/html; charset=utf-8';
    case 'js':
    case 'mjs':
      return 'application/javascript; charset=utf-8';
    case 'json':
      return 'application/json; charset=utf-8';
    case 'css':
      return 'text/css; charset=utf-8';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'svg':
      return 'image/svg+xml';
    case 'mp4':
      return 'video/mp4';
    case 'wasm':
      return 'application/wasm';
    case 'otf':
      return 'font/otf';
    case 'ttf':
      return 'font/ttf';
    case 'woff':
      return 'font/woff';
    case 'woff2':
      return 'font/woff2';
    default:
      return 'application/octet-stream';
  }
}

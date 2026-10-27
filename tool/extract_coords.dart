import 'dart:io';

void main() {
  final file = File('lib/features/map/domain/models/venue_location.dart');
  final content = file.readAsStringSync();
  final regex = RegExp(
    r"id:\s*'([a-z0-9_-]+)',[\s\S]*?name:\s*'([^']+)',[\s\S]*?address:\s*'([^']+)',[\s\S]*?coordinates:\s*GeoPoint\(([0-9.-]+),\s*([0-9.-]+)\),",
  );

  final matches = regex.allMatches(content);
  print('Found ${matches.length} venues in venue_location.dart:');
  for (final m in matches) {
    print('${m.group(1)} | ${m.group(2)} | lat: ${m.group(4)}, lng: ${m.group(5)} | addr: "${m.group(3)}"');
  }
}

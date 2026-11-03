import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Límite de reproducciones automáticas al arranque (usuario solicitó entre 3 y 5 veces).
/// Tras alcanzar 4 visualizaciones, la app abre directamente el feed principal,
/// pero el manifiesto permanece siempre disponible mediante el botón dedicado en el header.
const int kMaxAutoShowManifestoCount = 4;
const String kManifestoViewCountKey = 'colima_night_manifesto_view_count';

/// Notifier para consultar y gestionar el conteo de visualizaciones del manifiesto cinematográfico
class ManifestoViewCountNotifier extends StateNotifier<AsyncValue<int>> {
  ManifestoViewCountNotifier() : super(const AsyncValue.loading()) {
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(kManifestoViewCountKey) ?? 0;
      state = AsyncValue.data(count);
    } catch (_) {
      // Fallback seguro en memoria en caso de restricciones de almacenamiento
      state = const AsyncValue.data(0);
    }
  }

  /// Incrementa el contador al reproducir el manifiesto
  Future<void> recordView() async {
    final current = state.value ?? 0;
    final updated = current + 1;
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(kManifestoViewCountKey, updated);
    } catch (_) {
      // No bloqueante
    }
  }

  /// Indica si debe mostrarse automáticamente al terminar el splash screen
  bool get shouldAutoShow {
    final count = state.value ?? 0;
    return count < kMaxAutoShowManifestoCount;
  }
}

final manifestoViewCountProvider =
    StateNotifierProvider<ManifestoViewCountNotifier, AsyncValue<int>>((ref) {
  return ManifestoViewCountNotifier();
});

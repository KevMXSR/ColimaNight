import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Callback disparado al pausar o reanudar listeners de base de datos
typedef ListenerCallback = void Function();

/// Estructura de registro para un listener administrado bajo costo cero
class ManagedListenerRegistration {
  final String id;
  final ListenerCallback onPause;
  final ListenerCallback onResume;
  bool isPaused;

  ManagedListenerRegistration({
    required this.id,
    required this.onPause,
    required this.onResume,
    this.isPaused = false,
  });
}

/// Servicio centinela para la optimización y control estricto de costos en Firestore 5.0.
/// 
/// Garantiza la permanencia dentro del plan gratuito Spark (50,000 lecturas diarias)
/// y optimiza el consumo en expansión regional bajo el plan Blaze ($0.06 USD por 100k lecturas).
/// 
/// REGLAS FUNDAMENTALES IMPLEMENTADAS:
/// 1. Cero imágenes/flyers en Firestore: Almacenamiento exclusivo en Firebase Storage o URLs externas (< 2 KB/doc).
/// 2. Cero lecturas fantasma: Escucha de `WidgetsBindingObserver` para suspender streams de `snapshots()`
///    en segundo plano (`paused`, `inactive`, `hidden`).
/// 3. Push Notifications con FCM: Alertas relámpago gratuitas e ilimitadas vía tópicos FCM en vez de polling.
class FirestoreCostOptimizer with WidgetsBindingObserver {
  FirestoreCostOptimizer._();
  static final FirestoreCostOptimizer instance = FirestoreCostOptimizer._();

  bool _isInitialized = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  final Map<String, ManagedListenerRegistration> _managedListeners = {};

  int _ghostReadsPrevented = 0;

  /// Estado actual del ciclo de vida de la aplicación
  AppLifecycleState get lifecycleState => _lifecycleState;

  /// Indica si la aplicación está en primer plano y activa para escuchar Firestore
  bool get isAppActive => _lifecycleState == AppLifecycleState.resumed;

  /// Cantidad estimada de lecturas fantasma prevenidas al suspender listeners en segundo plano
  int get ghostReadsPrevented => _ghostReadsPrevented;

  /// Inicializa el centinela registrándolo en el observador del ciclo de vida de Flutter
  void initialize() {
    if (_isInitialized) return;
    try {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      debugPrint('[FirestoreCostOptimizer] Observador de ciclo de vida activado (Spark 0-Cost Guard).');
    } catch (e) {
      debugPrint('[FirestoreCostOptimizer] WidgetsBinding no inicializado: $e');
    }
  }

  /// Libera el observador
  void dispose() {
    if (!_isInitialized) return;
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    _isInitialized = false;
    _managedListeners.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    debugPrint('[FirestoreCostOptimizer] Ciclo de vida cambió a: $state');

    if (state == AppLifecycleState.resumed) {
      _resumeAllListeners();
    } else {
      _pauseAllListeners();
    }
  }

  /// Registra un listener de Firestore para ser pausado automáticamente en segundo plano
  void registerManagedListener({
    required String listenerId,
    required ListenerCallback onPause,
    required ListenerCallback onResume,
  }) {
    _managedListeners[listenerId] = ManagedListenerRegistration(
      id: listenerId,
      onPause: onPause,
      onResume: onResume,
      isPaused: !isAppActive,
    );

    // Si la app está en segundo plano al registrarse, pausar de inmediato
    if (!isAppActive) {
      onPause();
    }
  }

  /// Desregistra un listener administrado cuando el widget se destruye (dispose)
  void unregisterManagedListener(String listenerId) {
    _managedListeners.remove(listenerId);
  }

  void _pauseAllListeners() {
    int count = 0;
    for (final reg in _managedListeners.values) {
      if (!reg.isPaused) {
        reg.isPaused = true;
        try {
          reg.onPause();
          count++;
        } catch (e) {
          debugPrint('[FirestoreCostOptimizer] Error al pausar listener ${reg.id}: $e');
        }
      }
    }
    // Asume un ahorro estimado de lecturas por minuto en segundo plano
    _ghostReadsPrevented += (count * 2);
    debugPrint('[FirestoreCostOptimizer] Pausados $count listeners de Firestore para evitar lecturas fantasma.');
  }

  void _resumeAllListeners() {
    int count = 0;
    for (final reg in _managedListeners.values) {
      if (reg.isPaused) {
        reg.isPaused = false;
        try {
          reg.onResume();
          count++;
        } catch (e) {
          debugPrint('[FirestoreCostOptimizer] Error al reanudar listener ${reg.id}: $e');
        }
      }
    }
    debugPrint('[FirestoreCostOptimizer] Reanudados $count listeners de Firestore al volver al primer plano.');
  }

  // =========================================================================
  // REGLA 1: VALIDACIÓN DE TAMAÑO Y ALMACENAMIENTO DE MULTIMEDIA (STORAGE VS FIRESTORE)
  // =========================================================================

  /// Valida que el documento para Firestore sea ultra liviano (< 2 KB) y no contenga blobs o base64
  static bool validateDocumentPayload(Map<String, dynamic> data, {int maxBytes = 2048}) {
    try {
      final jsonString = jsonEncode(data);
      final byteSize = utf8.encode(jsonString).length;

      if (byteSize > maxBytes) {
        debugPrint('[FirestoreCostOptimizer] ADVERTENCIA: Documento excede $maxBytes bytes ($byteSize B).');
        return false;
      }

      // Verifica que no existan strings base64 o binarios pesados incrustados
      for (final entry in data.entries) {
        final val = entry.value;
        if (val is String && (val.startsWith('data:image') || val.length > 1024)) {
          debugPrint('[FirestoreCostOptimizer] REGLA VIOLADA: Campo "${entry.key}" contiene posibles datos binarios base64.');
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('[FirestoreCostOptimizer] Error calculando tamaño de documento: $e');
      return false;
    }
  }

  /// Verifica si una URL de imagen o flyer apunta a Storage o CDN externo legítimo
  static bool isValidMediaUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    // No permitir data URIs en Firestore
    if (lower.startsWith('data:image')) return false;

    return lower.startsWith('https://') ||
           lower.startsWith('http://') ||
           lower.startsWith('assets/');
  }

  // =========================================================================
  // REGLA 3: REGISTRO DE TÓPICOS FCM (PUSH NOTIFICATIONS DE COSTO CERO)
  // =========================================================================

  /// Nombres de los tópicos oficiales de Firebase Cloud Messaging (FCM)
  /// Las promociones y alertas se difunden por FCM de manera ilimitada y sin costo de lecturas.
  static const String fcmTopicFlashPromos = 'colima_flash_promos';
  static const String fcmTopicSecurityAlerts = 'colima_security_alerts';

  /// Genera el tópico FCM para un corredor o municipio específico
  static String fcmCorridorTopic(String corridorId) {
    return 'corridor_${corridorId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase()}';
  }

  // =========================================================================
  // EXPANSIÓN REGIONAL: CÁLCULO DE COSTO BLAZE PARA MUNICIPIOS EXPANDIDOS
  // =========================================================================

  /// Calcula el costo estimado en Firestore Blaze ($0.06 USD por 100,000 lecturas adicionales)
  /// teniendo en cuenta la cuota gratuita mensual de 1,500,000 lecturas (50k/día * 30 días).
  static double calculateMonthlyBlazeCostUsd({
    required int totalMonthlyReads,
    int freeTierReads = 1500000,
    double ratePer100k = 0.06,
  }) {
    if (totalMonthlyReads <= freeTierReads) {
      return 0.0;
    }
    final billableReads = totalMonthlyReads - freeTierReads;
    return (billableReads / 100000.0) * ratePer100k;
  }
}

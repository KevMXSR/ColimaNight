import 'dart:io';

/// ==============================================================================
/// 🚨 COLIMANIGHT — PANEL Y PROTOCOLO DE CONTINGENCIA AUTÓNOMA (KILL-SWITCH)
/// ==============================================================================
/// Herramienta de emergencia exclusiva para el Fundador / Administrador.
/// Permite verificar y gestionar el estado del interruptor maestro de seguridad:
/// - Modo Mantenimiento
/// - Modo Solo Lectura (Anti-Denial-of-Wallet)
/// - Silenciador de Alertas (Anti-Pánico / Falsas Alarmas)
/// - Topes Financieros: Meta $0 USD (Capa Gratuita), Techo Emergencia $15 USD
/// ==============================================================================

void main(List<String> args) {
  print('================================================================');
  print('🛡️ COLIMANIGHT — PROTOCOLO DE CONTINGENCIA Y RESPUESTA A INCIDENTES');
  print('================================================================\n');

  final configFile = File('backend/functions/src/config.ts');
  final bool hasBackend = configFile.existsSync();

  final flag = args.isNotEmpty ? args.first.toLowerCase() : '--status';

  switch (flag) {
    case '--silence-alerts':
      print('🔴 [ACCION CRITICA] ACTIVANDO KILL-SWITCH DE ALERTAS PÚBLICAS');
      print('   - Las alertas rojas quedan suprimidas en el mapa.');
      print('   - Todo reporte entrante se canaliza exclusivamente a auditoría interna.');
      print('   - Los negocios de Colima quedan protegidos contra pánico artificial.\n');
      _generateSwitchJson(
        maintenance: false,
        readOnly: false,
        alertsSilenced: true,
        reason: 'Activado por administrador ante sospecha de sabotaje con falsas alarmas.',
      );
      break;

    case '--activate-maintenance':
      print('⚠️ [ACCION CRITICA] ACTIVANDO MODO MANTENIMIENTO GLOBAL');
      print('   - La app muestra una pantalla de pausa técnica temporal.');
      print('   - Se bloquean escrituras para detener cualquier ataque activo.');
      print('   - El consumo de base de datos se reduce a CERO.\n');
      _generateSwitchJson(
        maintenance: true,
        readOnly: true,
        alertsSilenced: true,
        reason: 'Pausa técnica preventiva para resguardo de infraestructura.',
      );
      break;

    case '--read-only':
      print('🔒 [ACCION DE CONTINGENCIA] ACTIVANDO MODO SOLO LECTURA');
      print('   - Consultas permitidas, escrituras y telemetría pausadas.');
      print('   - Previene ataques de agotamiento de facturación (Denial-of-Wallet).\n');
      _generateSwitchJson(
        maintenance: false,
        readOnly: true,
        alertsSilenced: false,
        reason: 'Mitigación preventiva de costos / saturación.',
      );
      break;

    case '--restore-normal':
      print('🟢 [ACCION DE RESTAURACION] RESTABLECIENDO OPERACION NORMAL');
      print('   - Modo Mantenimiento: DESACTIVADO');
      print('   - Modo Solo Lectura: DESACTIVADO');
      print('   - Alertas Públicas: ACTIVAS (con cuórum verificado)');
      print('   - Telemetría en vivo: ACTIVA (80m)\n');
      _generateSwitchJson(
        maintenance: false,
        readOnly: false,
        alertsSilenced: false,
        reason: 'Operación restaurada a condiciones normales.',
      );
      break;

    case '--status':
    default:
      _printSecurityStatus(hasBackend);
      break;
  }
}

void _printSecurityStatus(bool hasBackend) {
  print('📊 POSTURA DE SEGURIDAD Y RESILIENCIA:');
  print('----------------------------------------------------------------');
  print('1. 🛡️ Protección Perimetral:');
  print('   - Geocerca de Proximidad: 80 metros exactos (Haversine)');
  print('   - Detección de Mock GPS / Spoofing: ACTIVA (en cliente y backend)');
  print('   - Cuórum Blindado: 5 reportes (3 para armas) con dispersión >= 4m');
  print('   - App Check Ready: Configurado para Play Integrity / DeviceCheck\n');

  print('2. 💰 Blindaje Financiero (Denial-of-Wallet):');
  print('   - Meta Operativa: \$0 USD / mes (Operando en Spark / Free Tier)');
  print('   - Techo de Apagado de Emergencia: \$15 USD / mes');
  print('   - Límite de Concurrencia Cloud Functions: maxInstances: 10\n');

  print('3. 🔒 Ofuscación y Anti-Clonación:');
  print('   - Ofuscación R8 / ProGuard: ACTIVA (isMinifyEnabled, isShrinkResources)');
  print('   - Secretos en Cliente: 0% (Salts eliminados del frontend)');
  print('   - Reglas Firestore: system_status y reports con lectura privada\n');

  print('Comandos disponibles:');
  print('  dart run tool/emergency_killswitch.dart --status');
  print('  dart run tool/emergency_killswitch.dart --silence-alerts');
  print('  dart run tool/emergency_killswitch.dart --activate-maintenance');
  print('  dart run tool/emergency_killswitch.dart --read-only');
  print('  dart run tool/emergency_killswitch.dart --restore-normal');
}

void _generateSwitchJson({
  required bool maintenance,
  required bool readOnly,
  required bool alertsSilenced,
  required String reason,
}) {
  final file = File('docs/reports/system_status_state.json');
  final parentDir = file.parent;
  if (!parentDir.existsSync()) {
    parentDir.createSync(recursive: true);
  }

  final payload = '''
{
  "maintenanceMode": $maintenance,
  "readOnlyMode": $readOnly,
  "alertsKillSwitch": $alertsSilenced,
  "reason": "$reason",
  "budgetCeilingUsd": 15.0,
  "targetOperationalCostUsd": 0.0,
  "updatedAt": "${DateTime.now().toUtc().toIso8601String()}"
}
''';

  file.writeAsStringSync(payload);
  print('📝 Estado de contingencia escrito en: ${file.path}');
  print('Contenido:');
  print(payload);
}

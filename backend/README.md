# Backend de ColimaNight — Fase 1 (Producción)

Infraestructura de backend en **Firebase (Firestore + Cloud Functions v2)** para la plataforma de vida nocturna de Colima y Villa de Álvarez. Diseñado con telemetría de aforo en vivo, prueba de proximidad estricta de **80 metros**, blindaje reputacional contra falsas alarmas (cuórum mínimo de **5 reportes**, 3 para armas), pipeline de eventos de **11 canales oficiales de Instagram** y modelo de donaciones comunitarias tipo Patreon.

---

## 1. Arquitectura y Pilares Críticos de la Fase 1

### 1.1. Proof of Proximity a 80 Metros Exactos
- **Delimitación Física:** Para garantizar que solo quienes están efectivamente dentro del local o terraza aporten al aforo o emitan reportes, el radio ortodrómico (Haversine) se ajustó a **80 metros exactos** (reemplazando los 150m previos).
- **Filtro Anti-Spoofing:** Se rechazan lecturas con precisión GPS horizontal $> 35\text{ m}$ para prevenir emulaciones o rebotes de señal en interiores.

### 1.2. Blindaje Reputacional del Establecimiento (Cuórum de 5)
- **Principio Anti-Difamación:** Un reporte aislado o falso **NUNCA** tiñe el semáforo del local de rojo ni genera pánico público.
- **Cuórum de 5 Dispositivos:** Se requieren al menos **5 reportes independientes confirmados** (hashes HMAC distintos y dispersión espacial $\ge 4\text{ m}$) dentro de una ventana rodante de **10 minutos** para que un altercado o sobrecupo pase a `alert_verified` en el mapa público.
- **Excepción de Alta Gravedad (Armas):** Los reportes de arma de fuego o arma blanca requieren un cuórum reducido de **3 reportes independientes**.
- **Auditoría Interna Confidencial:** Cualquier cantidad inferior a 5 (o 3 para armas) se cataloga como `status: 'internal_audit'` y permanece estrictamente privada y accesible solo para administradores. La imagen y reputación comercial del negocio quedan 100% blindadas.

### 1.3. Telemetría de Aforo en Vivo (Presence Heartbeat)
- **Función:** `submitPresenceHeartbeat`
- **Caducidad (TTL):** Los latidos caducan automáticamente a los **45 minutos**.
- **Contador en Tiempo Real:** Usuarios autenticados (Google, Apple) o sesiones de invitados con token validado in situ incrementan `venues/{venueId}.liveAttendeesCount`.
- **Porcentaje de Aforo Dinámico:** El backend calcula el porcentaje `currentOccupancyPercent` dividiendo los latidos activos entre la capacidad umbral (`capacityThreshold`) del establecimiento.
- **Vibe Dinámico:** Se actualiza automáticamente entre `tranquilo`, `chill`, `animado`, `fiesta_total` y `saturado`.

### 1.4. Pipeline de Eventos de Instagram (11 Canales Oficiales)
Sincronización automatizada para los 11 canales de Instagram de Colima verificados por la comunidad:
1. `@dmtrockbar` (DMT Rock Bar)
2. `@cerveceriadecolima` (Cervecería de Colima / Estación Colimita)
3. `@lapuertadelperreo.dog` (La Puerta Bar / La Puerta del Perreo)
4. `@guachirooftop` (El Guachi Rooftop, Ignacio Sandoval)
5. `@almada_cantina.fina` (Almada Cantina Fina)
6. `@dospuntoscerveceria` (Dos Puntos Cervecería)
7. `@lowclub.col` (Low Social Club, Centro)
8. `@el_gustito_ignacio_sandoval` (El Gustito, Ignacio Sandoval)
9. `@la_regional_cantina` (La Regional Cantina)
10. `@mezcal.santo` (Santo Mezcal)
11. `@casa.colima.mezcaleria` (Casa Colima Mezcalería)

La función programada `ingestSocialEvents` (ejecutada diariamente a las 19:00 CST) y la función manual `triggerSocialIngestManual` extraen carteleras, DJs, covers y promociones, poblando la colección `events` y actualizando `venues/{venueId}.liveMusic`.

### 1.5. Modelo de Donativos Comunitarios (Estilo Patreon)
Mecanismo para el sostenimiento de infraestructura, base de datos y mapas satelitales:
- **Amigo Nocturno ($30 MXN):** Insignia de colaborador básico.
- **Colima VIP Supporter ($99 MXN):** Soporte mensual de geocercas e ingesta.
- **Patrocinador Leyenda ($250 MXN):** Reconocimiento destacado en perfil.
- Registrado a través de `recordCommunityDonation` en la colección `donations`.

---

## 2. Estructura de Archivos del Backend

```
backend/
├── firestore.rules          # Reglas de seguridad endurecidas para producción
├── firestore.indexes.json   # Índices compuestos para telemetría y consultas
├── README.md                # Esta guía de arquitectura y despliegue
└── functions/
    ├── package.json         # Dependencias (firebase-admin, firebase-functions v2)
    ├── tsconfig.json        # Configuración de compilación TypeScript
    └── src/
        ├── types.ts         # Tipos e interfaces de datos completos
        ├── config.ts        # Umbrales (80m, cuórum de 5, TTL 45m, 11 canales IG)
        ├── utils/
        │   ├── geo.ts       # Haversine y validación de 80 metros exactos
        │   ├── crypto.ts    # HMAC-SHA256 y corte nocturno a las 06:00 AM
        │   └── moderation.ts# Saneamiento y blindaje anti-difamación
        ├── services/
        │   ├── presenceService.ts    # Telemetría de aforo y heartbeats con TTL
        │   ├── consensusService.ts   # Cuórum de 5 y auditoría interna
        │   └── socialIngestService.ts# Ingesta de los 11 canales de Instagram
        └── index.ts         # Exportación de Cloud Functions v2
```

---

## 3. Guía de Despliegue con Firebase CLI

### 3.1. Prerrequisitos
- Node.js versión 18 LTS instalada.
- Firebase CLI instalado globalmente:
  ```bash
  npm install -g firebase-tools
  ```
- Inicio de sesión en Firebase:
  ```bash
  firebase login
  ```
- Inicializar o seleccionar el proyecto de ColimaNight:
  ```bash
  firebase use <ID_DEL_PROYECTO_FIREBASE>
  ```

### 3.2. Instalación de Dependencias y Compilación
Desde la raíz del backend:
```bash
cd backend/functions
npm install
npm run build
```

### 3.3. Configuración de Variables de Entorno / Secret Manager
Configura la clave secreta para la derivación de hashes anónimos de dispositivo:
```bash
firebase functions:secrets:set COLIMANIGHT_HMAC_SECRET
```
*(Ingresa una cadena criptográfica de al menos 32 caracteres).*

### 3.4. Despliegue Completo a Producción
Para desplegar las Cloud Functions y las Reglas de Seguridad de Firestore en un solo comando:
```bash
firebase deploy --only functions,firestore
```

Si deseas desplegar de forma granular:
- **Solo Reglas de Seguridad e Índices:**
  ```bash
  firebase deploy --only firestore
  ```
- **Solo Cloud Functions:**
  ```bash
  firebase deploy --only functions
  ```

---

## 4. Emulación Local para Testing

Puedes probar las funciones y reglas localmente sin impactar producción usando el suite de emuladores:
```bash
cd backend/functions
npm run build
firebase emulators:start --only functions,firestore
```
El UI de emulación estará disponible en `http://localhost:4000`.

---

## 5. Matriz de Endpoints Cloud Functions v2

| Función | Tipo | Descripción | Restricción / Cuórum |
|---|---|---|---|
| `submitPresenceHeartbeat` | HTTPS onCall | Envío de latido de presencia física in situ | Haversine $\le 80\text{ m}$, TTL 45 min |
| `submitIncidentReport` | HTTPS onCall | Reporte ciudadano de altercado o riesgo | Cuórum de 5 (3 armas) en 10 min |
| `cleanupExpiredPresenceAndIncidents` | Cron (5 min) | Limpieza de TTL 45 min y normalización | Tarea automática en segundo plano |
| `ingestSocialEvents` | Cron (19:00) | Pipeline de los 11 canales de Instagram | Sincronización oficial diaria |
| `triggerSocialIngestManual` | HTTPS onCall | Disparo manual de ingesta de Instagram | Requiere rol `admin` |
| `getDonationTiers` | HTTPS onCall | Retorna los niveles de apoyo comunitario | Público |
| `recordCommunityDonation` | HTTPS onCall | Registra donativos tipo Patreon e insignias | Autenticado / Donador |

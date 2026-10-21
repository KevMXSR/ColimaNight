# 🍸 ColimaNight — Arquitectura Frontend & Sistema de Diseño (Flutter)

Plataforma móvil nocturna de descubrimiento en tiempo real para jóvenes de 18-35 años en la zona conurbada de **Colima y Villa de Álvarez**.

---

## 1. 🎨 Sistema de Diseño "Cyber-Night / Neon Clubbing"

### 1.1 Paleta de Color Dark Mode
| Nombre Token | Hex / Valor | Significado & Uso |
| :--- | :--- | :--- |
| `background` | `#0A0A0F` | Fondo obsidiana espacial profundo (ahorro OLED, alta inmersión nocturna) |
| `surface` | `#13131F` | Superficie de paneles y modales secundarios |
| `surfaceElevated` | `#1B1B2C` | Tarjetas y contenedores elevados |
| `neonViolet` | `#8A2BE2` | Morado neón electrizante (color de marca principal) |
| `neonCyan` | `#00F0FF` | Cyan ciberpunk (energía, rutas tipo Uber/DiDi, botones activos) |
| `neonMagenta` | `#FF007F` | Magenta clubbing (resplandores Hot Right Now, música en vivo) |
| `neonAmber` | `#FFB800` | Dorado ámbar (estatus VIP, ratings y recomendaciones exclusivas) |
| `neonRedAlert` | `#FF3366` | Rojo neón (aforo crítico 85%+, alta afluencia, beacon en vivo) |
| `neonGreen` | `#00FF88` | Verde neón (aforo fluido, promociones 2x1 inmediatas) |
| `glassFill` | `rgba(255,255,255,0.09)` | Relleno translúcido para efecto Glassmorphism |
| `glassBorder` | `rgba(255,255,255,0.20)` | Borde fino reflectante con refracción de luz |

### 1.2 Tipografía Sugerida
- **Titulares & Contadores:** Google Fonts `Syne` y `Space Grotesk` (estética futurista, robusta y disruptiva para carteleras nocturnas).
- **Cuerpo & Lectura de interfaz:** Google Fonts `Outfit` (limpia, geométrica, legibilidad óptima en ambientes de poca iluminación).

### 1.3 Efecto Glassmorphism & Microanimaciones
- **Desprestigio de fondo:** `BackdropFilter` con `ImageFilter.blur(sigmaX: 16, sigmaY: 16)`.
- **Bordes de refracción:** Degradado linear blanco sutil (`0.08` a `0.02`) con ancho de 1.2px.
- **Aura Pulsante (`PulsingGlow`):** Animación infinita con curva `easeInOut` que interpola el radio de desenfoque de 8px a 24px y la escala a 1.025x en los lugares destacados.

---

## 2. 📱 Catálogo Oficial de Establecimientos (22 Puntos Verificados)

1. **'El Guachi'**:
   - Dirección: Calle Ignacio Sandoval 1943, Paseo de la Cantera, Colima (Lat: 19.2631, Lng: -103.7043).
   - Sin referencias a Villa de Álvarez ni Tercer Anillo.
   - Cero menciones históricas ni de reapertura.
   - 1 frase concisa: *"Club nocturno sobre Ignacio Sandoval con DJ sets, audio envolvente y coctelería."*
2. **Cervecería de la Costa (8 sucursales oficiales Google Maps)**:
   - Costa Tercer Anillo (19.2828, -103.7325)
   - Costa San Fernando (19.2522, -103.7206)
   - Costa Ignacio Sandoval (19.2605, -103.7064)
   - Costa Pablo Silva, VDA (19.2664, -103.7491)
   - Costa Venustiano Carranza (19.2800, -103.7124)
   - Costa La Paz (19.2674, -103.7170)
   - Costa Griselda Álvarez, VDA (19.2750, -103.7510)
   - Costa Santa Fe (19.2892, -103.7250)
3. **Estación Colimita (2 sucursales oficiales Google Maps)**:
   - Estación Colimita Andador Centro (19.2439, -103.7275)
   - Estación Colimita Constitución (19.2578, -103.7158)
4. **Locales Centro**:
   - DMT Rock Bar (Degollado 28) (19.2430, -103.7270)
   - Dos Puntos (Degollado 34) (19.2432, -103.7272)
   - El Taurino (Filomeno Medina 12) (19.2445, -103.7295)
   - La Puerta Bar (27 de Septiembre 135) (19.2450, -103.7265)
   - Low Social Club (Calle Miguel Hidalgo 165) (19.2410, -103.7256)
5. **Locales Sandoval**:
   - Almada Cantina (Ignacio Sandoval 1906) (19.2625, -103.7048)
   - El Gustito (Ignacio Sandoval 1866) (19.2618, -103.7055)
6. **Otros Puntos Conurbados**:
   - La Regional (Sevilla del Río 534) (19.2542, -103.7180)
   - La Chintola (Blvd. Camino Real) (19.2460, -103.7100)
   - Santo Mezcal (Constitución 1999) (19.2615, -103.7120)
   - Taverna NY Pizza (Venustiano Carranza 1310) (19.2720, -103.7185)

7. **Easter Egg Exclusivo de Mapa — Barezzito (In Memoriam)**:
   - Eliminado por completo del Feed principal y buscador de locales.
   - Ubicación exacta real: Av. Constitución 1450, Jardines Vista Hermosa III, Colima (Lat: 19.2524, Lng: -103.7210).
   - Interacción discreta: Pin minimalista con etiqueta flotante que alterna secuencialmente cada toque entre `'💀'`, `'RIP'` y `'In Memoriam'` sin desplegar bottom sheet comercial.

*Nota de fidelidad de datos:* Cero mesas VIP inventadas (`isVipPresent: false` en taprooms, rock bars, pizzerías y cantinas).

---

## 3. 🔐 Fase 1: Autenticación, Telemetría de Presencia y Monetización

### 3.1 Autenticación Social & Modo Invitado (`lib/features/auth/`)
- **Modo Invitado Inmediato:** Navegación 100% libre sin bloqueos de registro obligatorio.
- **Google Sign-In:** Inicio de sesión social ágil para guardar favoritos y sincronizar perfil.
- **Botón de Perfil Reactivo:** Integrado en la barra superior del feed indicando el estado (`Invitado` o `Conectado como [Nombre]`), con acceso al modal de perfil.

### 3.2 Telemetría de Presencia en Vivo (Perímetro 80 metros)
- **Monitoreo en Tiempo Real:** Detección comunitaria de presencia activa en el perímetro de 80m de cada establecimiento.
- **Insignias Dinámicas:** Contadores visuales `👥 X en vivo` y `👥 X en vivo (80m)` en `HotRightNowCard`, `VenueCard` y `VenueDetailBottomSheet`.

### 3.3 Apoyo Comunitario al Estilo Patreon (`lib/features/monetization/`)
- **Transparencia Total:** Justificación clara sobre el financiamiento de servidores en tiempo real, cartografía y monitoreo de seguridad.
- **Niveles de Apoyo:**
  - $25 MXN: Cerveza Virtual 🍺 (Insignia Supporter Bronce).
  - $50 MXN: Ronda de Shots 🥃 (Insignia Supporter Plata).
  - $100 MXN: Mesa VIP Supporter 👑 (Corona Dorada VIP en perfil).
  - Patreon / Apoyo Libre: Enlace externo a pasarelas de pago.
- **Botón de Donativo:** Acceso rápido con ícono de corazón/apoyo en la barra superior del feed.

### 3.4 Publicidad Nativa Cyber-Night (Google AdMob Mockup)
- **Tarjeta Patrocinada (`CyberAdMobCard`):** Banner nativo con efecto Glassmorphism y bordes ámbar/cian intercalado cada 6 establecimientos en el feed principal.

---

## 4. 🏗️ Arquitectura de Carpetas (Clean Architecture + Feature-First)

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # Paleta Cyber-Night, gradientes y glows
│   │   ├── app_typography.dart     # Tipografías Syne, Outfit y Space Grotesk
│   │   └── app_theme.dart          # Configuración global de ThemeData Dark
│   └── widgets/
│       ├── glass_container.dart    # BackdropFilter con bordes translúcidos
│       ├── neon_badge.dart         # Píldoras dinámicas (% aforo, presencia en vivo, VIP, 2x1)
│       └── pulsing_glow.dart       # Efecto de respiración y aura neón
│
├── features/
│   ├── auth/
│   │   ├── domain/models/user_model.dart     # Modelo de usuario (Invitado, Social, Supporter)
│   │   └── presentation/
│   │       ├── providers/auth_provider.dart  # StateNotifier de sesión social y estatus supporter
│   │       └── widgets/auth_modal.dart       # Modal Glassmorphism de acceso y perfil
│   ├── monetization/
│   │   └── presentation/widgets/
│   │       ├── patreon_support_modal.dart    # Modal de apoyo comunitario Patreon ($25, $50, $100 MXN)
│   │       └── cyber_admob_card.dart         # Tarjeta publicitaria nativa Glassmorphism cada 6 locales
│   └── venues/
│       ├── domain/models/venue_model.dart    # Entidad de bar con telemetría de presencia y metadata
│       └── presentation/
│           ├── providers/venue_providers.dart # Riverpod (22 locales conurbados, aforo reactivo)
│           ├── widgets/
│           │   ├── filter_chips_bar.dart
│           │   ├── hot_right_now_card.dart   # Tarjeta Hero con aforo + telemetría en vivo
│           │   ├── venue_card.dart           # Tarjeta con insignia 👥 X en vivo
│           │   ├── venue_detail_bottom_sheet.dart # Detalle con telemetría en radio de 80m
│           │   └── faded_red_report_button.dart
│           └── views/
│               ├── discovery_feed_view.dart  # Feed con perfil, apoyo Patreon y ads intercalados
│               └── venue_detail_map_view.dart
│
└── main.dart                       # Entrypoint con ProviderScope y orientación fija
```

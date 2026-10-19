import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/venue_model.dart';
import '../providers/venue_providers.dart';
import '../widgets/venue_detail_bottom_sheet.dart';
import '../widgets/incident_report_modal.dart';

/// Estilos de mapas libres y gratuitos para visualización urbana en Colima y VDA
enum AppMapStyle {
  streets(
    label: 'Calles (OSM)',
    icon: Icons.map_rounded,
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    fallbackUrl: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  ),
  dark(
    label: 'Neón Noche',
    icon: Icons.nightlight_round,
    urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  ),
  voyager(
    label: 'Urbano',
    icon: Icons.explore_rounded,
    urlTemplate: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  final String label;
  final IconData icon;
  final String urlTemplate;
  final String fallbackUrl;
  const AppMapStyle({
    required this.label,
    required this.icon,
    required this.urlTemplate,
    required this.fallbackUrl,
  });
}

class VenueDetailMapView extends ConsumerStatefulWidget {
  final VenueModel venue;

  const VenueDetailMapView({
    super.key,
    required this.venue,
  });

  @override
  ConsumerState<VenueDetailMapView> createState() => _VenueDetailMapViewState();
}

class _VenueDetailMapViewState extends ConsumerState<VenueDetailMapView> {
  late String _selectedVenueId;
  final MapController _mapController = MapController();
  double _currentZoom = 15.2;
  int _barezzitoEasterEggStep = 0;
  static const List<String> _barezzitoNotes = ['💀', 'RIP', 'In Memoriam'];
  AppMapStyle _selectedMapStyle = AppMapStyle.streets;

  @override
  void initState() {
    super.initState();
    _selectedVenueId = widget.venue.id;
  }

  void _centerOnVenue(VenueModel venue) {
    setState(() {
      _selectedVenueId = venue.id;
    });
    _mapController.move(
      ll.LatLng(venue.latitude, venue.longitude),
      15.5,
    );
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showTestAforoModal(BuildContext context, VenueModel currentVenue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _TestAforoBottomSheet(
          venueId: currentVenue.id,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allVenues = ref.watch(mockVenuesProvider);
    final currentVenue = allVenues.firstWhere(
      (v) => v.id == _selectedVenueId,
      orElse: () => widget.venue,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Capa 1: Mapa Interactivo Gratuito (CartoDB / OpenStreetMap con fallback)
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: ll.LatLng(currentVenue.latitude, currentVenue.longitude),
                initialZoom: 15.2,
                minZoom: 12.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (camera, hasGesture) {
                  final zoom = camera.zoom;
                  if (zoom != null && (zoom - _currentZoom).abs() > 0.15) {
                    setState(() {
                      _currentZoom = zoom;
                    });
                  }
                },
              ),
              children: [
                // Capa de teselas libres con soporte de múltiples estilos y fallback automático
                TileLayer(
                  key: ValueKey<String>(_selectedMapStyle.name),
                  urlTemplate: _selectedMapStyle.urlTemplate,
                  fallbackUrl: _selectedMapStyle.fallbackUrl,
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.colimanight.app',
                  maxZoom: 19,
                ),

                // Capa de Marcadores Neón de los Antros y Bares + Easter Egg Discreto
                MarkerLayer(
                  markers: [
                    ...allVenues.map((v) {
                      final isSelected = v.id == currentVenue.id;
                      final showLabel = _currentZoom >= 14.0 || isSelected;
                      return Marker(
                        point: ll.LatLng(v.latitude, v.longitude),
                        width: showLabel ? (isSelected ? 200 : 170) : 36,
                        height: showLabel ? 65 : 36,
                        child: GestureDetector(
                          onTap: () => _centerOnVenue(v),
                          child: _MapVenuePin(
                            venue: v,
                            isSelected: isSelected,
                            showLabel: showLabel,
                          ),
                        ),
                      );
                    }),

                    // Easter Egg Discreto de Barezzito en Av. Constitución 1450 (19.2524, -103.7210)
                    Marker(
                      point: const ll.LatLng(19.2524, -103.7210),
                      width: _currentZoom >= 13.5 ? 100 : 30,
                      height: _currentZoom >= 13.5 ? 55 : 30,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _barezzitoEasterEggStep =
                                (_barezzitoEasterEggStep + 1) % _barezzitoNotes.length;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_currentZoom >= 13.5) ...[
                              // Nota flotante discreta que alterna secuencialmente
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(scale: animation, child: child),
                                ),
                                child: Container(
                                  key: ValueKey<int>(_barezzitoEasterEggStep),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14141F).withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24, width: 0.8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _barezzitoNotes[_barezzitoEasterEggStep],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            // Pin minimalista discreto
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C28).withOpacity(0.9),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 0.8),
                              ),
                              child: const Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: Color(0xFF8E8EA0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Capa 2: Barra Superior Flotante con Botón Atrás y Controles
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón Regresar Glassmorphism
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.85),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Badge de Zona Conurbada Colima & VDA
                        GlassContainer(
                          blur: 12,
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.neonCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Colima - VDA • Libre de Costo',
                                style: AppTypography.badgeLabel.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Botón Modo Pruebas / Simular Aforo y Reportes
                        GestureDetector(
                          onTap: () => _showTestAforoModal(context, currentVenue),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neonAmber),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonAmber.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tune_rounded, size: 16, color: AppColors.neonAmber),
                                const SizedBox(width: 4),
                                Text(
                                  'Probar Aforo',
                                  style: AppTypography.badgeLabel.copyWith(
                                    color: AppColors.neonAmber,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Barra flotante interactiva: Selector de Estilo de Mapa + Google Maps directo
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...AppMapStyle.values.map((style) {
                            final isCurrent = _selectedMapStyle == style;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedMapStyle = style),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.neonCyan.withOpacity(0.25)
                                      : AppColors.surface.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent ? AppColors.neonCyan : AppColors.glassBorder,
                                    width: isCurrent ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      style.icon,
                                      size: 13,
                                      color: isCurrent ? AppColors.neonCyan : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      style.label,
                                      style: TextStyle(
                                        color: isCurrent ? Colors.white : AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Botón directo a Google Maps para verificar georreferencias
                          GestureDetector(
                            onTap: () => _openInGoogleMaps(currentVenue.latitude, currentVenue.longitude),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.neonCyan.withOpacity(0.7)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.open_in_new_rounded, size: 13, color: AppColors.neonCyan),
                                  SizedBox(width: 4),
                                  Text(
                                    'Google Maps',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Botón para centrar en el establecimiento seleccionado
                          GestureDetector(
                            onTap: () => _centerOnVenue(currentVenue),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.my_location_rounded, size: 13, color: AppColors.neonCyan),
                                  SizedBox(width: 4),
                                  Text(
                                    'Centrar',
                                    style: TextStyle(
                                      color: AppColors.neonCyan,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Capa 3: Bottom Sheet Expandible tipo Uber/DiDi
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.26,
            maxChildSize: 0.88,
            builder: (context, scrollController) {
              return VenueDetailBottomSheet(
                venue: currentVenue,
                scrollController: scrollController,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Pin de mapa interactivo con halo neón y badge de aforo adaptativo por nivel de zoom
class _MapVenuePin extends StatelessWidget {
  final VenueModel venue;
  final bool isSelected;
  final bool showLabel;

  const _MapVenuePin({
    required this.venue,
    required this.isSelected,
    this.showLabel = true,
  });

  Color get _pinColor {
    if (venue.securityStatus == 'active_alert') return AppColors.neonRedAlert;
    if (venue.securityStatus == 'under_review') return AppColors.neonAmber;
    if (venue.capacityPercent >= 85) return const Color(0xFFFF5252);
    if (venue.hasLiveMusic) return AppColors.neonMagenta;
    if (venue.hasPromo) return AppColors.neonCyan;
    return AppColors.neonViolet;
  }

  @override
  Widget build(BuildContext context) {
    final color = _pinColor;

    // Zoom Lejano (sin etiqueta expandida): solo marcador compacto de alta visibilidad
    if (!showLabel) {
      return AnimatedScale(
        scale: isSelected ? 1.25 : 0.95,
        duration: const Duration(milliseconds: 200),
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : AppColors.surface.withOpacity(0.92),
              border: Border.all(
                color: isSelected ? Colors.white : color,
                width: isSelected ? 2.2 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.85 : 0.45),
                  blurRadius: isSelected ? 10 : 5,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: isSelected ? 18 : 15,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      );
    }

    // Zoom Cercano o Seleccionado: Nombre completo legible sin recorte y badge de aforo
    return AnimatedScale(
      scale: isSelected ? 1.12 : 0.96,
      duration: const Duration(milliseconds: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Etiqueta flotante con el nombre completo y % de aforo
          Container(
            constraints: const BoxConstraints(maxWidth: 195),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : AppColors.surface.withOpacity(0.94),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? color : AppColors.glassBorder,
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.75 : 0.25),
                  blurRadius: isSelected ? 12 : 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    venue.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.badgeLabel.copyWith(
                      color: Colors.white,
                      fontSize: isSelected ? 10.5 : 9.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${venue.capacityPercent}%',
                  style: AppTypography.badgeLabel.copyWith(
                    color: color,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // Icono de Pin Neón
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.35),
                  ),
                ),
              Icon(
                Icons.location_on_rounded,
                size: isSelected ? 28 : 22,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.9),
                    blurRadius: 10,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modal interactivo para que el usuario pueda probar y modificar aforos en caliente
class _TestAforoBottomSheet extends ConsumerStatefulWidget {
  final String venueId;

  const _TestAforoBottomSheet({required this.venueId});

  @override
  ConsumerState<_TestAforoBottomSheet> createState() => _TestAforoBottomSheetState();
}

class _TestAforoBottomSheetState extends ConsumerState<_TestAforoBottomSheet> {
  final TextEditingController _incidentController = TextEditingController();

  @override
  void dispose() {
    _incidentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final venues = ref.watch(mockVenuesProvider);
    final venue = venues.firstWhere((v) => v.id == widget.venueId, orElse: () => venues.first);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.neonAmber.withOpacity(0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMULADOR DE PRUEBAS',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.neonAmber),
                  ),
                  Text(
                    venue.name,
                    style: AppTypography.h3.copyWith(fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Control deslizante de Aforo %
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aforo en Tiempo Real:',
                style: AppTypography.bodyMedium,
              ),
              Text(
                '${venue.capacityPercent}%',
                style: AppTypography.h3.copyWith(color: AppColors.neonCyan),
              ),
            ],
          ),
          Slider(
            value: venue.capacityPercent.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.neonCyan,
            inactiveColor: Colors.white12,
            onChanged: (val) {
              ref.read(mockVenuesProvider.notifier).updateCapacity(venue.id, val.round());
            },
          ),
          const SizedBox(height: 10),

          // Toggles rápidos para Vibe
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: venue.hasLiveMusic ? AppColors.neonMagenta : Colors.white60,
                    side: BorderSide(
                      color: venue.hasLiveMusic ? AppColors.neonMagenta : Colors.white24,
                    ),
                  ),
                  onPressed: () {
                    ref.read(mockVenuesProvider.notifier).toggleLiveMusic(venue.id);
                  },
                  child: Text(venue.hasLiveMusic ? '🎸 Música Activa' : '🎸 Sin Música'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: venue.hasPromo ? AppColors.neonCyan : Colors.white60,
                    side: BorderSide(
                      color: venue.hasPromo ? AppColors.neonCyan : Colors.white24,
                    ),
                  ),
                  onPressed: () {
                    ref.read(mockVenuesProvider.notifier).togglePromo(venue.id);
                  },
                  child: Text(venue.hasPromo ? '⚡ 2x1 Activo' : '⚡ Sin Promo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Simulación de Reportes de Incidentes (Anti-Difamación & Consenso)
          Text(
            'PROBAR REPORTE ANÓNIMO DE INCIDENTE',
            style: AppTypography.badgeLabel.copyWith(color: AppColors.neonRedAlert),
          ),
          const SizedBox(height: 6),
          Text(
            'Estado actual: ${venue.securityStatus} (${venue.activeIncidentReportsCount} reportes)',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _incidentController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Ej. Pelea en la entrada con el cadenero...',
                    hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonRedAlert,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                ),
                onPressed: () {
                  final text = _incidentController.text.trim();
                  if (text.isEmpty) return;
                  final result = ref.read(mockVenuesProvider.notifier).submitIncidentReport(
                        venueId: venue.id,
                        incidentType: 'brawl',
                        rawText: text,
                      );
                  _incidentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.surfaceElevated,
                      content: Text(
                        'Resultado de Moderación: $result\n(Reporte ${venue.activeIncidentReportsCount + 1}/3)',
                        style: AppTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  );
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neonRedAlert,
                side: BorderSide(color: AppColors.neonRedAlert.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.category_rounded, size: 16),
              label: const Text(
                'Abrir Reporte de 4 Indicadores y Notas Rápidas',
                style: TextStyle(fontSize: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                IncidentReportModal.show(context, venue: venue);
              },
            ),
          ),
          if (venue.activeIncidentReportsCount > 0) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 16, color: AppColors.neonCyan),
              label: const Text('Restablecer Seguridad a Normal'),
              onPressed: () {
                ref.read(mockVenuesProvider.notifier).resetIncident(venue.id);
              },
            ),
          ],
        ],
      ),
    );
  }
}

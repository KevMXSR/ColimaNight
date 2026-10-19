import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../../../core/constants/colima_geo_constants.dart';
import '../../domain/models/nightlife_corridor.dart';
import '../../domain/models/venue_location.dart';
import '../../../geolocation/services/colima_location_service.dart';
import '../../../external_links/services/colima_deep_link_service.dart';

/// Vista principal del mapa nocturno de ColimaNight.
///
/// Integra la interfaz oscura (Dark Night), el selector horizontal de corredores
/// de Colima y Villa de Álvarez, visualización de pines por estado y la tarjeta
/// modal interactiva con accesos directos a WhatsApp, Uber, Waze e Instagram.
class NightlifeMapView extends StatefulWidget {
  final List<VenueLocation> venues;
  final List<NightlifeCorridor> corridors;

  const NightlifeMapView({
    super.key,
    required this.venues,
    required this.corridors,
  });

  @override
  State<NightlifeMapView> createState() => _NightlifeMapViewState();
}

class _NightlifeMapViewState extends State<NightlifeMapView> {
  final ColimaLocationService _locationService = ColimaLocationService();
  CorridorId? _selectedCorridor;
  VenueLocation? _activeVenue;
  ProximityEstimate? _activeProximityEstimate;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _requestUserLocation();
  }

  Future<void> _requestUserLocation() async {
    setState(() => _isLoadingLocation = true);
    await _locationService.checkAndRequestPermissions();
    setState(() => _isLoadingLocation = false);
  }

  void _onVenueSelected(VenueLocation venue) async {
    setState(() {
      _activeVenue = venue;
      _activeProximityEstimate = null;
    });

    // Simulación de cálculo de proximidad desde centro o GPS del usuario
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      final estimate = _locationService.calculateProximity(
        userLat: position.latitude,
        userLng: position.longitude,
        venue: venue,
      );
      setState(() {
        _activeProximityEstimate = estimate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Stack(
        children: [
          // 1. Capa de Mapa Oscuro (Google Maps / CartoDB Dark Matter)
          Positioned.fill(
            child: _buildMapCanvasPlaceholder(),
          ),

          // 2. Barra Superior Flotante: Selector de Corredores de Colima & VDA
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: _buildCorridorSelector(),
          ),

          // 3. Indicador de Mancha Urbana de Colima & Estado de Red
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 16,
            child: _buildAreaBadge(),
          ),

          // 4. Modal Inferior del Establecimiento Seleccionado
          if (_activeVenue != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildVenueDetailCard(_activeVenue!),
            ),
        ],
      ),
    );
  }

  Widget _buildMapCanvasPlaceholder() {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: ll.LatLng(ColimaGeoConstants.centerLatitude, ColimaGeoConstants.centerLongitude),
        initialZoom: ColimaGeoConstants.defaultZoom,
        minZoom: 11.0,
        maxZoom: 18.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          fallbackUrl: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.colimanight.app',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: widget.venues.map((venue) {
            final color = _parseColor(venue.statusColorHex);
            final isSelected = _activeVenue?.id == venue.id;
            return Marker(
              point: ll.LatLng(venue.coordinates.latitude, venue.coordinates.longitude),
              width: isSelected ? 160 : 36,
              height: isSelected ? 50 : 36,
              alignment: isSelected ? Alignment.topCenter : Alignment.center,
              child: GestureDetector(
                onTap: () => _onVenueSelected(venue),
                child: isSelected
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B26).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                venue.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_bar_rounded,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCorridorSelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: widget.corridors.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = _selectedCorridor == null;
            return _buildFilterChip(
              label: 'Todos los Corredores',
              isSelected: isAllSelected,
              icon: Icons.explore_rounded,
              onTap: () => setState(() => _selectedCorridor = null),
            );
          }
          final corridor = widget.corridors[index - 1];
          final isSelected = _selectedCorridor == corridor.id;
          return _buildFilterChip(
            label: corridor.name.split('(').first.trim(),
            isSelected: isSelected,
            onTap: () => setState(() => _selectedCorridor = corridor.id),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.18) : const Color(0xFF161C26),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white60,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF131924).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Colima - Villa de Álvarez (En Vivo)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueDetailCard(VenueLocation venue) {
    final statusColor = _parseColor(venue.statusColorHex);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: statusColor.withValues(alpha: 0.2),
            blurRadius: 15,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con Nombre y Botón de Cierre
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      venue.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                onPressed: () => setState(() => _activeVenue = null),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Indicadores de Estado y Aforo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      venue.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_activeProximityEstimate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation_rounded, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '${_activeProximityEstimate!.formattedDistance} • ${_activeProximityEstimate!.drivingEtaMinutes} min auto',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Promoción activa o Música
          if (venue.activePromotion.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.local_offer_rounded, size: 14, color: Color(0xFFFFD600)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    venue.activePromotion,
                    style: const TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 14),

          // Botones de Acción Rápida (Navegación, Uber, WhatsApp, Instagram)
          Row(
            children: [
              // Botón Cómo Llegar (Google Maps / Waze)
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  icon: const Icon(Icons.directions_car_rounded, size: 18),
                  label: const Text(
                    'Cómo llegar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () => ColimaDeepLinkService.navigateWithGoogleMaps(
                    destinationLat: venue.coordinates.latitude,
                    destinationLng: venue.coordinates.longitude,
                    venueName: venue.name,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Botón Uber
              _buildIconActionButton(
                icon: Icons.local_taxi_rounded,
                tooltip: 'Pedir Uber',
                color: Colors.white,
                bgColor: const Color(0xFF222836),
                onTap: () => ColimaDeepLinkService.requestUberRide(
                  destinationLat: venue.coordinates.latitude,
                  destinationLng: venue.coordinates.longitude,
                  venueName: venue.name,
                ),
              ),
              const SizedBox(width: 8),

              // Botón WhatsApp Reservaciones
              if (venue.whatsappNumber != null) ...[
                _buildIconActionButton(
                  icon: Icons.chat_rounded,
                  tooltip: 'Reservar por WhatsApp',
                  color: const Color(0xFF25D366),
                  bgColor: const Color(0xFF152A20),
                  onTap: () => ColimaDeepLinkService.openWhatsAppReservation(
                    rawPhoneNumber: venue.whatsappNumber!,
                    venueName: venue.name,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Botón Instagram
              if (venue.instagramHandle != null)
                _buildIconActionButton(
                  icon: Icons.camera_alt_rounded,
                  tooltip: 'Instagram Oficial',
                  color: const Color(0xFFE1306C),
                  bgColor: const Color(0xFF2C1625),
                  onTap: () => ColimaDeepLinkService.openInstagramProfile(venue.instagramHandle!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

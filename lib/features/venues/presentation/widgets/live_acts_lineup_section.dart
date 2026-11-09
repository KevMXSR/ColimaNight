import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/monetization_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_venue_image.dart';
import '../../domain/models/venue_model.dart';
import '../providers/venue_providers.dart';
import 'venue_detail_bottom_sheet.dart';

/// Género musical adaptativo para la cartelera en vivo
enum LiveMusicGenreType {
  rock,
  techHouse,
  perreo,
  craftIndie,
  mariachiAcoustic,
  sportsLive;

  String get label {
    switch (this) {
      case LiveMusicGenreType.rock:
        return 'ROCK & METAL';
      case LiveMusicGenreType.techHouse:
        return 'TECH-HOUSE & DJS';
      case LiveMusicGenreType.perreo:
        return 'PERREO & URBANO';
      case LiveMusicGenreType.craftIndie:
        return 'INDIE & VINYL';
      case LiveMusicGenreType.mariachiAcoustic:
        return 'MARIACHI & BOHEMIA';
      case LiveMusicGenreType.sportsLive:
        return 'TRANSMISIÓN DEPORTIVA HD';
    }
  }

  Color get primaryColor {
    switch (this) {
      case LiveMusicGenreType.rock:
        return const Color(0xFFF97316); // Naranja fuego
      case LiveMusicGenreType.techHouse:
        return const Color(0xFF00FFCC); // Neón cian
      case LiveMusicGenreType.perreo:
        return const Color(0xFFF43F5E); // Rosa / Magenta urbano
      case LiveMusicGenreType.craftIndie:
        return const Color(0xFF2DD4BF); // Teal craft
      case LiveMusicGenreType.mariachiAcoustic:
        return const Color(0xFFFBBF24); // Ámbar dorado
      case LiveMusicGenreType.sportsLive:
        return const Color(0xFF10B981); // Verde esmeralda deportivo
    }
  }

  Color get secondaryColor {
    switch (this) {
      case LiveMusicGenreType.rock:
        return const Color(0xFFEF4444);
      case LiveMusicGenreType.techHouse:
        return const Color(0xFFA855F7);
      case LiveMusicGenreType.perreo:
        return const Color(0xFFFACC15);
      case LiveMusicGenreType.craftIndie:
        return const Color(0xFF38BDF8);
      case LiveMusicGenreType.mariachiAcoustic:
        return const Color(0xFFD97706);
      case LiveMusicGenreType.sportsLive:
        return const Color(0xFF34D399);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LiveMusicGenreType.rock:
        return const Color(0xFF221008);
      case LiveMusicGenreType.techHouse:
        return const Color(0xFF071224);
      case LiveMusicGenreType.perreo:
        return const Color(0xFF200713);
      case LiveMusicGenreType.craftIndie:
        return const Color(0xFF06181A);
      case LiveMusicGenreType.mariachiAcoustic:
        return const Color(0xFF1C1304);
      case LiveMusicGenreType.sportsLive:
        return const Color(0xFF042014);
    }
  }

  IconData get icon {
    switch (this) {
      case LiveMusicGenreType.rock:
        return Icons.electric_bolt_rounded;
      case LiveMusicGenreType.techHouse:
        return Icons.graphic_eq_rounded;
      case LiveMusicGenreType.perreo:
        return Icons.whatshot_rounded;
      case LiveMusicGenreType.craftIndie:
        return Icons.album_rounded;
      case LiveMusicGenreType.mariachiAcoustic:
        return Icons.music_note_rounded;
      case LiveMusicGenreType.sportsLive:
        return Icons.sports_soccer_rounded;
    }
  }

  TextStyle get titleStyle {
    switch (this) {
      case LiveMusicGenreType.rock:
        return const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: Colors.white,
          fontFamily: 'Montserrat',
        );
      case LiveMusicGenreType.techHouse:
        return const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: Colors.white,
        );
      case LiveMusicGenreType.perreo:
        return const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.4,
        );
      case LiveMusicGenreType.craftIndie:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        );
      case LiveMusicGenreType.mariachiAcoustic:
        return const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.2,
        );
      case LiveMusicGenreType.sportsLive:
        return const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.4,
        );
    }
  }
}

/// Elemento representativo de un acto en vivo
class _LiveActEntry {
  final String id;
  final String actName;
  final String venueName;
  final String zone;
  final String dateDisplay;
  final LiveMusicGenreType genreType;
  final String highlightText;
  final String? promoNote;
  final String? sourceInstagramUrl;
  final String? sourceInstagramHandle;
  final String? sourceFacebookUrl;
  final bool isPresaleActive;
  final String? presalePrice;
  final String? presaleUrl;
  final bool isSportsMatch;
  final String? matchTeams;
  final String? broadcastDetails;
  final bool isVideoStory;
  final VenueModel venue;
  final VenueEvent? event;

  const _LiveActEntry({
    required this.id,
    required this.actName,
    required this.venueName,
    required this.zone,
    required this.dateDisplay,
    required this.genreType,
    required this.highlightText,
    this.promoNote,
    this.sourceInstagramUrl,
    this.sourceInstagramHandle,
    this.sourceFacebookUrl,
    this.isPresaleActive = false,
    this.presalePrice,
    this.presaleUrl,
    this.isSportsMatch = false,
    this.matchTeams,
    this.broadcastDetails,
    this.isVideoStory = false,
    required this.venue,
    this.event,
  });
}

/// Sección dinámica de Música en Vivo que adapta tipografía, paletas de neón
/// y bloques de anuncios según el estilo musical de cada artista / DJ.
class LiveActsLineupSection extends ConsumerWidget {
  const LiveActsLineupSection({super.key});

  List<_LiveActEntry> _buildEntries(List<VenueModel> venues) {
    final List<_LiveActEntry> entries = [];

    for (final venue in venues) {
      if (!venue.hasLiveMusic && venue.upcomingEvents.isEmpty) continue;

      // 1. Foro DMT (Rock & Indie + Preventa verificada)
      if (venue.id == 'foro_dmt') {
        final ev = venue.upcomingEvents.firstWhere(
          (e) => e.id == 'foro_dmt_rock_friday',
          orElse: () => venue.upcomingEvents.isNotEmpty ? venue.upcomingEvents.first : _dummyEvent(venue),
        );
        entries.add(_LiveActEntry(
          id: 'act_foro_dmt',
          actName: 'Bandas Locales & Noche de Rock en Vivo',
          venueName: venue.name,
          zone: 'Centro Histórico (Degollado 50)',
          dateDisplay: ev.dateDisplay,
          genreType: LiveMusicGenreType.rock,
          highlightText: 'Tributos en vivo, rock en español, grunge y cerveza artesanal fría.',
          promoNote: 'Entrada libre antes de las 10 PM • Cubetazo especial',
          sourceInstagramUrl: ev.sourceInstagramUrl ?? 'https://www.instagram.com/foro_dmt/',
          sourceInstagramHandle: ev.sourceInstagramHandle ?? '@foro_dmt',
          sourceFacebookUrl: ev.sourceFacebookUrl ?? venue.facebookUrl,
          isPresaleActive: ev.isPresaleActive,
          presalePrice: ev.presalePrice ?? 'Preventa: \$120 MXN • Taquilla: \$180 MXN',
          presaleUrl: ev.presaleUrl,
          venue: venue,
          event: ev,
        ));
      }

      // 2. Low Social Club (Tech-House + Preventa verificada)
      else if (venue.id == 'low_social_club') {
        final ev = venue.upcomingEvents.isNotEmpty ? venue.upcomingEvents.first : _dummyEvent(venue);
        entries.add(_LiveActEntry(
          id: 'act_low_social',
          actName: 'DJ Residente • Sets Tech-House & Afro-House',
          venueName: venue.name,
          zone: 'Av. Constitución',
          dateDisplay: ev.dateDisplay,
          genreType: LiveMusicGenreType.techHouse,
          highlightText: 'Música electrónica underground 128 BPM, visuales envolventes y sonido club.',
          promoNote: '2x1 en mixología y acceso antes de medianoche',
          sourceInstagramUrl: ev.sourceInstagramUrl ?? 'https://www.instagram.com/lowclub.col/',
          sourceInstagramHandle: ev.sourceInstagramHandle ?? '@lowclub.col',
          sourceFacebookUrl: ev.sourceFacebookUrl ?? venue.facebookUrl,
          isPresaleActive: ev.isPresaleActive,
          presalePrice: ev.presalePrice ?? 'Preventa: \$100 MXN (Incluye Drink)',
          presaleUrl: ev.presaleUrl,
          venue: venue,
          event: ev,
        ));
      }

      // 3. Guachi Rooftop (Sunset Electronic Sessions)
      else if (venue.id == 'el_guachi') {
        final ev = venue.upcomingEvents.isNotEmpty ? venue.upcomingEvents.first : _dummyEvent(venue);
        entries.add(_LiveActEntry(
          id: 'act_guachi',
          actName: 'Sunset Sessions • Deep House & Mixología',
          venueName: 'Guachi Rooftop',
          zone: 'Tercer Anillo Periférico',
          dateDisplay: ev.dateDisplay,
          genreType: LiveMusicGenreType.techHouse,
          highlightText: 'Sesión de atardecer con vista panorámica, coctelería y DJs invitados.',
          promoNote: '2x1 en coctelería de autor antes de las 9:00 PM',
          sourceInstagramUrl: ev.sourceInstagramUrl ?? 'https://www.instagram.com/guachirooftop/',
          sourceInstagramHandle: ev.sourceInstagramHandle ?? '@guachirooftop',
          sourceFacebookUrl: venue.facebookUrl,
          venue: venue,
          event: ev,
        ));
      }

      // 4. Bar La Puerta: Snacks & Drinks Oficial + La Puerta del Perreo (@lapuertadelperreo.dog)
      else if (venue.id == 'bar_la_puerta' || venue.id == 'la_puerta_bar') {
        final evSnacks = venue.upcomingEvents.firstWhere(
          (e) => e.id == 'puerta_jueves_snacks_drinks',
          orElse: () => venue.upcomingEvents.isNotEmpty ? venue.upcomingEvents.first : _dummyEvent(venue),
        );
        entries.add(_LiveActEntry(
          id: 'act_bar_la_puerta',
          actName: 'DJ Sets Perreo Old School & Snacks',
          venueName: venue.name,
          zone: 'Centro Histórico Colima',
          dateDisplay: evSnacks.dateDisplay,
          genreType: LiveMusicGenreType.perreo,
          highlightText: 'Noche de snacks y drinks a partir de las 7:00 PM, caguamas bien frías y perreo clásico.',
          promoNote: 'Jueves: Snacks y Drinks a partir de las 7:00 PM',
          sourceInstagramUrl: evSnacks.sourceInstagramUrl ?? 'https://www.instagram.com/barlapuerta/',
          sourceInstagramHandle: evSnacks.sourceInstagramHandle ?? '@barlapuerta',
          sourceFacebookUrl: venue.facebookUrl,
          venue: venue,
          event: evSnacks,
        ));

        // Segundo perfil verificado: @lapuertadelperreo.dog
        final evPerreo = venue.upcomingEvents.firstWhere(
          (e) => e.id == 'puerta_perreo_bellako',
          orElse: () => evSnacks,
        );
        if (evPerreo.id == 'puerta_perreo_bellako') {
          entries.add(_LiveActEntry(
            id: 'act_puerta_del_perreo',
            actName: 'La Puerta del Perreo • Bellakeo Underground',
            venueName: '${venue.name} • Perreo Dog',
            zone: 'Centro Histórico (27 de Septiembre)',
            dateDisplay: evPerreo.dateDisplay,
            genreType: LiveMusicGenreType.perreo,
            highlightText: 'Sesión underground de reggaetón bellako, perreo sucio y ambiente festivo exclusivo.',
            promoNote: evPerreo.promoNote ?? 'Shots de cortesía y caguamas especiales toda la noche',
            sourceInstagramUrl: evPerreo.sourceInstagramUrl ?? 'https://www.instagram.com/lapuertadelperreo.dog/',
            sourceInstagramHandle: evPerreo.sourceInstagramHandle ?? '@lapuertadelperreo.dog',
            sourceFacebookUrl: venue.facebookUrl,
            venue: venue,
            event: evPerreo,
          ));
        }
      }

      // 5. Cervecería de la Costa Carranza (Transmisión Fútbol en Pantalla)
      else if (venue.id == 'costa_carranza') {
        final evSports = venue.upcomingEvents.firstWhere(
          (e) => e.isSportsMatch,
          orElse: () => venue.upcomingEvents.isNotEmpty ? venue.upcomingEvents.first : _dummyEvent(venue),
        );
        entries.add(_LiveActEntry(
          id: 'act_costa_carranza_futbol',
          actName: '⚽ Transmisión en Pantalla • Clásico Nacional',
          venueName: venue.name,
          zone: 'Venustiano Carranza (Esmeralda Norte)',
          dateDisplay: evSports.dateDisplay,
          genreType: LiveMusicGenreType.sportsLive,
          highlightText: 'Chivas vs América en pantalla al aire libre, audio ambiente y cubetazos.',
          promoNote: evSports.promoNote ?? 'Cubetazos 5x4 en Cerveza de la Costa durante el partido',
          sourceInstagramUrl: evSports.sourceInstagramUrl ?? 'https://www.instagram.com/cerveceriadelacosta/',
          sourceInstagramHandle: evSports.sourceInstagramHandle ?? '@cerveceriadelacosta',
          sourceFacebookUrl: evSports.sourceFacebookUrl ?? venue.facebookUrl,
          isSportsMatch: true,
          matchTeams: evSports.matchTeams ?? 'CHIVAS vs AMÉRICA (Clásico Nacional)',
          broadcastDetails: evSports.broadcastDetails ?? 'Transmisión en Pantalla al aire libre + Audio Ambiente',
          isVideoStory: true,
          venue: venue,
          event: evSports,
        ));
      }

      // 6. Dos Puntos (Indie & Vinyl Taproom)
      else if (venue.id == 'dos_puntos') {
        final ev = venue.upcomingEvents.isNotEmpty ? venue.upcomingEvents.first : _dummyEvent(venue);
        entries.add(_LiveActEntry(
          id: 'act_dos_puntos',
          actName: 'DJ Set en Terraza & Mezclas Funk / Indie',
          venueName: venue.name,
          zone: 'Santos Degollado (Centro)',
          dateDisplay: ev.dateDisplay,
          genreType: LiveMusicGenreType.craftIndie,
          highlightText: 'Jardín cervecero al aire libre, selección en vinilo y pizzas de autor.',
          promoNote: '2x1 en pints seleccionadas de 7:00 a 9:00 PM',
          sourceInstagramUrl: ev.sourceInstagramUrl ?? 'https://www.instagram.com/dospuntoscerveceria/',
          sourceInstagramHandle: ev.sourceInstagramHandle ?? '@dospuntoscerveceria',
          sourceFacebookUrl: venue.facebookUrl,
          venue: venue,
          event: ev,
        ));
      }

      // 7. Almada Cantina Fina (Mariachi & Bohemia)
      else if (venue.id == 'almada_cantina') {
        entries.add(_LiveActEntry(
          id: 'act_almada',
          actName: 'Mariachi & Banda Acústica en Vivo',
          venueName: venue.name,
          zone: 'Residencial Las Pérgolas (Ignacio Sandoval)',
          dateDisplay: 'Viernes & Sábados • 21:00 hrs',
          genreType: LiveMusicGenreType.mariachiAcoustic,
          highlightText: 'Ambiente de cantina contemporánea, platillos de autor y mariachi en vivo.',
          promoNote: 'Copeo tradicional y servicio de botellas',
          sourceInstagramUrl: 'https://www.instagram.com/almada_cantina.fina/',
          sourceInstagramHandle: venue.instagramHandle,
          sourceFacebookUrl: venue.facebookUrl,
          venue: venue,
          event: null,
        ));
      }
    }

    return entries;
  }

  VenueEvent _dummyEvent(VenueModel venue) {
    return VenueEvent(
      id: '${venue.id}_live',
      title: venue.liveMusicAct ?? 'Música en Vivo',
      dateDisplay: 'Fin de Semana • Noche',
      artistOrDj: venue.liveMusicAct,
      sourceInstagramUrl: venue.instagramHandle != null
          ? 'https://www.instagram.com/${venue.instagramHandle!.replaceAll('@', '')}/'
          : null,
      sourceInstagramHandle: venue.instagramHandle,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venues = ref.watch(mockVenuesProvider);
    final entries = _buildEntries(venues);

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera estilizada de la Cartelera de Música en Vivo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceElevated,
                  AppColors.surfaceElevated.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonCyan.withOpacity(0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.neonCyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CARTELERA DE MÚSICA EN VIVO & DJS',
                            style: AppTypography.badgeLabel.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.neonCyan,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVA',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Alineación con estilo adaptativo por género: Rock, Tech-House, Perreo y Acústico',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bloques adaptativos de cada Artista / Banda / DJ
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = entries[index];
              return _LiveActCard(item: item);
            },
          ),
        ],
      ),
    );
  }
}

/// Tarjeta adaptativa con diseño y tipografía específica por género musical
class _LiveActCard extends StatelessWidget {
  final _LiveActEntry item;

  const _LiveActCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final genre = item.genreType;
    final primary = genre.primaryColor;
    final secondary = genre.secondaryColor;

    return Container(
      decoration: BoxDecoration(
        color: genre.backgroundColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary.withOpacity(0.55),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Fila Superior: Badge de Género + Badge de Fecha Programada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge del Género
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primary.withOpacity(0.8), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(genre.icon, size: 12, color: primary),
                          const SizedBox(width: 4),
                          Text(
                            genre.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge de Fecha y Horario
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: secondary.withOpacity(0.6), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 11, color: secondary),
                          const SizedBox(width: 4),
                          Text(
                            item.dateDisplay,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 2. Bloque Central: Nombre del Artista / Banda con tipografía adaptativa
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.actName,
                      style: genre.titleStyle,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => VenueDetailBottomSheet.show(context, item.venue),
                      child: Row(
                        children: [
                          const Icon(Icons.place_rounded, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.venueName} • ${item.zone}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.highlightText,
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    if (item.venue.hasPromo && item.promoNote != null && item.promoNote!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonAmber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.neonAmber.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_offer_rounded, size: 12, color: AppColors.neonAmber),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                item.promoNote!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neonAmber,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Banner de Preventa Verificada si está activa
                if (item.isPresaleActive) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.neonViolet.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.neonViolet.withOpacity(0.6), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.confirmation_number_rounded, size: 15, color: AppColors.neonViolet),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PREVENTA DISPONIBLE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: AppColors.neonViolet,
                                ),
                              ),
                              if (item.presalePrice != null)
                                Text(
                                  item.presalePrice!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (item.presaleUrl != null && item.presaleUrl!.isNotEmpty)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonViolet,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                            ),
                            onPressed: () => MonetizationConfig.launchUrlSafe(item.presaleUrl!),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_activity_rounded, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'Comprar',
                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Banner de Transmisión Deportiva (Fútbol / Champions / Boxeo en Pantalla Gigante)
                if (item.isSportsMatch) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_soccer_rounded, size: 16, color: Color(0xFF34D399)),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.matchTeams ?? 'PARTIDO EN VIVO',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF34D399),
                                ),
                              ),
                              if (item.broadcastDetails != null)
                                Text(
                                  item.broadcastDetails!,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'TRANSMISIÓN EN PANTALLA',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // 3. Fila de Acciones: "Ver Lugar", "Instagram", "Facebook" y "Cómo llegar / Ride"
                Row(
                  children: [
                    // Botón Ver Establecimiento
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: primary.withOpacity(0.7)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: primary.withOpacity(0.08),
                        ),
                        onPressed: () => VenueDetailBottomSheet.show(context, item.venue),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.nightlife_rounded, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'Ver Local',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Botón Instagram si existe
                    if (item.sourceInstagramUrl != null) ...[
                      InkWell(
                        onTap: () => MonetizationConfig.launchUrlSafe(item.sourceInstagramUrl!),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                item.sourceInstagramHandle ?? 'IG',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Botón Facebook si existe
                    if (item.sourceFacebookUrl != null || item.venue.facebookUrl != null) ...[
                      InkWell(
                        onTap: () => MonetizationConfig.launchUrlSafe(item.sourceFacebookUrl ?? item.venue.facebookUrl!),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1877F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.facebook_rounded, size: 15, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Botón Cómo Llegar (Google Maps / Ride)
                    InkWell(
                      onTap: () {
                        final mapsUrl =
                            'https://www.google.com/maps/dir/?api=1&destination=${item.venue.latitude},${item.venue.longitude}';
                        MonetizationConfig.launchUrlSafe(mapsUrl);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.directions_car_rounded, size: 14, color: AppColors.neonCyan),
                            SizedBox(width: 4),
                            Text(
                              'Ruta',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonCyan,
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
        ),
      ),
    );
  }
}

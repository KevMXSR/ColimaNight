import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/venue_model.dart';
import '../providers/venue_providers.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/hot_right_now_card.dart';
import '../widgets/venue_card.dart';
import '../widgets/venue_compact_list_tile.dart';
import '../widgets/top_ranking_podium_bar.dart';
import '../widgets/faded_red_report_button.dart';
import 'venue_detail_map_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_modal.dart';
import '../../../monetization/presentation/widgets/patreon_support_modal.dart';
import '../../../monetization/presentation/widgets/cyber_admob_card.dart';

class DiscoveryFeedView extends ConsumerWidget {
  const DiscoveryFeedView({super.key});

  void _navigateToDetail(BuildContext context, WidgetRef ref, VenueModel venue) {
    ref.read(selectedVenueProvider.notifier).state = venue;
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            VenueDetailMapView(venue: venue),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allVenues = ref.watch(mockVenuesProvider);
    final filteredVenues = ref.watch(filteredVenuesProvider);
    final hotVenue = ref.watch(hotRightNowVenueProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final user = ref.watch(authProvider);
    final viewMode = ref.watch(feedViewModeProvider);
    final topRanked = ref.watch(topRankedVenuesProvider);

    // Evita duplicar en el listado inferior al establecimiento que ya está destacado en "Hot Right Now"
    final displayVenues = hotVenue != null && searchQuery.isEmpty
        ? filteredVenues.where((v) => v.id != hotVenue.id).toList()
        : filteredVenues;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Principal con Logo Neón y Status Nocturno
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'COLIMA',
                              style: AppTypography.heroDisplay.copyWith(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'NIGHT',
                              style: AppTypography.heroDisplay.copyWith(
                                fontSize: 24,
                                color: AppColors.neonCyan,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.neonRedAlert,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonRedAlert,
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Colima & Villa de Álvarez • En Vivo',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Acciones Rápidas del Header (Apoyo Patreon, Perfil/Auth, Mapa)
                    Row(
                      children: [
                        // Botón Apoyo Comunitario / Patreon
                        GestureDetector(
                          onTap: () => PatreonSupportModal.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.neonAmber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neonAmber.withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonAmber.withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.favorite_rounded, color: AppColors.neonAmber, size: 16),
                                if (user.isSupporter) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star_rounded, color: AppColors.neonAmber, size: 14),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Botón de Perfil / Autenticación Social (Invitado vs Conectado)
                        GestureDetector(
                          onTap: () => AuthModal.show(
                            context,
                            onOpenSupporterModal: () => PatreonSupportModal.show(context),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: user.isGuest
                                  ? AppColors.surfaceElevated.withOpacity(0.8)
                                  : AppColors.neonViolet.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: user.isGuest ? AppColors.glassBorder : AppColors.neonViolet,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                                  color: user.isGuest ? AppColors.textSecondary : AppColors.neonCyan,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 72),
                                  child: Text(
                                    user.isGuest ? 'Invitado' : user.displayName.split(' ').first,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.badgeLabel.copyWith(
                                      color: user.isGuest ? AppColors.textSecondary : Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Botón para saltar al mapa completo
                        GestureDetector(
                          onTap: () {
                            final target = hotVenue ??
                                (filteredVenues.isNotEmpty ? filteredVenues.first : allVenues.first);
                            _navigateToDetail(context, ref, target);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.neonViolet.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neonViolet.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.map_outlined, color: AppColors.neonCyan, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  'Mapa',
                                  style: AppTypography.bodyBold.copyWith(
                                    color: AppColors.neonCyan,
                                    fontSize: 12,
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

            // Barra de Búsqueda Interactiva en Tiempo Real
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: GlassContainer(
                  blur: 10,
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  fillColor: AppColors.surfaceElevated.withOpacity(0.7),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.neonCyan, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            ref.read(searchQueryProvider.notifier).state = val;
                          },
                          style: AppTypography.bodyLarge.copyWith(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Buscar antro, DJ, banda o zona...',
                            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Barra de Chips de Filtros Rápidos
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: FilterChipsBar(),
              ),
            ),

            // Sección "HOT RIGHT NOW" (Visible si no hay búsqueda activa)
            if (searchQuery.isEmpty && hotVenue != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.whatshot_rounded, color: AppColors.neonRedAlert, size: 20),
                          const SizedBox(width: 6),
                          Text('HOT RIGHT NOW', style: AppTypography.h3),
                        ],
                      ),
                      Text(
                        'Mayor afluencia hoy',
                        style: AppTypography.caption.copyWith(color: AppColors.neonAmber),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HotRightNowCard(
                  venue: hotVenue,
                  onTap: () => _navigateToDetail(context, ref, hotVenue),
                ),
              ),
            ],

            // Podio / Carrusel Horizontal "Top Ranking de Hoy" (Top 5 más concurridos)
            if (searchQuery.isEmpty && topRanked.isNotEmpty)
              SliverToBoxAdapter(
                child: TopRankingPodiumBar(
                  topVenues: topRanked,
                  onVenueTap: (v) => _navigateToDetail(context, ref, v),
                ),
              ),

            // Encabezado de la Lista con Selector de Modo Dual (Fotos Inmersivas vs Lista Compacta)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      searchQuery.isEmpty ? 'EXPLORA LA NOCHE' : 'RESULTADOS',
                      style: AppTypography.h3.copyWith(
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        // Selector de Vista (Fotos vs Lista Top)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => ref.read(feedViewModeProvider.notifier).state = ViewMode.cards,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: viewMode == ViewMode.cards
                                        ? AppColors.neonCyan.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: viewMode == ViewMode.cards
                                          ? AppColors.neonCyan
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.view_agenda_rounded,
                                        size: 13,
                                        color: viewMode == ViewMode.cards
                                            ? AppColors.neonCyan
                                            : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Fotos',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: viewMode == ViewMode.cards
                                              ? Colors.white
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref.read(feedViewModeProvider.notifier).state = ViewMode.compact,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: viewMode == ViewMode.compact
                                        ? AppColors.neonAmber.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: viewMode == ViewMode.compact
                                          ? AppColors.neonAmber
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.view_headline_rounded,
                                        size: 13,
                                        color: viewMode == ViewMode.compact
                                            ? AppColors.neonAmber
                                            : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Lista Top',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: viewMode == ViewMode.compact
                                              ? Colors.white
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${displayVenues.length} lugares',
                          style: AppTypography.caption.copyWith(color: AppColors.neonCyan),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Lista de Establecimientos (Renderiza modo inmersivo de tarjetas o modo compacto según la preferencia)
            if (displayVenues.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'No encontramos lugares con esos filtros',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Intenta seleccionando otra categoría o limpiando la búsqueda.',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              )
            else
              Builder(
                builder: (context) {
                  final List<Widget> feedWidgets = [];
                  for (int i = 0; i < displayVenues.length; i++) {
                    final venue = displayVenues[i];
                    feedWidgets.add(
                      viewMode == ViewMode.cards
                          ? VenueCard(
                              venue: venue,
                              onTap: () => _navigateToDetail(context, ref, venue),
                            )
                          : VenueCompactListTile(
                              venue: venue,
                              rankNumber: i + 1,
                              onTap: () => _navigateToDetail(context, ref, venue),
                            ),
                    );
                    // Intercala tarjeta publicitaria nativa Cyber-Night cada 6 establecimientos
                    if ((i + 1) % 6 == 0 && (i + 1) < displayVenues.length) {
                      feedWidgets.add(
                        CyberAdMobCard(index: (i + 1) ~/ 6),
                      );
                    }
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => feedWidgets[index],
                      childCount: feedWidgets.length,
                    ),
                  );
                },
              ),

            // Botón con tono rojo desvanecido al final de la pantalla para reportes anónimos
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: FadedRedReportButton(),
              ),
            ),

            // Margen inferior
            const SliverToBoxAdapter(
              child: SizedBox(height: 50),
            ),
          ],
        ),
      ),
    );
  }
}

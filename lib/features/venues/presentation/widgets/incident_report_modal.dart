import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/venue_model.dart';
import '../providers/venue_providers.dart';

enum IncidentCategory {
  brawl(
    id: 'brawl',
    title: 'Riña o pelea',
    subtitle: 'Altercado físico o conato de bronca',
    icon: Icons.sports_mma_rounded,
    color: AppColors.neonRedAlert,
  ),
  weapon(
    id: 'weapon',
    title: 'Avistamiento de armas',
    subtitle: 'Símbolo de alerta: reporte de arma',
    icon: Icons.crisis_alert_rounded,
    color: Color(0xFFFF1744),
  ),
  slowService(
    id: 'slow_service',
    title: 'Servicio lento',
    subtitle: 'Demoras excesivas en barras o mesas',
    icon: Icons.hourglass_bottom_rounded,
    color: AppColors.neonAmber,
  ),
  other(
    id: 'other',
    title: 'Otro motivo',
    subtitle: 'Detalla con notas rápidas o texto libre',
    icon: Icons.edit_note_rounded,
    color: AppColors.neonCyan,
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const IncidentCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class IncidentReportModal extends ConsumerStatefulWidget {
  final VenueModel? preselectedVenue;

  const IncidentReportModal({
    super.key,
    this.preselectedVenue,
  });

  static Future<void> show(BuildContext context, {VenueModel? venue}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncidentReportModal(preselectedVenue: venue),
    );
  }

  @override
  ConsumerState<IncidentReportModal> createState() => _IncidentReportModalState();
}

class _IncidentReportModalState extends ConsumerState<IncidentReportModal> {
  late String _selectedVenueId;
  IncidentCategory? _selectedCategory;
  final TextEditingController _detailsController = TextEditingController();

  // Notas rápidas precargadas sugeridas por el usuario
  final List<String> _quickNotes = [
    'Mucho calor',
    'Cargo indebido en la cuenta',
    'Baños sucios',
    'Música a volumen excesivo',
    'Fila detenida en puerta',
    'Falta de hielo / bebidas agotadas',
  ];

  @override
  void initState() {
    super.initState();
    final venues = ref.read(mockVenuesProvider);
    _selectedVenueId = widget.preselectedVenue?.id ??
        (venues.isNotEmpty ? venues.first.id : '');
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Text(
            'Por favor selecciona uno de los 4 motivos de reporte.',
            style: AppTypography.caption.copyWith(color: AppColors.neonRedAlert),
          ),
        ),
      );
      return;
    }

    final venues = ref.read(mockVenuesProvider);
    final targetVenue = venues.firstWhere(
      (v) => v.id == _selectedVenueId,
      orElse: () => venues.first,
    );

    final rawText = _detailsController.text.trim();
    final fallbackText = rawText.isNotEmpty
        ? rawText
        : _selectedCategory!.title;

    final feedback = ref.read(mockVenuesProvider.notifier).submitIncidentReport(
          venueId: targetVenue.id,
          incidentType: _selectedCategory!.id,
          rawText: fallbackText,
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F0D14),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _selectedCategory!.color.withOpacity(0.6)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_selectedCategory!.icon, color: _selectedCategory!.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Reporte Procesado con Éxito (100% Anónimo)',
                  style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Establecimiento: ${targetVenue.name}\n$feedback',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venues = ref.watch(mockVenuesProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 26,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.neonRedAlert.withOpacity(0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: AppColors.neonRedAlert.withOpacity(0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asa de agarre deslizable
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Encabezado del Modal con Insignia de Anonimato
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neonRedAlert.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.neonRedAlert.withOpacity(0.5)),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.neonRedAlert,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REPORTE DE INCIDENCIA ANONIMA',
                          style: AppTypography.badgeLabel.copyWith(
                            color: AppColors.neonRedAlert,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Colima - Villa de Álvarez',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Selector del Establecimiento a Reportar
            Text(
              'ESTABLECIMIENTO REPORTADO:',
              style: AppTypography.badgeLabel.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVenueId,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceElevated,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neonCyan),
                  items: venues.map((v) {
                    return DropdownMenuItem<String>(
                      value: v.id,
                      child: Text(
                        '${v.name} (${v.zone.split(',').first})',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedVenueId = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Los 4 Recuadros / Indicadores de Reporte
            Text(
              '¿POR QUÉ ESTÁS REPORTANDO?',
              style: AppTypography.badgeLabel.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: IncidentCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withOpacity(0.18)
                          : const Color(0xFF161624),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? cat.color : Colors.white12,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: cat.color.withOpacity(0.35),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 22),
                            const Spacer(),
                            if (isSelected)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: cat.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.title,
                          style: AppTypography.bodyBold.copyWith(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            fontSize: 9.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Casilla de Detalles con Notas Rápidas Precargadas (Activa para "Otro" o cualquier reporte)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: (_selectedCategory != null)
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              secondChild: const SizedBox.shrink(),
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == IncidentCategory.other
                            ? 'DETALLES O MOTIVO (REQUERIDO):'
                            : 'DETALLES OPCIONALES:',
                        style: AppTypography.badgeLabel.copyWith(
                          color: AppColors.neonCyan,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Notas rápidas disponibles',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.neonAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Chips de Notas Rápidas sugeridas por el usuario
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickNotes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final note = _quickNotes[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _detailsController.text = note;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _detailsController.text == note
                                    ? AppColors.neonCyan
                                    : Colors.white12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded, size: 12, color: AppColors.neonAmber),
                                const SizedBox(width: 4),
                                Text(
                                  note,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: _detailsController.text == note
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Campo de Texto de Detalle
                  TextField(
                    controller: _detailsController,
                    maxLines: 2,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Escribe detalles o selecciona una nota arriba...',
                      hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.neonCyan),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Explicación del filtro anti-difamación y cuórum
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.privacy_tip_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Filtro de moderación activo: Se neutralizan nombres propios y difamaciones personales. Para riñas, se requieren al menos 5 reportes independientes confirmados en 10 min dentro del establecimiento.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Botón de Envío de Reporte
            GestureDetector(
              onTap: _submitReport,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonRedAlert,
                      const Color(0xFFC2185B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonRedAlert.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ENVIAR REPORTE ANÓNIMO',
                      style: AppTypography.bodyBold.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.8,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

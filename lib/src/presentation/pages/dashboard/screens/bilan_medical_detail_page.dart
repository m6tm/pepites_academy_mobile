import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/route_aware_refresh_mixin.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/bilan_medical_mensuel.dart';
import '../../../../injection_container.dart';
import '../../../state/bilan_medical_mensuel_state.dart';
import '../../../theme/app_colors.dart';
import 'bilan_medical_form_page.dart';

/// Page de detail d'un bilan medical mensuel.
class BilanMedicalDetailPage extends StatefulWidget {
  final Academicien academicien;
  final BilanMedicalMensuel bilan;

  const BilanMedicalDetailPage({
    super.key,
    required this.academicien,
    required this.bilan,
  });

  @override
  State<BilanMedicalDetailPage> createState() => _BilanMedicalDetailPageState();
}

class _BilanMedicalDetailPageState extends State<BilanMedicalDetailPage>
    with RouteAware, RouteAwareRefreshMixin<BilanMedicalDetailPage> {
  late BilanMedicalMensuel _currentBilan;
  late final BilanMedicalMensuelState _state;
  String _posteName = '';

  @override
  void initState() {
    super.initState();
    _currentBilan = widget.bilan;
    _state = DependencyInjection.bilanMedicalMensuelState;
    _state.addListener(_onStateChanged);
    _loadPosteName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeRouteObserver(context, DependencyInjection.routeObserver);
  }

  @override
  void didPopNext() {
    refreshNotifier.notifyReturned();
    _state.loadBilans(widget.academicien.id);
  }

  @override
  void dispose() {
    unsubscribeRouteObserver(DependencyInjection.routeObserver);
    _state.removeListener(_onStateChanged);
    super.dispose();
  }

  Future<void> _loadPosteName() async {
    try {
      final poste = await DependencyInjection
          .referentielService.posteRepository
          .getById(widget.academicien.posteFootballId);
      if (mounted && poste != null) {
        setState(() => _posteName = poste.nom);
      }
    } catch (_) {
      // ignore
    }
  }

  void _onStateChanged() {
    final updated = _state.bilans.where((b) => b.id == _currentBilan.id).firstOrNull;
    if (updated != null && updated != _currentBilan) {
      setState(() => _currentBilan = updated);
    }
  }

  Future<void> _deleteBilan(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bilanMedicalDeleteTitle),
        content: Text(l10n.bilanMedicalDeleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await DependencyInjection.bilanMedicalMensuelService.delete(
        _currentBilan.id,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  void _editBilan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BilanMedicalFormPage(
          academicien: widget.academicien,
          bilan: _currentBilan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.bilanMedicalDetailTitle,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: _editBilan,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.red),
            onPressed: () => _deleteBilan(l10n),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAcademicienCard(colorScheme, isDark, l10n),
            const SizedBox(height: 20),
            _buildPeriodeCard(colorScheme, isDark, l10n),
            const SizedBox(height: 20),
            _buildCountersCard(colorScheme, isDark, l10n),
            const SizedBox(height: 20),
            _buildTotalCard(colorScheme, isDark, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicienCard(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: widget.academicien.photoUrl.isNotEmpty
                ? NetworkImage(widget.academicien.photoUrl)
                : null,
            child: widget.academicien.photoUrl.isEmpty
                ? Icon(Icons.person_rounded, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.academicien.prenom} ${widget.academicien.nom}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _posteName,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodeCard(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bilanMedicalPeriodeLabel,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentBilan.periodeLabel,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountersCard(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bilanMedicalBlessuresTitle,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildCounterRow(
            l10n.bilanMedicalMusculaire,
            _currentBilan.blessuresMusculaire,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildCounterRow(
            l10n.bilanMedicalArticulaire,
            _currentBilan.blessuresArticulaire,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildCounterRow(
            l10n.bilanMedicalTraumatique,
            _currentBilan.blessuresTraumatique,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.bilanMedicalTotalLabel,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            _currentBilan.totalBlessures.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

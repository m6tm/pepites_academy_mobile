import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/bilan_medical_mensuel.dart';
import '../../../../injection_container.dart';
import '../../../theme/app_colors.dart';

/// Page de creation / edition d'un bilan medical mensuel.
class BilanMedicalFormPage extends StatefulWidget {
  final Academicien academicien;
  final BilanMedicalMensuel? bilan;

  const BilanMedicalFormPage({
    super.key,
    required this.academicien,
    this.bilan,
  });

  @override
  State<BilanMedicalFormPage> createState() => _BilanMedicalFormPageState();
}

class _BilanMedicalFormPageState extends State<BilanMedicalFormPage> {
  late final TextEditingController _musculaireController;
  late final TextEditingController _articulaireController;
  late final TextEditingController _traumatiqueController;
  late int _selectedMois;
  late int _selectedAnnee;
  bool _isLoading = false;
  String? _error;
  String _posteName = '';

  bool get _isEditing => widget.bilan != null;

  String _moisLabel(int mois, AppLocalizations l10n) {
    switch (mois) {
      case 1:
        return l10n.january;
      case 2:
        return l10n.february;
      case 3:
        return l10n.march;
      case 4:
        return l10n.april;
      case 5:
        return l10n.may;
      case 6:
        return l10n.june;
      case 7:
        return l10n.july;
      case 8:
        return l10n.august;
      case 9:
        return l10n.september;
      case 10:
        return l10n.october;
      case 11:
        return l10n.november;
      case 12:
        return l10n.december;
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMois = widget.bilan?.mois ?? now.month;
    _selectedAnnee = widget.bilan?.annee ?? now.year;
    _musculaireController = TextEditingController(
      text: (widget.bilan?.blessuresMusculaire ?? 0).toString(),
    );
    _articulaireController = TextEditingController(
      text: (widget.bilan?.blessuresArticulaire ?? 0).toString(),
    );
    _traumatiqueController = TextEditingController(
      text: (widget.bilan?.blessuresTraumatique ?? 0).toString(),
    );
    _loadPosteName();
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

  @override
  void dispose() {
    _musculaireController.dispose();
    _articulaireController.dispose();
    _traumatiqueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final musculaire = int.tryParse(_musculaireController.text) ?? 0;
    final articulaire = int.tryParse(_articulaireController.text) ?? 0;
    final traumatique = int.tryParse(_traumatiqueController.text) ?? 0;

    if (musculaire < 0 || articulaire < 0 || traumatique < 0) {
      setState(() => _error = l10n.bilanMedicalErrorInvalidCounters);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = DependencyInjection.bilanMedicalMensuelService;
      final bilan = BilanMedicalMensuel(
        id: widget.bilan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        academicienId: widget.academicien.id,
        medecinId: widget.bilan?.medecinId ?? '',
        mois: _selectedMois,
        annee: _selectedAnnee,
        blessuresMusculaire: musculaire,
        blessuresArticulaire: articulaire,
        blessuresTraumatique: traumatique,
        createdAt: widget.bilan?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await service.update(bilan);
      } else {
        await service.create(bilan);
      }

      // Attend la reponse du serveur si l'appareil est en ligne.
      final isOnline = await DependencyInjection.connectivityGuard.isOnline;
      if (isOnline) {
        final syncResult =
            await DependencyInjection.syncService.syncPendingOperationsAndWait();
        if (syncResult != null && syncResult.failureCount > 0) {
          setState(() {
            _error = l10n.serviceSyncErrorGeneric;
            _isLoading = false;
          });
          return;
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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
          _isEditing ? l10n.bilanMedicalEditTitle : l10n.bilanMedicalNewTitle,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAcademicienCard(colorScheme, isDark, l10n),
            const SizedBox(height: 20),
            _buildPeriodeSelector(colorScheme, isDark, l10n),
            const SizedBox(height: 20),
            _buildCounterField(
              l10n.bilanMedicalMusculaire,
              _musculaireController,
              Colors.orange,
              l10n,
            ),
            const SizedBox(height: 16),
            _buildCounterField(
              l10n.bilanMedicalArticulaire,
              _articulaireController,
              Colors.blue,
              l10n,
            ),
            const SizedBox(height: 16),
            _buildCounterField(
              l10n.bilanMedicalTraumatique,
              _traumatiqueController,
              Colors.red,
              l10n,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.montserrat(
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing
                            ? l10n.bilanMedicalUpdateButton
                            : l10n.bilanMedicalCreateButton,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
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
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: widget.academicien.photoUrl.isNotEmpty
                ? NetworkImage(widget.academicien.photoUrl)
                : null,
            child: widget.academicien.photoUrl.isEmpty
                ? Icon(Icons.person_rounded, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.academicien.prenom} ${widget.academicien.nom}',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _posteName,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
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

  Widget _buildPeriodeSelector(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final annees = List.generate(10, (i) => DateTime.now().year - 5 + i);

    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<int>(
                  value: _selectedMois,
                  items: List.generate(12, (i) => i + 1),
                  labelBuilder: (m) => _moisLabel(m, l10n),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMois = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<int>(
                  value: _selectedAnnee,
                  items: annees,
                  labelBuilder: (a) => a.toString(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAnnee = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: GoogleFonts.montserrat(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCounterField(
    String label,
    TextEditingController controller,
    Color color,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
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
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: color.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

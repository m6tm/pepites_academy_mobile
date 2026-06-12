import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/dossier_medical.dart';
import '../../../../injection_container.dart';
import '../../../state/dossier_medical_form_state.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/image_compressor.dart';
import '../../../widgets/signature_pad.dart';

/// Page de formulaire pour la creation ou l'edition d'un dossier medical.
///
/// Affiche les informations du joueur en lecture seule, puis toutes les
/// sections du dossier medical selon le modele de fiche de suivi.
class DossierMedicalFormPage extends StatefulWidget {
  final Academicien academicien;
  final DossierMedical? dossier;

  const DossierMedicalFormPage({
    super.key,
    required this.academicien,
    this.dossier,
  });

  @override
  State<DossierMedicalFormPage> createState() => _DossierMedicalFormPageState();
}

class _DossierMedicalFormPageState extends State<DossierMedicalFormPage> {
  late final DossierMedicalFormState _state;
  final Map<String, TextEditingController> _controllers = {};
  String? _posteLabel;
  String? _niveauLabel;
  bool _isUploadingSignature = false;
  bool _hasSignatureError = false;
  File? _pendingSignatureFile;
  final _premiersSoinsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _state = DependencyInjection.dossierMedicalFormState;
    if (widget.dossier != null) {
      _state.loadFromDossier(widget.dossier!);
    } else {
      _state.reset();
    }
    _initControllers();
    _loadReferentiels();
  }

  void _initControllers() {
    _getController('heureBlessure', _state.heureBlessure);
    _getController('adversaire', _state.adversaire);
    _getController('lieuPrecision', _state.lieuPrecision);
    _getController('circonstancesTypePrecision', _state.circonstancesTypePrecision);
    _getController('circonstancesPrecision', _state.circonstancesPrecision);
    _getController('description', _state.description);
    _getController('partieCorpsPrecision', _state.partieCorpsPrecision);
    _getController('typeBlessurePrecision', _state.typeBlessurePrecision);
    _getController('observations', _state.observations);
    _getController('responsableMedical', _state.responsableMedical);
    _getController('premiersSoins', '');
    _getController('validationRepriseRecommandation', _state.validationRepriseRecommandation);
  }

  TextEditingController _getController(String key, String initialValue) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    }
    return _controllers[key]!;
  }

  TextEditingController? _controller(String key) => _controllers[key];

  Future<void> _loadReferentiels() async {
    final poste = await DependencyInjection.referentielService.posteRepository
        .getById(widget.academicien.posteFootballId);
    final niveau = await DependencyInjection.referentielService.niveauRepository
        .getById(widget.academicien.niveauScolaireId);
    if (mounted) {
      setState(() {
        _posteLabel = poste?.nom;
        _niveauLabel = niveau?.nom;
      });
    }
  }

  Future<void> _handleSignature() async {
    final file = await SignatureDialog.show(context);
    if (file == null) return;

    final compressed = await ImageCompressor.compress(
      imageFile: file,
      quality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (compressed == null) return;

    setState(() {
      _isUploadingSignature = true;
      _hasSignatureError = false;
      _pendingSignatureFile = null;
    });

    _state.setSignatureFile(compressed);
    final success = await _state.uploadSignature();

    if (mounted) {
      setState(() {
        _isUploadingSignature = false;
        if (!success) {
          _hasSignatureError = true;
          _pendingSignatureFile = compressed;
        }
      });
    }
  }

  Future<void> _pickSignatureFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (picked == null) return;

    final compressed = await ImageCompressor.compress(
      imageFile: File(picked.path),
      quality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (compressed == null) return;

    setState(() {
      _isUploadingSignature = true;
      _hasSignatureError = false;
      _pendingSignatureFile = null;
    });

    _state.setSignatureFile(compressed);
    final success = await _state.uploadSignature();

    if (mounted) {
      setState(() {
        _isUploadingSignature = false;
        if (!success) {
          _hasSignatureError = true;
          _pendingSignatureFile = compressed;
        }
      });
    }
  }

  Future<void> _retrySignatureUpload() async {
    if (_pendingSignatureFile == null) return;
    setState(() {
      _isUploadingSignature = true;
      _hasSignatureError = false;
    });
    _state.setSignatureFile(_pendingSignatureFile);
    final success = await _state.uploadSignature();
    if (mounted) {
      setState(() {
        _isUploadingSignature = false;
        if (success) {
          _hasSignatureError = false;
          _pendingSignatureFile = null;
        } else {
          _hasSignatureError = true;
        }
      });
    }
  }

  Future<void> _showSignatureOptions() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ajouter une signature',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.draw_outlined, color: AppColors.primary),
              ),
              title: Text(
                'Dessiner la signature',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Signez directement sur l\'ecran',
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleSignature();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
              ),
              title: Text(
                'Importer depuis la galerie',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Selectionnez une image existante',
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickSignatureFromGallery();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final success = await _state.save(widget.academicien.id, existing: widget.dossier);
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _premiersSoinsFocusNode.dispose();
    // Ne pas disposer le state car il est gere par DependencyInjection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _state,
          builder: (context, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(colorScheme, isDark),
                _buildAcademicienInfo(colorScheme, isDark),
                _buildSectionTitle('Declaration de blessure', colorScheme),
                _buildDeclarationForm(colorScheme, isDark),
                _buildSectionTitle('Circonstances', colorScheme),
                _buildCirconstancesForm(colorScheme, isDark),
                _buildSectionTitle('Description et nature', colorScheme),
                _buildDescriptionForm(colorScheme, isDark),
                _buildSectionTitle('Premiers soins', colorScheme),
                _buildPremiersSoinsForm(colorScheme, isDark),
                _buildSectionTitle('Observations', colorScheme),
                _buildObservationsForm(colorScheme, isDark),
                _buildSectionTitle('Suivi de reeducation', colorScheme),
                _buildSuiviReeducationForm(colorScheme, isDark),
                _buildSectionTitle('Retour progressif', colorScheme),
                _buildRetourProgressifForm(colorScheme, isDark),
                _buildSectionTitle('Validation de reprise', colorScheme),
                _buildValidationRepriseForm(colorScheme, isDark),
                _buildSectionTitle('Validation finale', colorScheme),
                _buildValidationFinaleForm(colorScheme, isDark),
                if (_state.hasError)
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: _buildErrorBanner(colorScheme),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  sliver: SliverToBoxAdapter(
                    child: _buildSaveButton(colorScheme, isDark),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Widgets helpers
  // ------------------------------------------------------------------
  Widget _buildHeader(ColorScheme colorScheme, bool isDark) {
    final isEditing = widget.dossier != null;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Modifier le dossier' : 'Nouveau dossier',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dossier medical de suivi',
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
      ),
    );
  }

  Widget _buildAcademicienInfo(ColorScheme colorScheme, bool isDark) {
    final acad = widget.academicien;
    final age = _calculateAge(acad.dateNaissance);
    final telephoneGarant = acad.telephoneGarant;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B0A1E), AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B0A1E).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${acad.prenom} ${acad.nom}',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Age', '$age ans'),
            if (_posteLabel != null) _buildInfoRow('Poste', _posteLabel!),
            if (_niveauLabel != null) _buildInfoRow('Categorie', _niveauLabel!),
            _buildInfoRow(
              'Date de naissance',
              '${acad.dateNaissance.day.toString().padLeft(2, '0')}/'
                  '${acad.dateNaissance.month.toString().padLeft(2, '0')}/'
                  '${acad.dateNaissance.year}',
            ),
            if (telephoneGarant.isNotEmpty)
              _buildInfoRow('Telephone garant', telephoneGarant),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children, bool isDark = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required ValueChanged<String> onChanged,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    VoidCallback? onSubmitted,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
          items: items,
          onChanged: onChanged,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
          dropdownColor: isDark ? colorScheme.surface : Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Sections
  // ------------------------------------------------------------------
  Widget _buildDeclarationForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildLabel('Date de blessure', colorScheme),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _state.dateBlessure,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (picked != null) _state.setDateBlessure(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  '${_state.dateBlessure.day.toString().padLeft(2, '0')}/'
                      '${_state.dateBlessure.month.toString().padLeft(2, '0')}/'
                      '${_state.dateBlessure.year}',
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildLabel('Heure approximative', colorScheme),
        InkWell(
          onTap: () async {
            final now = TimeOfDay.now();
            final initial = _parseTimeOfDay(_state.heureBlessure) ?? now;
            final picked = await showTimePicker(
              context: context,
              initialTime: initial,
            );
            if (picked != null) {
              _state.setHeureBlessure(
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
              );
              _controller('heureBlessure')?.text = _state.heureBlessure;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _state.heureBlessure.isNotEmpty
                      ? _state.heureBlessure
                      : 'Selectionner l\'heure',
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildLabel('Lieu', colorScheme),
        _buildDropdown<String>(
          hint: 'Selectionner le lieu',
          value: _state.lieu.isEmpty ? null : _state.lieu,
          items: ['entrainement', 'match', 'autre']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e == 'entrainement'
                        ? 'Entrainement'
                        : e == 'match'
                            ? 'Match'
                            : 'Autre',
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => _state.setLieu(v ?? 'entrainement'),
        ),
        if (_state.lieu == 'autre') ...[
          const SizedBox(height: 14),
          _buildLabel('Precision du lieu', colorScheme),
          _buildTextField(
            hint: 'Precisez le lieu',
            controller: _getController('lieuPrecision', _state.lieuPrecision),
            onChanged: _state.setLieuPrecision,
          ),
        ],
        if (_state.lieu == 'match') ...[
          const SizedBox(height: 14),
          _buildLabel('Adversaire', colorScheme),
          _buildTextField(
            hint: 'Nom de l\'adversaire',
            controller: _getController('adversaire', _state.adversaire),
            onChanged: _state.setAdversaire,
          ),
        ],
      ],
    );
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget _buildCirconstancesForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildLabel('Type de circonstance', colorScheme),
        _buildDropdown<String>(
          hint: 'Selectionner',
          value: _state.circonstancesType.isEmpty ? null : _state.circonstancesType,
          items: ['tacle', 'chute', 'collision', 'surcharge', 'autre']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e[0].toUpperCase() + e.substring(1),
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => _state.setCirconstancesType(v ?? ''),
        ),
        const SizedBox(height: 14),
        if (_state.circonstancesType == 'autre') ...[
          const SizedBox(height: 14),
          _buildLabel('Precisez le type de circonstance', colorScheme),
          _buildTextField(
            hint: 'Ex: blessure a l\'echauffement...',
            controller: _getController('circonstancesTypePrecision', _state.circonstancesTypePrecision),
            onChanged: _state.setCirconstancesTypePrecision,
          ),
        ],
        const SizedBox(height: 14),
        _buildLabel('Details complementaires', colorScheme),
        _buildTextField(
          hint: 'Decrivez la circonstance...',
          controller: _getController('circonstancesPrecision', _state.circonstancesPrecision),
          onChanged: _state.setCirconstancesPrecision,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildDescriptionForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildLabel('Partie du corps touchee', colorScheme),
        _buildDropdown<String>(
          hint: 'Selectionner',
          value: _state.partieCorps.isEmpty ? null : _state.partieCorps,
          items: [
            'tete',
            'epaule',
            'bras',
            'main',
            'dos',
            'hanche',
            'cuisse',
            'genou',
            'jambe',
            'cheville',
            'pied',
            'autre',
          ]
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e[0].toUpperCase() + e.substring(1),
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => _state.setPartieCorps(v ?? ''),
        ),
        if (_state.partieCorps == 'autre') ...[
          const SizedBox(height: 14),
          _buildLabel('Precisez la partie du corps', colorScheme),
          _buildTextField(
            hint: 'Ex: cote droit du thorax...',
            controller: _getController('partieCorpsPrecision', _state.partieCorpsPrecision),
            onChanged: _state.setPartieCorpsPrecision,
          ),
        ],
        const SizedBox(height: 14),
        _buildLabel('Type de blessure', colorScheme),
        _buildDropdown<String>(
          hint: 'Selectionner',
          value: _state.typeBlessure.isEmpty ? null : _state.typeBlessure,
          items: [
            'entorse',
            'fracture',
            'claquage',
            'contracture',
            'coupure',
            'contusion',
            'dechirure',
            'autre',
          ]
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e[0].toUpperCase() + e.substring(1),
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => _state.setTypeBlessure(v ?? ''),
        ),
        if (_state.typeBlessure == 'autre') ...[
          const SizedBox(height: 14),
          _buildLabel('Precisez le type de blessure', colorScheme),
          _buildTextField(
            hint: 'Ex: luxation acromio-claviculaire...',
            controller: _getController('typeBlessurePrecision', _state.typeBlessurePrecision),
            onChanged: _state.setTypeBlessurePrecision,
          ),
        ],
        const SizedBox(height: 14),
        _buildLabel('Niveau de gravite', colorScheme),
        _buildDropdown<String>(
          hint: 'Selectionner',
          value: _state.gravite.isEmpty ? null : _state.gravite,
          items: ['legere', 'moyenne', 'grave']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e[0].toUpperCase() + e.substring(1),
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => _state.setGravite(v ?? ''),
        ),
        const SizedBox(height: 14),
        _buildLabel('Description', colorScheme),
        _buildTextField(
          hint: 'Decrivez la blessure...',
          controller: _getController('description', _state.description),
          onChanged: _state.setDescription,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildPremiersSoinsForm(ColorScheme colorScheme, bool isDark) {
    void submitSoin() {
      final controller = _getController('premiersSoins', '');
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        _state.addPremiersSoins(text);
        controller.clear();
        _premiersSoinsFocusNode.requestFocus();
      }
    }

    return _buildCard(
      isDark: isDark,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                hint: 'Ajouter un soin...',
                controller: _getController('premiersSoins', ''),
                focusNode: _premiersSoinsFocusNode,
                onChanged: (_) {},
                onSubmitted: submitSoin,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: submitSoin,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _state.premiersSoins.asMap().entries.map((entry) {
            return Chip(
              label: Text(
                entry.value,
                style: GoogleFonts.montserrat(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _state.removePremiersSoins(entry.key),
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildObservationsForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildTextField(
          hint: 'Observations libres...',
          controller: _getController('observations', _state.observations),
          onChanged: _state.setObservations,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildSuiviReeducationForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        ..._state.suiviReeducation.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildReeducationItem(index, item, colorScheme);
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _state.addSuiviReeducation(),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Ajouter une seance',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReeducationItem(
    int index,
    Map<String, dynamic> item,
    ColorScheme colorScheme,
  ) {
    final itemId = item['id']?.toString() ?? 'reeducation_$index';
    final travauxController = _getController(
      'reeducation_travaux_$itemId',
      item['travaux']?.toString() ?? '',
    );
    final observationsController = _getController(
      'reeducation_observations_$itemId',
      item['observations']?.toString() ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Seance ${index + 1}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _controllers['reeducation_travaux_$itemId']?.dispose();
                  _controllers['reeducation_observations_$itemId']?.dispose();
                  _controllers.remove('reeducation_travaux_$itemId');
                  _controllers.remove('reeducation_observations_$itemId');
                  _state.removeSuiviReeducation(index);
                },
                child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final date = DateTime.tryParse(item['date']?.toString() ?? '');
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked != null) {
                final updated = Map<String, dynamic>.from(item);
                updated['date'] = picked.toIso8601String();
                _state.updateSuiviReeducation(index, updated);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateShort(
                      DateTime.tryParse(item['date']?.toString() ?? '') ??
                          DateTime.now(),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: travauxController,
            onChanged: (v) {
              final updated = Map<String, dynamic>.from(item);
              updated['travaux'] = v;
              _state.updateSuiviReeducation(index, updated);
            },
            decoration: InputDecoration(
              hintText: 'Travaux effectues',
              hintStyle: GoogleFonts.montserrat(fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedBorder(),
            ),
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Douleur : ',
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
              Expanded(
                child: Slider(
                  value: (item['douleur'] as num?)?.toDouble() ?? 5.0,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${item['douleur'] ?? 5}',
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    final updated = Map<String, dynamic>.from(item);
                    updated['douleur'] = v.toInt();
                    _state.updateSuiviReeducation(index, updated);
                  },
                ),
              ),
            ],
          ),
          TextField(
            controller: observationsController,
            onChanged: (v) {
              final updated = Map<String, dynamic>.from(item);
              updated['observations'] = v;
              _state.updateSuiviReeducation(index, updated);
            },
            decoration: InputDecoration(
              hintText: 'Observations',
              hintStyle: GoogleFonts.montserrat(fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedBorder(),
            ),
            style: GoogleFonts.montserrat(fontSize: 13),
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget _buildRetourProgressifForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        ..._state.retourProgressif.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildRetourProgressifItem(index, item, colorScheme);
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _state.addRetourProgressif(),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Ajouter une etape',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRetourProgressifItem(
    int index,
    Map<String, dynamic> item,
    ColorScheme colorScheme,
  ) {
    final itemId = item['id']?.toString() ?? 'retour_$index';
    final activiteController = _getController(
      'retour_activite_$itemId',
      item['activite']?.toString() ?? '',
    );
    final validationController = _getController(
      'retour_validation_$itemId',
      item['validation']?.toString() ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Etape ${index + 1}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _controllers['retour_activite_$itemId']?.dispose();
                  _controllers['retour_validation_$itemId']?.dispose();
                  _controllers.remove('retour_activite_$itemId');
                  _controllers.remove('retour_validation_$itemId');
                  _state.removeRetourProgressif(index);
                },
                child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final date = DateTime.tryParse(item['date']?.toString() ?? '');
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                final updated = Map<String, dynamic>.from(item);
                updated['date'] = picked.toIso8601String();
                _state.updateRetourProgressif(index, updated);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateShort(
                      DateTime.tryParse(item['date']?.toString() ?? '') ??
                          DateTime.now(),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: activiteController,
            onChanged: (v) {
              final updated = Map<String, dynamic>.from(item);
              updated['activite'] = v;
              _state.updateRetourProgressif(index, updated);
            },
            decoration: InputDecoration(
              hintText: 'Activite autorisee',
              hintStyle: GoogleFonts.montserrat(fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedBorder(),
            ),
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: validationController,
            onChanged: (v) {
              final updated = Map<String, dynamic>.from(item);
              updated['validation'] = v;
              _state.updateRetourProgressif(index, updated);
            },
            decoration: InputDecoration(
              hintText: 'Validation + temps utilise',
              hintStyle: GoogleFonts.montserrat(fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedBorder(),
            ),
            style: GoogleFonts.montserrat(fontSize: 13),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationRepriseForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildCustomCheckbox(
          label: 'Joueur apte a reprendre les entrainements',
          value: _state.validationRepriseEntrainement,
          onChanged: _state.setValidationRepriseEntrainement,
        ),
        const SizedBox(height: 10),
        _buildCustomCheckbox(
          label: 'Joueur apte a reprendre la competition',
          value: _state.validationRepriseCompetition,
          onChanged: _state.setValidationRepriseCompetition,
        ),
        const SizedBox(height: 10),
        _buildCustomCheckbox(
          label: 'Surveillance particuliere recommandee',
          value: _state.validationRepriseSurveillance,
          onChanged: _state.setValidationRepriseSurveillance,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hint: 'Recommandation libre...',
          controller: _getController(
            'validationRepriseRecommandation',
            _state.validationRepriseRecommandation,
          ),
          onChanged: _state.setValidationRepriseRecommandation,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildCustomCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.08)
              : colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? AppColors.primary.withValues(alpha: 0.4)
                : colorScheme.onSurface.withValues(alpha: 0.08),
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationFinaleForm(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildLabel('Date de validation', colorScheme),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _state.validationFinaleDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (picked != null) _state.setValidationFinaleDate(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _state.validationFinaleDate != null
                      ? '${_state.validationFinaleDate!.day.toString().padLeft(2, '0')}/'
                          '${_state.validationFinaleDate!.month.toString().padLeft(2, '0')}/'
                          '${_state.validationFinaleDate!.year}'
                      : 'Selectionner une date',
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildLabel('Responsable medical', colorScheme),
        _buildTextField(
          hint: 'Nom du responsable',
          controller: _getController('responsableMedical', _state.responsableMedical),
          onChanged: _state.setResponsableMedical,
        ),
        const SizedBox(height: 14),
        _buildLabel('Signature du responsable', colorScheme),
        GestureDetector(
          onTap: _showSignatureOptions,
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _state.signatureUrl.isNotEmpty
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : colorScheme.onSurface.withValues(alpha: 0.1),
                width: _state.signatureUrl.isNotEmpty ? 2 : 1,
              ),
            ),
            child: _isUploadingSignature
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload en cours...',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _hasSignatureError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 28, color: Colors.red.shade400),
                          const SizedBox(height: 4),
                          Text(
                            'Echec de l\'upload',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ElevatedButton.icon(
                            onPressed: _retrySignatureUpload,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text(
                              'Reessayer',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _state.signatureUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.network(
                              _state.signatureUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image_outlined,
                                size: 36,
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.draw_outlined,
                                size: 36,
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajouter la signature',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _state.error ?? 'Une erreur est survenue.',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _state.isLoading ? null : _onSave,
        icon: _state.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(
          widget.dossier != null
              ? 'Enregistrer les modifications'
              : 'Creer le dossier medical',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Bordures de champs
  // ------------------------------------------------------------------
  OutlineInputBorder _inputBorder() {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.08),
      ),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    );
  }

  // ------------------------------------------------------------------
  // Utils
  // ------------------------------------------------------------------
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

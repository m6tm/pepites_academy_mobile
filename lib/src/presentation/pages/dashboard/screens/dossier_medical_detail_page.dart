import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/dossier_medical.dart';
import '../../../theme/app_colors.dart';
import 'dossier_medical_form_page.dart';

/// Page de detail d'un dossier medical en mode lecture seule.
///
/// Offre un bouton "Modifier" pour basculer vers le formulaire d'edition.
class DossierMedicalDetailPage extends StatelessWidget {
  final Academicien academicien;
  final DossierMedical dossier;

  const DossierMedicalDetailPage({
    super.key,
    required this.academicien,
    required this.dossier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(colorScheme, isDark, context),
            _buildAcademicienInfo(colorScheme, isDark),
            _buildSectionTitle('Declaration de blessure', colorScheme),
            _buildDetailCard([
              _detailRow('Date', _formatDate(dossier.dateBlessure)),
              if (dossier.heureBlessure != null && dossier.heureBlessure!.isNotEmpty)
                _detailRow('Heure', dossier.heureBlessure!),
              _detailRow(
                'Lieu',
                _displayValue(
                  dossier.lieu,
                  dossier.circonstances?['lieu_precision']?.toString(),
                ),
              ),
              if (dossier.adversaire != null && dossier.adversaire!.isNotEmpty)
                _detailRow('Adversaire', dossier.adversaire!),
            ], colorScheme, isDark),
            _buildSectionTitle('Circonstances', colorScheme),
            _buildDetailCard([
              if (dossier.circonstances != null) ...[
                if (dossier.circonstances!['type'] != null)
                  _detailRow(
                    'Type',
                    _displayValue(
                      dossier.circonstances!['type'].toString(),
                      dossier.circonstances!['type_precision']?.toString(),
                    ),
                  ),
                if (dossier.circonstances!['precision'] != null &&
                    dossier.circonstances!['precision'].toString().isNotEmpty)
                  _detailRow('Details', dossier.circonstances!['precision'].toString()),
              ] else
                _emptyValue('Aucune circonstance renseignee'),
            ], colorScheme, isDark),
            _buildSectionTitle('Description et nature', colorScheme),
            _buildDetailCard([
              if (dossier.partieCorps != null)
                _detailRow(
                  'Partie du corps',
                  _displayValue(
                    dossier.partieCorps!,
                    dossier.circonstances?['partie_corps_precision']?.toString(),
                  ),
                ),
              if (dossier.typeBlessure != null)
                _detailRow(
                  'Type de blessure',
                  _displayValue(
                    dossier.typeBlessure!,
                    dossier.circonstances?['type_blessure_precision']?.toString(),
                  ),
                ),
              if (dossier.gravite != null)
                _detailRow('Gravite', _capitalize(dossier.gravite!), color: _graviteColor(dossier.gravite!)),
              if (dossier.description != null && dossier.description!.isNotEmpty)
                _detailRow('Description', dossier.description!),
            ], colorScheme, isDark),
            _buildSectionTitle('Premiers soins', colorScheme),
            _buildDetailCard([
              if (dossier.premiersSoins != null && dossier.premiersSoins!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: dossier.premiersSoins!
                      .map(
                        (s) => Chip(
                          label: Text(
                            s,
                            style: GoogleFonts.montserrat(fontSize: 12),
                          ),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                      )
                      .toList(),
                )
              else
                _emptyValue('Aucun soin renseigne'),
            ], colorScheme, isDark),
            _buildSectionTitle('Observations', colorScheme),
            _buildDetailCard([
              if (dossier.observations != null && dossier.observations!.isNotEmpty)
                Text(
                  dossier.observations!,
                  style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
                )
              else
                _emptyValue('Aucune observation'),
            ], colorScheme, isDark),
            _buildSectionTitle('Suivi de reeducation', colorScheme),
            _buildDetailCard([
              if (dossier.suiviReeducation != null && dossier.suiviReeducation!.isNotEmpty)
                Column(
                  children: dossier.suiviReeducation!.asMap().entries.map((e) {
                    final item = e.value;
                    return _buildReeducationCard(item, colorScheme);
                  }).toList(),
                )
              else
                _emptyValue('Aucune seance de reeducation'),
            ], colorScheme, isDark),
            _buildSectionTitle('Retour progressif', colorScheme),
            _buildDetailCard([
              if (dossier.retourProgressif != null && dossier.retourProgressif!.isNotEmpty)
                Column(
                  children: dossier.retourProgressif!.asMap().entries.map((e) {
                    final item = e.value;
                    return _buildRetourProgressifCard(item, colorScheme);
                  }).toList(),
                )
              else
                _emptyValue('Aucune etape de retour progressif'),
            ], colorScheme, isDark),
            _buildSectionTitle('Validation de reprise', colorScheme),
            _buildDetailCard([
              if (dossier.validationReprise != null) ...[
                _detailRow(
                  'Apte entrainement',
                  dossier.validationReprise!['entrainement'] == true ? 'Oui' : 'Non',
                ),
                _detailRow(
                  'Apte competition',
                  dossier.validationReprise!['competition'] == true ? 'Oui' : 'Non',
                ),
                _detailRow(
                  'Surveillance particuliere',
                  dossier.validationReprise!['surveillance'] == true ? 'Oui' : 'Non',
                ),
                if (dossier.validationReprise!['recommandation'] != null &&
                    dossier.validationReprise!['recommandation'].toString().isNotEmpty)
                  _detailRow('Recommandation', dossier.validationReprise!['recommandation'].toString()),
              ] else
                _emptyValue('Validation non renseignee'),
            ], colorScheme, isDark),
            _buildSectionTitle('Validation finale', colorScheme),
            _buildDetailCard([
              if (dossier.validationFinaleDate != null)
                _detailRow('Date', _formatDate(dossier.validationFinaleDate!)),
              if (dossier.responsableMedical != null && dossier.responsableMedical!.isNotEmpty)
                _detailRow('Responsable', dossier.responsableMedical!),
              if (dossier.signatureUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Signature',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      dossier.signatureUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ] else
                _emptyValue('Signature non renseignee'),
            ], colorScheme, isDark),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DossierMedicalFormPage(
                academicien: academicien,
                dossier: dossier,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: Text(
          'Modifier',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDark, BuildContext context) {
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
                    'Dossier medical',
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
                    dossier.natureBlessure,
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
    final acad = academicien;
    final age = _calculateAge(acad.dateNaissance);

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
        child: Row(
          children: [
            Expanded(
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
                  const SizedBox(height: 6),
                  Text(
                    '$age ans',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.folder_shared_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
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

  Widget _buildDetailCard(
    List<Widget> children,
    ColorScheme colorScheme,
    bool isDark,
  ) {
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

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyValue(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 13,
        color: Colors.grey.shade500,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildReeducationCard(Map<String, dynamic> item, ColorScheme colorScheme) {
    final date = DateTime.tryParse(item['date']?.toString() ?? '');
    final douleurValue = item['douleur'];
    final douleur = douleurValue is num ? douleurValue.toInt() : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                date != null ? _formatDate(date) : 'Date inconnue',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (douleur != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _douleurColor(douleur).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Douleur $douleur/10',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _douleurColor(douleur),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (item['travaux'] != null && item['travaux'].toString().isNotEmpty)
            Text(
              'Travaux : ${item['travaux']}',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
          if (item['observations'] != null && item['observations'].toString().isNotEmpty)
            Text(
              'Obs. : ${item['observations']}',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRetourProgressifCard(Map<String, dynamic> item, ColorScheme colorScheme) {
    final date = DateTime.tryParse(item['date']?.toString() ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                date != null ? _formatDate(date) : 'Date inconnue',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (item['activite'] != null && item['activite'].toString().isNotEmpty)
            Text(
              'Activite : ${item['activite']}',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
          if (item['validation'] != null && item['validation'].toString().isNotEmpty)
            Text(
              'Validation + temps : ${item['validation']}',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
        ],
      ),
    );
  }

  Color _douleurColor(int douleur) {
    if (douleur <= 3) return AppColors.success;
    if (douleur <= 6) return AppColors.warning;
    return AppColors.error;
  }

  Color _graviteColor(String gravite) {
    switch (gravite.toLowerCase()) {
      case 'legere':
        return AppColors.success;
      case 'moyenne':
        return AppColors.warning;
      case 'grave':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _displayValue(String value, String? precision) {
    if (value.toLowerCase() == 'autre' &&
        precision != null &&
        precision.trim().isNotEmpty) {
      return _capitalize(precision.trim());
    }
    return _capitalize(value);
  }
}

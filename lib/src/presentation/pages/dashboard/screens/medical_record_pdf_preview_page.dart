import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/dossier_medical.dart';
import '../../../../infrastructure/services/medical_record_pdf_service.dart';
import '../../../theme/app_colors.dart';

/// Page de previsualisation PDF d'un dossier medical.
///
/// Affiche le PDF genere et propose un bouton flottant pour le telecharger /
/// le partager.
class MedicalRecordPdfPreviewPage extends StatelessWidget {
  final Academicien academicien;
  final DossierMedical dossier;
  final MedicalRecordPdfService _pdfService;

  MedicalRecordPdfPreviewPage({
    super.key,
    required this.academicien,
    required this.dossier,
    MedicalRecordPdfService? pdfService,
  }) : _pdfService = pdfService ?? MedicalRecordPdfService();

  Future<void> _sharePdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _pdfService.generatePdf(dossier, academicien, l10n);
      final tempDir = await getTemporaryDirectory();
      final fileName = _pdfFileName(dossier, academicien);
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: fileName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.medicalRecordPdfShareError,
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  String _pdfFileName(DossierMedical dossier, Academicien academicien) {
    final sanitizedName = '${academicien.prenom}_${academicien.nom}'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final date = '${dossier.dateBlessure.year}'
        '${dossier.dateBlessure.month.toString().padLeft(2, '0')}'
        '${dossier.dateBlessure.day.toString().padLeft(2, '0')}';
    return 'dossier_medical_${sanitizedName}_$date.pdf';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.medicalRecordPdfPreviewTitle,
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
      body: PdfPreview(
        build: (format) => _pdfService.generatePdf(dossier, academicien, l10n),
        pdfFileName: _pdfFileName(dossier, academicien),
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        actions: const [],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _sharePdf(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.download_rounded),
        label: Text(
          l10n.medicalRecordPdfDownloadButton,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

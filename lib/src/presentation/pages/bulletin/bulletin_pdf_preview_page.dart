import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/bulletin.dart';
import '../../../infrastructure/services/bulletin_pdf_service.dart';
import '../../theme/app_colors.dart';

/// Page de previsualisation PDF d'un bulletin de formation.
///
/// Affiche le PDF genere et propose un bouton flottant pour le telecharger /
/// le partager.
class BulletinPdfPreviewPage extends StatelessWidget {
  final Academicien academicien;
  final Bulletin bulletin;
  final BulletinPdfService _pdfService;

  BulletinPdfPreviewPage({
    super.key,
    required this.academicien,
    required this.bulletin,
    BulletinPdfService? pdfService,
  }) : _pdfService = pdfService ?? BulletinPdfService();

  Future<void> _sharePdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _pdfService.generatePdf(bulletin, academicien, l10n);
      final tempDir = await getTemporaryDirectory();
      final fileName = _pdfFileName(bulletin, academicien);
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
              'Erreur lors du partage du PDF : $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  String _pdfFileName(Bulletin bulletin, Academicien academicien) {
    final sanitizedName = '${academicien.prenom}_${academicien.nom}'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final periode = bulletin.periodeLabel.replaceAll(' ', '_');
    return 'bulletin_${sanitizedName}_$periode.pdf';
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
          'Previsualisation du bulletin',
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
        build: (format) => _pdfService.generatePdf(bulletin, academicien, l10n),
        pdfFileName: _pdfFileName(bulletin, academicien),
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
          'Telecharger le PDF',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

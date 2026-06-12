import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/academicien.dart';
import '../../domain/entities/dossier_medical.dart';
import '../../../../../l10n/app_localizations.dart';

/// Service de generation PDF pour une fiche de dossier medical.
class MedicalRecordPdfService {
  /// Genere le PDF d'un dossier medical et retourne les bytes.
  Future<Uint8List> generatePdf(
    DossierMedical dossier,
    Academicien academicien,
    AppLocalizations l10n,
  ) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pw.ImageProvider? signatureImage;
    if (dossier.signatureUrl.isNotEmpty) {
      signatureImage = await _loadSignatureImage(dossier.signatureUrl);
    }

    final logoData = await rootBundle.load('assets/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final titleStyle = pw.TextStyle(
      font: fontBold,
      fontSize: 18,
      color: PdfColor.fromHex('#8B0A1E'),
    );
    final sectionStyle = pw.TextStyle(
      font: fontBold,
      fontSize: 12,
      color: PdfColor.fromHex('#8B0A1E'),
    );
    final labelStyle = pw.TextStyle(font: fontBold, fontSize: 9);
    final valueStyle = pw.TextStyle(font: font, fontSize: 9);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => _buildDocumentHeader(l10n, context, logoImage),
        footer: (context) => _buildDocumentFooter(l10n, context),
        build: (context) => [
          _buildDocumentTitle(titleStyle, dossier),
          pw.SizedBox(height: 16),
          _buildPlayerInfo(academicien, labelStyle, valueStyle),
          pw.SizedBox(height: 16),
          _buildSection(
            'Declaration de blessure',
            sectionStyle,
            _buildDeclarationTable(dossier, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Circonstances',
            sectionStyle,
            _buildCircumstancesTable(dossier, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Description et nature',
            sectionStyle,
            _buildDescriptionTable(dossier, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Premiers soins',
            sectionStyle,
            _buildFirstAidTable(dossier, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Observations',
            sectionStyle,
            _buildObservations(dossier, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Validation de reprise',
            sectionStyle,
            _buildReturnValidationTable(dossier, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Validation finale',
            sectionStyle,
            _buildFinalValidationTable(
              dossier,
              labelStyle,
              valueStyle,
              signatureImage,
            ),
          ),
        ],
      ),
    );

    if (dossier.suiviReeducation != null &&
        dossier.suiviReeducation!.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (context) => _buildDocumentHeader(l10n, context, logoImage),
          footer: (context) => _buildDocumentFooter(l10n, context),
          build: (context) => [
            _buildPageTitle('Suivi de reeducation', titleStyle),
            pw.SizedBox(height: 16),
            _buildReeducationTable(
              dossier.suiviReeducation!,
              labelStyle,
              valueStyle,
            ),
          ],
        ),
      );
    }

    if (dossier.retourProgressif != null &&
        dossier.retourProgressif!.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (context) => _buildDocumentHeader(l10n, context, logoImage),
          footer: (context) => _buildDocumentFooter(l10n, context),
          build: (context) => [
            _buildPageTitle('Retour progressif', titleStyle),
            pw.SizedBox(height: 16),
            _buildProgressiveReturnTable(
              dossier.retourProgressif!,
              labelStyle,
              valueStyle,
            ),
          ],
        ),
      );
    }

    return pdf.save();
  }

  /// Sauvegarde le PDF dans un fichier temporaire et retourne le chemin.
  Future<String> saveToTempFile(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final filePath = path.join(dir.path, fileName);
    final file = await File(filePath).writeAsBytes(bytes);
    return file.path;
  }

  pw.Widget _buildDocumentTitle(
    pw.TextStyle titleStyle,
    DossierMedical dossier,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Dossier medical', style: titleStyle),
        pw.SizedBox(height: 4),
        pw.Text(
          'Statut : ${dossier.statutRepriseLabel}',
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  pw.Widget _buildPageTitle(String title, pw.TextStyle titleStyle) {
    return pw.Text(title, style: titleStyle);
  }

  pw.Widget _buildDocumentHeader(
    AppLocalizations l10n,
    pw.Context context,
    pw.ImageProvider logoImage,
  ) {
    final primaryColor = PdfColor.fromHex('#8B0A1E');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              children: [
                pw.Image(logoImage, height: 36, fit: pw.BoxFit.contain),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      l10n.appTitle,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      l10n.medicalRecordPdfHeaderSubtitle,
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Text(
              _formatDate(DateTime.now()),
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(height: 0.5, thickness: 0.5, color: primaryColor),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildDocumentFooter(AppLocalizations l10n, pw.Context context) {
    final primaryColor = PdfColor.fromHex('#8B0A1E');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(height: 0.5, thickness: 0.5, color: primaryColor),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              l10n.medicalRecordPdfFooterConfidential,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              l10n.medicalRecordPdfFooterPage(
                context.pageNumber,
                context.pagesCount,
              ),
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPlayerInfo(
    Academicien academicien,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    final age = _calculateAge(academicien.dateNaissance);
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F9F9F9'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Nom',
                  '${academicien.prenom} ${academicien.nom}',
                  labelStyle,
                  valueStyle,
                ),
                _buildInfoRow('Age', '$age ans', labelStyle, valueStyle),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Date de naissance',
                  _formatDate(academicien.dateNaissance),
                  labelStyle,
                  valueStyle,
                ),
                if (academicien.telephoneGarant.isNotEmpty)
                  _buildInfoRow(
                    'Telephone garant',
                    academicien.telephoneGarant,
                    labelStyle,
                    valueStyle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$label : ', style: labelStyle),
            pw.TextSpan(text: value, style: valueStyle),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildSection(
    String title,
    pw.TextStyle sectionStyle,
    pw.Widget content,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: sectionStyle),
        pw.Divider(height: 8, thickness: 0.5),
        content,
      ],
    );
  }

  pw.Widget _buildDeclarationTable(
    DossierMedical dossier,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        _buildTableRow(
          'Date de blessure',
          _formatDate(dossier.dateBlessure),
          labelStyle,
          valueStyle,
        ),
        if (dossier.heureBlessure != null)
          _buildTableRow(
            'Heure',
            dossier.heureBlessure!,
            labelStyle,
            valueStyle,
          ),
        _buildTableRow(
          'Lieu',
          _displayValue(dossier.lieu, dossier.circonstances?['lieu_precision']),
          labelStyle,
          valueStyle,
        ),
        if (dossier.adversaire != null)
          _buildTableRow(
            'Adversaire',
            dossier.adversaire!,
            labelStyle,
            valueStyle,
          ),
      ],
    );
  }

  pw.Widget _buildCircumstancesTable(
    DossierMedical dossier,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    final type = dossier.circonstances?['type']?.toString() ?? '';
    final typePrecision = dossier.circonstances?['type_precision']?.toString();
    final details = dossier.circonstances?['precision']?.toString();

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        if (type.isNotEmpty)
          _buildTableRow(
            'Type',
            _displayValue(type, typePrecision),
            labelStyle,
            valueStyle,
          ),
        if (details != null && details.isNotEmpty)
          _buildTableRow('Details', details, labelStyle, valueStyle),
      ],
    );
  }

  pw.Widget _buildDescriptionTable(
    DossierMedical dossier,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    final partieCorpsPrecision = dossier
        .circonstances?['partie_corps_precision']
        ?.toString();
    final typeBlessurePrecision = dossier
        .circonstances?['type_blessure_precision']
        ?.toString();

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        if (dossier.partieCorps != null)
          _buildTableRow(
            'Partie du corps',
            _displayValue(dossier.partieCorps!, partieCorpsPrecision),
            labelStyle,
            valueStyle,
          ),
        if (dossier.typeBlessure != null)
          _buildTableRow(
            'Type de blessure',
            _displayValue(dossier.typeBlessure!, typeBlessurePrecision),
            labelStyle,
            valueStyle,
          ),
        if (dossier.gravite != null)
          _buildTableRow(
            'Gravite',
            _capitalize(dossier.gravite!),
            labelStyle,
            valueStyle,
          ),
        if (dossier.description != null)
          _buildTableRow(
            'Description',
            dossier.description!,
            labelStyle,
            valueStyle,
          ),
      ],
    );
  }

  pw.Widget _buildFirstAidTable(
    DossierMedical dossier,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    if (dossier.premiersSoins == null || dossier.premiersSoins!.isEmpty) {
      return pw.Text('Aucun soin renseigne', style: valueStyle);
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: dossier.premiersSoins!
          .map((soin) => pw.Bullet(text: soin, style: valueStyle))
          .toList(),
    );
  }

  pw.Widget _buildObservations(
    DossierMedical dossier,
    pw.TextStyle valueStyle,
  ) {
    return pw.Text(
      dossier.observations ?? 'Aucune observation',
      style: valueStyle,
    );
  }

  pw.Widget _buildReturnValidationTable(
    DossierMedical dossier,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    final validationReprise = dossier.validationReprise;
    if (validationReprise == null) {
      return pw.Text('Validation non renseignee', style: valueStyle);
    }
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        _buildTableRow(
          'Apte entrainement',
          validationReprise['entrainement'] == true ? 'Oui' : 'Non',
          labelStyle,
          valueStyle,
        ),
        _buildTableRow(
          'Apte competition',
          validationReprise['competition'] == true ? 'Oui' : 'Non',
          labelStyle,
          valueStyle,
        ),
        _buildTableRow(
          'Surveillance particuliere',
          validationReprise['surveillance'] == true ? 'Oui' : 'Non',
          labelStyle,
          valueStyle,
        ),
        if (validationReprise['recommandation'] != null)
          _buildTableRow(
            'Recommandation',
            validationReprise['recommandation'].toString(),
            labelStyle,
            valueStyle,
          ),
      ],
    );
  }

  pw.Widget _buildFinalValidationTable(
    DossierMedical dossier,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
    pw.ImageProvider? signatureImage,
  ) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        _buildTableRow(
          'Date de validation',
          dossier.validationFinaleDate != null
              ? _formatDate(dossier.validationFinaleDate!)
              : 'Non renseignee',
          labelStyle,
          valueStyle,
        ),
        _buildTableRow(
          'Responsable medical',
          dossier.responsableMedical ?? 'Non renseigne',
          labelStyle,
          valueStyle,
        ),
        _buildTableRowWidget(
          'Signature',
          signatureImage != null
              ? pw.Image(signatureImage, height: 48, fit: pw.BoxFit.contain)
              : pw.Text('Non renseignee', style: valueStyle),
          labelStyle,
        ),
      ],
    );
  }

  Future<pw.ImageProvider?> _loadSignatureImage(String signatureUrl) async {
    try {
      if (signatureUrl.startsWith('http')) {
        final response = await Dio().get<List<int>>(
          signatureUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = response.data;
        if (bytes != null && bytes.isNotEmpty) {
          return pw.MemoryImage(Uint8List.fromList(bytes));
        }
      } else {
        final file = File(signatureUrl);
        if (await file.exists()) {
          return pw.MemoryImage(await file.readAsBytes());
        }
      }
    } catch (_) {
      // En cas d'erreur de chargement, on retombe sur l'affichage texte.
    }
    return null;
  }

  pw.Widget _buildReeducationTable(
    List<Map<String, dynamic>> items,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(0.8),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#8B0A1E')),
          children: [
            _buildTableHeaderCell('Date', labelStyle),
            _buildTableHeaderCell('Travaux', labelStyle),
            _buildTableHeaderCell('Douleur', labelStyle),
            _buildTableHeaderCell('Observations', labelStyle),
          ],
        ),
        ...items.map((item) {
          final date = DateTime.tryParse(item['date']?.toString() ?? '');
          return pw.TableRow(
            children: [
              _buildTableCell(
                date != null ? _formatDate(date) : '-',
                valueStyle,
              ),
              _buildTableCell(item['travaux']?.toString() ?? '-', valueStyle),
              _buildTableCell(item['douleur']?.toString() ?? '-', valueStyle),
              _buildTableCell(
                item['observations']?.toString() ?? '-',
                valueStyle,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildProgressiveReturnTable(
    List<Map<String, dynamic>> items,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#8B0A1E')),
          children: [
            _buildTableHeaderCell('Date', labelStyle),
            _buildTableHeaderCell('Activite', labelStyle),
            _buildTableHeaderCell('Validation + temps', labelStyle),
          ],
        ),
        ...items.map((item) {
          final date = DateTime.tryParse(item['date']?.toString() ?? '');
          return pw.TableRow(
            children: [
              _buildTableCell(
                date != null ? _formatDate(date) : '-',
                valueStyle,
              ),
              _buildTableCell(item['activite']?.toString() ?? '-', valueStyle),
              _buildTableCell(
                item['validation']?.toString() ?? '-',
                valueStyle,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.TableRow _buildTableRow(
    String label,
    String value,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: labelStyle),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: valueStyle),
        ),
      ],
    );
  }

  pw.TableRow _buildTableRowWidget(
    String label,
    pw.Widget valueWidget,
    pw.TextStyle labelStyle,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: labelStyle),
        ),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: valueWidget),
      ],
    );
  }

  pw.Widget _buildTableHeaderCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: style.copyWith(color: PdfColor(1, 1, 1))),
    );
  }

  pw.Widget _buildTableCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: style),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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

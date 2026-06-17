import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/academicien.dart';
import '../../domain/entities/bulletin.dart';
import '../../domain/entities/encadreur.dart';
import '../../../../../l10n/app_localizations.dart';

/// Service de generation PDF pour un bulletin de formation.
class BulletinPdfService {
  /// Genere le PDF d'un bulletin et retourne les bytes.
  Future<Uint8List> generatePdf(
    Bulletin bulletin,
    Academicien academicien,
    AppLocalizations l10n, {
    Encadreur? encadreur,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

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
          _buildDocumentTitle(titleStyle, bulletin),
          pw.SizedBox(height: 16),
          _buildPlayerInfo(academicien, labelStyle, valueStyle),
          pw.SizedBox(height: 16),
          _buildSection(
            'Competences',
            sectionStyle,
            _buildCompetencesTable(bulletin, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Appreciations',
            sectionStyle,
            _buildAppreciationsTable(bulletin, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Presence et participation',
            sectionStyle,
            _buildPresenceTable(bulletin, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Details par atelier',
            sectionStyle,
            _buildAteliersTable(bulletin, labelStyle, valueStyle),
          ),
          pw.SizedBox(height: 12),
          _buildSection(
            'Observations',
            sectionStyle,
            _buildObservations(bulletin, valueStyle),
          ),
        ],
      ),
    );

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
    Bulletin bulletin,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bulletin de formation', style: titleStyle),
        pw.SizedBox(height: 4),
        pw.Text(
          'Periode : ${bulletin.periodeLabel}',
          style: pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          'Genere le ${_formatDate(bulletin.dateGeneration)}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
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
                      'Bulletin de formation',
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
              'Document confidentiel - Pepites Academy',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
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

  pw.Widget _buildCompetencesTable(
    Bulletin bulletin,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    final competences = bulletin.competences;
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        _buildTableRow('Technique', '${competences.technique.toStringAsFixed(1)}/10', labelStyle, valueStyle),
        _buildTableRow('Physique', '${competences.physique.toStringAsFixed(1)}/10', labelStyle, valueStyle),
        _buildTableRow('Tactique', '${competences.tactique.toStringAsFixed(1)}/10', labelStyle, valueStyle),
        _buildTableRow('Mental', '${competences.mental.toStringAsFixed(1)}/10', labelStyle, valueStyle),
        _buildTableRow('Esprit d\'equipe', '${competences.espritEquipe.toStringAsFixed(1)}/10', labelStyle, valueStyle),
        _buildTableRow(
          'Moyenne generale',
          '${competences.moyenne.toStringAsFixed(1)}/10',
          labelStyle,
          pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 9, color: PdfColor.fromHex('#8B0A1E')),
        ),
      ],
    );
  }

  pw.Widget _buildAppreciationsTable(
    Bulletin bulletin,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    if (bulletin.appreciations.isEmpty) {
      return pw.Text('Aucune appreciation disponible', style: valueStyle);
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: bulletin.appreciations.map((appreciation) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F5F5F5'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    appreciation.domaine,
                    style: labelStyle,
                  ),
                  pw.Text(
                    '${appreciation.note.toStringAsFixed(1)}/5',
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 9,
                      color: PdfColor.fromHex('#8B0A1E'),
                    ),
                  ),
                ],
              ),
              if (appreciation.commentaire.isNotEmpty)
                pw.Text(
                  appreciation.commentaire,
                  style: valueStyle,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPresenceTable(
    Bulletin bulletin,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        _buildTableRow(
          'Seances prevues',
          '${bulletin.nbSeancesTotal}',
          labelStyle,
          valueStyle,
        ),
        _buildTableRow(
          'Seances present',
          '${bulletin.nbSeancesPresent}',
          labelStyle,
          valueStyle,
        ),
        _buildTableRow(
          'Taux de presence',
          '${bulletin.tauxPresence.toStringAsFixed(1)}%',
          labelStyle,
          pw.TextStyle(
            font: pw.Font.helveticaBold(),
            fontSize: 9,
            color: bulletin.tauxPresence >= 80
                ? PdfColors.green
                : bulletin.tauxPresence >= 50
                    ? PdfColors.orange
                    : PdfColors.red,
          ),
        ),
        _buildTableRow(
          'Annotations',
          '${bulletin.nbAnnotationsTotal}',
          labelStyle,
          valueStyle,
        ),
      ],
    );
  }

  pw.Widget _buildAteliersTable(
    Bulletin bulletin,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    if (bulletin.detailsAteliers.isEmpty) {
      return pw.Text('Aucun detail d\'atelier disponible', style: valueStyle);
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: bulletin.detailsAteliers.map((detail) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F5F5F5'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    detail.atelierNom,
                    style: labelStyle,
                  ),
                  pw.Text(
                    'Score : ${detail.scoreMoyen.toStringAsFixed(1)}/5',
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 9,
                      color: PdfColor.fromHex('#8B0A1E'),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '${detail.nbAnnotations} annotation(s)',
                style: valueStyle,
              ),
              if (detail.exercices.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, top: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: detail.exercices.map((exercice) {
                      return pw.Text(
                        '- ${exercice.exerciceNom} : ${exercice.scoreMoyen.toStringAsFixed(1)}/5 (${exercice.nbAnnotations} annotations)',
                        style: valueStyle,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildObservations(
    Bulletin bulletin,
    pw.TextStyle valueStyle,
  ) {
    return pw.Text(
      bulletin.observationsGenerales.isNotEmpty
          ? bulletin.observationsGenerales
          : 'Aucune observation generale',
      style: valueStyle,
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
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(label, style: labelStyle),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(value, style: valueStyle),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int _calculateAge(DateTime dateNaissance) {
    final now = DateTime.now();
    int age = now.year - dateNaissance.year;
    if (now.month < dateNaissance.month ||
        (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
      age--;
    }
    return age;
  }
}

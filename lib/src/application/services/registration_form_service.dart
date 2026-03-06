import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/academicien.dart';

class RegistrationFormService {
  Future<File> genererFicheInscription({
    required Academicien academicien,
    required String posteName,
    required String niveauName,
  }) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load('assets/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    const double headerHeight = 158;

    final headerBytes = await rootBundle.load(
      'assets/fiche_enregistrement_pafc_entete.png',
    );
    final headerImage = pw.MemoryImage(headerBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(headerImage, headerHeight),
              ),
              pw.Positioned.fill(
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Center(
                    child: pw.Image(logoImage, width: 600, height: 600),
                  ),
                ),
              ),
              pw.Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBand(),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(40, headerHeight + 20, 40, 28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    pw.SizedBox(height: 15),
                    _buildAnneeSportive(),
                    pw.SizedBox(height: 20),
                    _buildIdentificationSection(academicien),
                    pw.SizedBox(height: 15),
                    _buildParentSection(academicien),
                    pw.SizedBox(height: 15),
                    _buildHistoriqueSection(academicien),
                    pw.SizedBox(height: 15),
                    _buildFootballSection(academicien, posteName),
                    pw.SizedBox(height: 40),
                    _buildSignatureSection(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/fiche_inscription_${academicien.nom}_${academicien.prenom}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(pw.MemoryImage headerImage, double height) {
    return pw.Container(
      width: double.infinity,
      height: height,
      child: pw.Image(headerImage, fit: pw.BoxFit.fill),
    );
  }

  pw.Widget _buildBottomBand() {
    return pw.Container(
      width: double.infinity,
      height: 8,
      color: PdfColor.fromHex('#E80023'),
    );
  }

  pw.Widget _buildTitle() {
    return pw.Text(
      'FICHE D\'ENREGISTREMENT (A remplir par les parents)',
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
    );
  }

  pw.Widget _buildAnneeSportive() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              'Année sportive : ',
              style: const pw.TextStyle(fontSize: 9),
            ),
            _buildUnderline(100),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Text('Catégorie : ', style: const pw.TextStyle(fontSize: 9)),
            _buildUnderline(100),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildIdentificationSection(Academicien academicien) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'IDENTIFICATION ET INFORMATIONS PERSONNELLES DE L\'ÉLÈVE',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 6),
        _buildSimpleRow('NOMS', academicien.nom.toUpperCase(), 180),
        _buildSimpleRow('PRÉNOMS', academicien.prenom),
        _buildSimpleRow('DATE ET LIEU DE NAISSANCE', ''),
        pw.Row(
          children: [
            pw.Text('NATIONALITÉ', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(150),
            pw.SizedBox(width: 20),
            pw.Text('TAILLE EN CM', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(50),
          ],
        ),
        pw.SizedBox(height: 4),
        _buildSimpleRow('SEXE', '', 50),
        pw.Row(
          children: [
            pw.Text(
              'N° TÉL DE L\'ÉLÈVE',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.SizedBox(width: 5),
            _buildUnderline(150),
            pw.SizedBox(width: 20),
            pw.Text('ADRESSE MAIL', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(180),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Text('FCB', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(120),
            pw.SizedBox(width: 10),
            pw.Text('TWITTER', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(100),
            pw.SizedBox(width: 10),
            pw.Text('WHATSAPP', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(80),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildParentSection(Academicien academicien) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSimpleRow('NOMS DU PÈRE OU DU TUTEUR LÉGAL', '', 150),
        pw.Row(
          children: [
            pw.Text('N° TÉL', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(150),
            pw.SizedBox(width: 20),
            pw.Text('EMAIL', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(180),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Text('FONCTION', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(150),
            pw.SizedBox(width: 20),
            pw.Text('ADRESSE', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(width: 5),
            _buildUnderline(180),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildHistoriqueSection(Academicien academicien) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HISTORIQUE DU PARCOURS SPORTIF DES 3 DERNIÈRES ANNÉES',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('CENTRE', isHeader: true),
                _buildTableCell('CATÉGORIE', isHeader: true),
                _buildTableCell('OBSERVATION', isHeader: true),
              ],
            ),
            ...academicien.historiqueParcours.map(
              (h) => pw.TableRow(
                children: [
                  _buildTableCell(h.centre ?? ''),
                  _buildTableCell(h.categorie ?? ''),
                  _buildTableCell(h.observation ?? ''),
                ],
              ),
            ),
            if (academicien.historiqueParcours.length < 5)
              ...List.generate(
                5 - academicien.historiqueParcours.length,
                (index) => pw.TableRow(
                  children: [
                    _buildTableCell(''),
                    _buildTableCell(''),
                    _buildTableCell(''),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFootballSection(Academicien academicien, String posteName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'AUTRES INFORMATIONS - FOOTBALL',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 6),
        _buildSimpleRow('À quel poste joue-t-il actuellement ?', '', 360),
        _buildSimpleRow('Quels sont ses atouts ?', '', 380),
        _buildSimpleRow('Quelles sont ses faiblesses ?', '', 380),
        _buildQuestionField(
          'Décrivez en quelques mots les performances de l\'enfant',
          '',
          3,
        ),
      ],
    );
  }

  pw.Widget _buildSignatureSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SIGNATURE DU PARENT/TUTEUR',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            _buildSimpleRow('Nom et Prénom', '', 180),
            pw.SizedBox(width: 20),
            _buildSimpleRow('Date', '', 100),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text('Signature : ', style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  pw.Widget _buildSimpleRow(String label, String value, [double width = 350]) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(width: 5),
          _buildUnderline(width),
        ],
      ),
    );
  }

  pw.Widget _buildUnderline(double width) {
    return pw.Container(
      width: width,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      height: 12,
    );
  }

  pw.Widget _buildQuestionField(
    String question,
    String value, [
    int lines = 1,
  ]) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(question, style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 1),
          ...List.generate(
            lines,
            (index) => pw.Column(
              children: [
                _buildUnderline(double.infinity),
                if (index < lines - 1) pw.SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Classe utilitaire pour capturer des widgets en images et les partager.
class ScreenshotHelper {
  /// Capture un widget (identifie par son [GlobalKey]) en image PNG.
  /// Le widget doit etre entoure d'un [RepaintBoundary] utilisant cette cle.
  static Future<Uint8List?> captureWidget(GlobalKey key, {double pixelRatio = 3.0}) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erreur capture widget: $e');
      return null;
    }
  }

  /// Capture un widget et le partage via le menu natif.
  /// 
  /// [key] - La GlobalKey du RepaintBoundary.
  /// [fileName] - Le nom du fichier temporaire (sans extension).
  /// [subject] - Le sujet pour le partage (optionnel).
  /// [text] - Le texte pour le partage (optionnel).
  static Future<void> captureAndShare(
    GlobalKey key, {
    required String fileName,
    String? subject,
    String? text,
  }) async {
    final bytes = await captureWidget(key);
    if (bytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: text,
    );
  }

  /// Sauvegarde la capture d'un widget dans le dossier des documents.
  /// Sur mobile, ceci rend le fichier disponible pour d'autres applications.
  static Future<String?> captureAndSave(
    GlobalKey key, {
    required String fileName,
  }) async {
    final bytes = await captureWidget(key);
    if (bytes == null) return null;

    // Pour le "telechargement", on utilise preferentiellement le dossier des documents
    // qui est plus accessible que le cache temporaire.
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.png');
    await file.writeAsBytes(bytes);

    return file.path;
  }
}

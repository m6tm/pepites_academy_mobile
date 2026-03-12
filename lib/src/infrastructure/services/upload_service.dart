import 'dart:convert';
import 'dart:io';

import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';

/// Type d'image a uploader.
enum UploadType { portrait, photoParent, signatureAcademicien, signatureParent }

/// Resultat d'un upload.
class UploadResult {
  final bool success;
  final String? url;
  final String? error;

  UploadResult({required this.success, this.url, this.error});

  factory UploadResult.success(String url) {
    return UploadResult(success: true, url: url);
  }

  factory UploadResult.failure(String error) {
    return UploadResult(success: false, error: error);
  }
}

/// Service pour l'upload immediat des images vers le serveur.
/// Permet d'uploader les portraits et signatures avant la creation de l'entite.
class UploadService {
  final DioClient _dioClient;

  UploadService(this._dioClient);

  /// Upload une image depuis un fichier local.
  ///
  /// [file] - Le fichier image a uploader.
  /// [type] - Le type d'image (portrait, signature, etc.).
  ///
  /// Retourne [UploadResult] avec l'URL de l'image uploadee.
  Future<UploadResult> uploadImage(File file, UploadType type) async {
    try {
      // Lire le fichier et le convertir en base64
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final base64WithPrefix = 'data:image/jpeg;base64,$base64String';

      return await uploadBase64(base64WithPrefix, type);
    } catch (e) {
      return UploadResult.failure('Erreur lecture fichier: $e');
    }
  }

  /// Upload une image encodee en base64.
  ///
  /// [base64Data] - L'image encodee en base64 (avec ou sans prefixe data URI).
  /// [type] - Le type d'image (portrait, signature, etc.).
  ///
  /// Retourne [UploadResult] avec l'URL de l'image uploadee.
  Future<UploadResult> uploadBase64(String base64Data, UploadType type) async {
    try {
      // Ajouter le prefixe data URI si absent
      String base64WithPrefix = base64Data;
      if (!base64Data.startsWith('data:')) {
        base64WithPrefix = 'data:image/jpeg;base64,$base64Data';
      }

      final typeString = _getTypeString(type);

      final response = await _dioClient.post<Map<String, dynamic>>(
        '/upload/photo',
        data: {'photo_base64': base64WithPrefix, 'type': typeString},
      );

      return response.fold(
        (failure) => UploadResult.failure(failure.message ?? 'Erreur upload'),
        (data) {
          if (data['succes'] == true && data['url'] != null) {
            return UploadResult.success(data['url'] as String);
          }
          return UploadResult.failure(
            data['erreur'] ?? 'Erreur lors de l\'upload',
          );
        },
      );
    } catch (e) {
      return UploadResult.failure('Exception: $e');
    }
  }

  /// Convertit le type d'upload en string pour l'API.
  String _getTypeString(UploadType type) {
    switch (type) {
      case UploadType.portrait:
        return 'portrait';
      case UploadType.photoParent:
        return 'photo_parent';
      case UploadType.signatureAcademicien:
        return 'signature_academicien';
      case UploadType.signatureParent:
        return 'signature_parent';
    }
  }
}

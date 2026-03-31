import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../theme/app_colors.dart';

/// Utilitaire pour le recadrage des images.
class ImageCropperHelper {
  /// Ouvre l'interface de recadrage pour une image donnée.
  /// [imageFile] Le fichier image à recadrer.
  /// [context] Le contexte pour l'affichage de l'interface.
  /// Retourne le fichier recadré ou null si annulé.
  static Future<File?> cropImage({
    required File imageFile,
    required BuildContext context,
    String? title,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title ?? 'Recadrer la photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: title ?? 'Recadrer la photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }
}

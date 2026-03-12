import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:pepites_academy_mobile/src/infrastructure/services/upload_service.dart';
import 'package:pepites_academy_mobile/src/injection_container.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';
import 'package:pepites_academy_mobile/src/presentation/utils/image_compressor.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/signature_pad.dart';

/// Widget permettant l'upload des signatures de l'academicien et du parent/tuteur.
/// La signature de l'academicien est obligatoire, celle du parent est optionnelle.
/// L'upload est effectue immediatement vers le serveur et l'URL est retournee.
class SignatureStep extends StatefulWidget {
  /// Fichier local de la signature de l'academicien (pour affichage)
  final File? signatureAcademicienFile;

  /// URL de la signature de l'academicien (apres upload)
  final String? signatureAcademicienUrl;

  /// Fichier local de la signature du parent/tuteur (pour affichage)
  final File? signatureParentFile;

  /// URL de la signature du parent/tuteur (apres upload)
  final String? signatureParentUrl;

  /// Callback appele lors du changement de la signature de l'academicien
  /// Retourne le fichier local et l'URL serveur
  final void Function(File? file, String? url)? onAcademicienSignatureChanged;

  /// Callback appele lors du changement de la signature du parent
  /// Retourne le fichier local et l'URL serveur
  final void Function(File? file, String? url)? onParentSignatureChanged;

  const SignatureStep({
    super.key,
    this.signatureAcademicienFile,
    this.signatureAcademicienUrl,
    this.signatureParentFile,
    this.signatureParentUrl,
    this.onAcademicienSignatureChanged,
    this.onParentSignatureChanged,
  });

  @override
  State<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends State<SignatureStep> {
  final _picker = ImagePicker();
  bool _isUploadingAcademicien = false;
  bool _isUploadingParent = false;
  bool _hasUploadErrorAcademicien = false;
  bool _hasUploadErrorParent = false;
  File? _pendingAcademicienFile;
  File? _pendingParentFile;

  /// Upload une image et retourne l'URL
  Future<String?> _uploadImage(File file, UploadType type) async {
    try {
      final result = await DependencyInjection.uploadService.uploadImage(
        file,
        type,
      );
      if (result.success && result.url != null) {
        return result.url;
      }
    } catch (e) {
      debugPrint('Erreur upload: $e');
    }
    return null;
  }

  /// Retry l'upload pour l'academicien
  Future<void> _retryAcademicienUpload() async {
    if (_pendingAcademicienFile == null) return;
    setState(() {
      _isUploadingAcademicien = true;
      _hasUploadErrorAcademicien = false;
    });
    final url = await _uploadImage(
      _pendingAcademicienFile!,
      UploadType.signatureAcademicien,
    );
    if (mounted) {
      setState(() {
        _isUploadingAcademicien = false;
        if (url != null) {
          _hasUploadErrorAcademicien = false;
          _pendingAcademicienFile = null;
          widget.onAcademicienSignatureChanged?.call(
            _pendingAcademicienFile,
            url,
          );
        } else {
          _hasUploadErrorAcademicien = true;
        }
      });
    }
  }

  /// Retry l'upload pour le parent
  Future<void> _retryParentUpload() async {
    if (_pendingParentFile == null) return;
    setState(() {
      _isUploadingParent = true;
      _hasUploadErrorParent = false;
    });
    final url = await _uploadImage(
      _pendingParentFile!,
      UploadType.signatureParent,
    );
    if (mounted) {
      setState(() {
        _isUploadingParent = false;
        if (url != null) {
          _hasUploadErrorParent = false;
          _pendingParentFile = null;
          widget.onParentSignatureChanged?.call(_pendingParentFile, url);
        } else {
          _hasUploadErrorParent = true;
        }
      });
    }
  }

  /// Ouvre le dialogue de signature pour dessiner directement
  Future<void> _openSignaturePad(bool isAcademicien) async {
    final file = await SignatureDialog.show(context);
    if (file != null) {
      // Compresser la signature
      final compressedFile = await ImageCompressor.compress(
        imageFile: file,
        quality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (compressedFile != null) {
        // Upload immediat vers le serveur
        setState(() {
          if (isAcademicien) {
            _isUploadingAcademicien = true;
          } else {
            _isUploadingParent = true;
          }
        });

        final uploadType = isAcademicien
            ? UploadType.signatureAcademicien
            : UploadType.signatureParent;
        final url = await _uploadImage(compressedFile, uploadType);

        if (mounted) {
          setState(() {
            if (isAcademicien) {
              _isUploadingAcademicien = false;
              if (url != null) {
                _hasUploadErrorAcademicien = false;
                _pendingAcademicienFile = null;
              } else {
                _hasUploadErrorAcademicien = true;
                _pendingAcademicienFile = compressedFile;
              }
            } else {
              _isUploadingParent = false;
              if (url != null) {
                _hasUploadErrorParent = false;
                _pendingParentFile = null;
              } else {
                _hasUploadErrorParent = true;
                _pendingParentFile = compressedFile;
              }
            }
          });

          if (isAcademicien) {
            widget.onAcademicienSignatureChanged?.call(compressedFile, url);
          } else {
            widget.onParentSignatureChanged?.call(compressedFile, url);
          }
        }
      }
    }
  }

  /// Ouvre la galerie pour selectionner une signature existante
  Future<void> _pickFromGallery(bool isAcademicien) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        // Compresser l'image
        final compressedFile = await ImageCompressor.compress(
          imageFile: File(pickedFile.path),
          quality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        if (compressedFile != null) {
          // Upload immediat vers le serveur
          setState(() {
            if (isAcademicien) {
              _isUploadingAcademicien = true;
            } else {
              _isUploadingParent = true;
            }
          });

          final uploadType = isAcademicien
              ? UploadType.signatureAcademicien
              : UploadType.signatureParent;
          final url = await _uploadImage(compressedFile, uploadType);

          if (mounted) {
            setState(() {
              if (isAcademicien) {
                _isUploadingAcademicien = false;
                if (url != null) {
                  _hasUploadErrorAcademicien = false;
                  _pendingAcademicienFile = null;
                } else {
                  _hasUploadErrorAcademicien = true;
                  _pendingAcademicienFile = compressedFile;
                }
              } else {
                _isUploadingParent = false;
                if (url != null) {
                  _hasUploadErrorParent = false;
                  _pendingParentFile = null;
                } else {
                  _hasUploadErrorParent = true;
                  _pendingParentFile = compressedFile;
                }
              }
            });

            if (isAcademicien) {
              widget.onAcademicienSignatureChanged?.call(compressedFile, url);
            } else {
              widget.onParentSignatureChanged?.call(compressedFile, url);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur selection signature: $e');
    }
  }

  /// Affiche le menu de choix entre dessiner et importer
  Future<void> _pickSignature(bool isAcademicien) async {
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
            // Option dessiner
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
                'Signez directement sur l\'écran avec votre doigt ou un stylet',
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _openSignaturePad(isAcademicien);
              },
            ),
            const SizedBox(height: 8),
            // Option importer
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                'Importer depuis la galerie',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Sélectionnez une image de signature existante',
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(isAcademicien);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tete de section
          Text(
            l10n.signaturesLabel,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.signaturesSubtitle,
            style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Signature de l'academicien (obligatoire)
          _buildSignatureCard(
            context: context,
            title: l10n.academicienSignatureLabel,
            subtitle: l10n.academicienSignatureDesc,
            signatureFile: widget.signatureAcademicienFile,
            signatureUrl: widget.signatureAcademicienUrl,
            isUploading: _isUploadingAcademicien,
            hasUploadError: _hasUploadErrorAcademicien,
            isRequired: true,
            isDark: isDark,
            colorScheme: colorScheme,
            onPick: () => _pickSignature(true),
            onRemove: () {
              setState(() {
                _hasUploadErrorAcademicien = false;
                _pendingAcademicienFile = null;
              });
              widget.onAcademicienSignatureChanged?.call(null, null);
            },
            onRetry: _retryAcademicienUpload,
          ),

          const SizedBox(height: 24),

          // Signature du parent/tuteur (optionnelle)
          _buildSignatureCard(
            context: context,
            title: l10n.parentSignatureLabel,
            subtitle: l10n.parentSignatureDesc,
            signatureFile: widget.signatureParentFile,
            signatureUrl: widget.signatureParentUrl,
            isUploading: _isUploadingParent,
            hasUploadError: _hasUploadErrorParent,
            isRequired: false,
            isDark: isDark,
            colorScheme: colorScheme,
            onPick: () => _pickSignature(false),
            onRemove: () {
              setState(() {
                _hasUploadErrorParent = false;
                _pendingParentFile = null;
              });
              widget.onParentSignatureChanged?.call(null, null);
            },
            onRetry: _retryParentUpload,
          ),

          const SizedBox(height: 24),

          // Note informative
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.signaturesInfo,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required File? signatureFile,
    String? signatureUrl,
    bool isUploading = false,
    bool hasUploadError = false,
    required bool isRequired,
    required bool isDark,
    required ColorScheme colorScheme,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.draw_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRequired) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.requiredLabel,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Zone d'upload ou d'apercu
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: signatureFile != null
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : colorScheme.onSurface.withValues(alpha: 0.1),
                  width: signatureFile != null ? 2 : 1,
                ),
              ),
              child: isUploading
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
                  : hasUploadError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 28,
                          color: Colors.red.shade400,
                        ),
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
                          onPressed: onRetry,
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
                  : signatureFile != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.file(
                            signatureFile,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 36,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.uploadSignatureHint,
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
      ),
    );
  }
}

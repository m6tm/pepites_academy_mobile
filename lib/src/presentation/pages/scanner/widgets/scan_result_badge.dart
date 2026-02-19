import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../application/services/qr_scanner_service.dart';
import '../../../state/qr_scanner_state.dart';
import '../../../theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/presence.dart';

/// Badge affichant le resultat d'un scan QR.
/// Montre la photo, le nom et le statut (Autorise/Refuse/Deja present).
class ScanResultBadge extends StatefulWidget {
  final ScanResult? result;
  final ScannerStatus status;
  final VoidCallback onDismiss;

  const ScanResultBadge({
    super.key,
    required this.result,
    required this.status,
    required this.onDismiss,
  });

  @override
  State<ScanResultBadge> createState() => _ScanResultBadgeState();
}

class _ScanResultBadgeState extends State<ScanResultBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getBackgroundColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getStatusColor().withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icone de statut
                  _buildStatusIcon(),
                  const SizedBox(height: 16),
                  // Photo du profil
                  if (widget.result?.photoUrl != null &&
                      widget.result!.photoUrl!.isNotEmpty)
                    _buildProfilePhoto(),
                  if (widget.result?.photoUrl != null &&
                      widget.result!.photoUrl!.isNotEmpty)
                    const SizedBox(height: 16),
                  // Nom du profil
                  if (widget.result?.success == true)
                    Text(
                      widget.result!.nomComplet,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  // Type de profil
                  if (widget.result?.typeProfil != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getProfilTypeTranslated(
                          widget.result!.typeProfil,
                          AppLocalizations.of(context)!,
                        ).toUpperCase(),
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Message de statut
                  Text(
                    _getStatusMessage(AppLocalizations.of(context)!),
                    style: GoogleFonts.montserrat(
                      color: _getStatusColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Bouton de fermeture
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onDismiss,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.nextScan,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Icone animee selon le statut du scan.
  Widget _buildStatusIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Icon(_getStatusIconData(), color: _getStatusColor(), size: 32),
    );
  }

  /// Photo de profil du scanne.
  Widget _buildProfilePhoto() {
    final photoUrl = widget.result!.photoUrl!;
    final isFile = !photoUrl.startsWith('http');

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withValues(alpha: 0.3),
            blurRadius: 15,
          ),
        ],
      ),
      child: ClipOval(
        child: isFile
            ? Image.file(
                File(photoUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              )
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.3),
      child: const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case ScannerStatus.success:
        return AppColors.success;
      case ScannerStatus.alreadyPresent:
        return AppColors.warning;
      case ScannerStatus.error:
        return AppColors.error;
      default:
        return Colors.white;
    }
  }

  Color _getBackgroundColor() {
    switch (widget.status) {
      case ScannerStatus.success:
        return AppColors.success;
      case ScannerStatus.alreadyPresent:
        return AppColors.warning;
      case ScannerStatus.error:
        return AppColors.error;
      default:
        return Colors.black;
    }
  }

  IconData _getStatusIconData() {
    switch (widget.status) {
      case ScannerStatus.success:
        return Icons.check_circle_rounded;
      case ScannerStatus.alreadyPresent:
        return Icons.info_rounded;
      case ScannerStatus.error:
        return Icons.cancel_rounded;
      default:
        return Icons.qr_code_scanner_rounded;
    }
  }

  String _getStatusMessage(AppLocalizations l10n) {
    if (widget.result == null) return l10n.unknownError;
    switch (widget.status) {
      case ScannerStatus.success:
        return l10n.attendanceRecordedSuccess;
      case ScannerStatus.alreadyPresent:
        return l10n.alreadyRegisteredForSession;
      case ScannerStatus.error:
        return widget.result!.message;
      default:
        return '';
    }
  }

  String _getProfilTypeTranslated(ProfilType? type, AppLocalizations l10n) {
    if (type == null) return '';
    switch (type) {
      case ProfilType.academicien:
        return l10n.academician;
      case ProfilType.encadreur:
        return l10n.coach;
    }
  }
}

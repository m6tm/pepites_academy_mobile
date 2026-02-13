import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../theme/app_colors.dart';

/// Tuile representant un academicien dans la liste d'annotations.
/// Affiche la photo, le nom et le nombre d'annotations deja faites.
class AcademicienAnnotationTile extends StatelessWidget {
  final Academicien academicien;
  final int nbAnnotations;
  final bool isDark;
  final VoidCallback onTap;

  const AcademicienAnnotationTile({
    super.key,
    required this.academicien,
    required this.nbAnnotations,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfos()),
              _buildAnnotationBadge(),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: academicien.photoUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                academicien.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(),
              ),
            )
          : _buildAvatarFallback(),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        '${academicien.prenom.isNotEmpty ? academicien.prenom[0] : ''}${academicien.nom.isNotEmpty ? academicien.nom[0] : ''}',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${academicien.prenom} ${academicien.nom}',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Appuyez pour annoter',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnotationBadge() {
    if (nbAnnotations == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$nbAnnotations',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppColors.success,
        ),
      ),
    );
  }
}

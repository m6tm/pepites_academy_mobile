import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glassmorphism_card.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/academy_toast.dart';

class RegistrationSuccessPage extends StatelessWidget {
  final String academicienName;
  final String qrData;
  final String? photoPath;

  const RegistrationSuccessPage({
    super.key,
    required this.academicienName,
    required this.qrData,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1C1C1C), const Color(0xFF2D0A0A)]
                : [Colors.white, const Color(0xFFFFEBEE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildSuccessHeader(l10n),
              const Spacer(),
              _buildBadgeCard(context, l10n),
              const Spacer(),
              _buildActionButtons(context, l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.registrationSuccessTitle,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.academicianBadgeReady(academicienName),
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GlassmorphismCard(
        blurSigma: 20,
        backgroundColor: Colors.white,
        backgroundOpacity: 0.1,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 30,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.sports_soccer, color: AppColors.primary),
                ),
                const Spacer(),
                Text(
                  l10n.appTitle.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              academicienName.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              l10n.officialBadge,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Implementation of sharing
              AcademyToast.show(
                context,
                title: l10n.sharingInProgress,
                description: l10n.featureComingSoon,
                icon: Icons.share_rounded,
              );
            },
            icon: const Icon(Icons.share),
            label: Text(l10n.shareBadgeAction),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home),
            label: Text(l10n.backToDashboard),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
        ],
      ),
    );
  }
}

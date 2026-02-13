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
              _buildSuccessHeader(),
              const Spacer(),
              _buildBadgeCard(context),
              const Spacer(),
              _buildActionButtons(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
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
        const Text(
          "Inscription Réussie !",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Le badge de $academicienName est prêt.",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(BuildContext context) {
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
                const Text(
                  "PÉPITES ACADEMY",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
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
            const Text(
              "BADGE OFFICIEL",
              style: TextStyle(
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

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Implementation of sharing
              AcademyToast.show(
                context,
                title: 'Partage en cours...',
                description: 'Fonctionnalite bientot disponible.',
                icon: Icons.share_rounded,
              );
            },
            icon: const Icon(Icons.share),
            label: const Text("PARTAGER LE BADGE"),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home),
            label: const Text("RETOUR AU DASHBOARD"),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
        ],
      ),
    );
  }
}

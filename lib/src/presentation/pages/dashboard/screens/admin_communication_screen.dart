import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../widgets/admin_internal_widgets.dart';

/// Ecran Communication du dashboard administrateur.
/// Gestion des SMS et notifications avec historique.
class AdminCommunicationScreen extends StatelessWidget {
  const AdminCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Communication',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SMS et notifications',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Statistiques SMS
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: MiniStatCard(
                    label: 'Envoyes',
                    value: '128',
                    icon: Icons.send_rounded,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: MiniStatCard(
                    label: 'Ce mois',
                    value: '34',
                    icon: Icons.calendar_month_rounded,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniStatCard(
                    label: 'En echec',
                    value: '2',
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Actions de communication
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                CommunicationAction(
                  title: 'Nouveau message',
                  subtitle: 'Rediger et envoyer un SMS',
                  icon: Icons.edit_rounded,
                  color: AppColors.primary,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                CommunicationAction(
                  title: 'Message groupe',
                  subtitle: 'Envoyer a un groupe filtre',
                  icon: Icons.group_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                CommunicationAction(
                  title: 'Historique SMS',
                  subtitle: 'Consulter les messages envoyes',
                  icon: Icons.history_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Derniers messages',
            actionLabel: 'Historique',
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final messages = [
              SmsData(
                'Rappel entrainement',
                '15 destinataires',
                '12 Fev',
                true,
              ),
              SmsData(
                'Match amical samedi',
                '22 destinataires',
                '11 Fev',
                true,
              ),
              SmsData(
                'Changement horaire',
                '8 destinataires',
                '10 Fev',
                false,
              ),
            ];
            final msg = messages[index];
            return SmsListItem(data: msg, isDark: isDark);
          }, childCount: 3),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

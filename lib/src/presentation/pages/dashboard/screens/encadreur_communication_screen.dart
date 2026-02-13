import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/sms_message.dart';
import '../../../../injection_container.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../sms/sms_compose_page.dart';
import '../../sms/sms_history_page.dart';
import '../widgets/admin_internal_widgets.dart';

/// Ecran Communication du dashboard encadreur.
/// Permet aux encadreurs d'envoyer des SMS aux academiciens et parents.
class EncadreurCommunicationScreen extends StatefulWidget {
  const EncadreurCommunicationScreen({super.key});

  @override
  State<EncadreurCommunicationScreen> createState() =>
      _EncadreurCommunicationScreenState();
}

class _EncadreurCommunicationScreenState
    extends State<EncadreurCommunicationScreen> {
  @override
  void initState() {
    super.initState();
    DependencyInjection.smsState.chargerHistorique();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: DependencyInjection.smsState,
      builder: (context, _) {
        final stats = DependencyInjection.smsState.statistiques;
        final historique = DependencyInjection.smsState.historique;

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
                      'Envoyez des SMS aux academiciens et parents',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Statistiques SMS dynamiques
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: MiniStatCard(
                        label: 'Envoyes',
                        value: '${stats['totalEnvoyes'] ?? 0}',
                        icon: Icons.send_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MiniStatCard(
                        label: 'Ce mois',
                        value: '${stats['envoyesCeMois'] ?? 0}',
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MiniStatCard(
                        label: 'En echec',
                        value: '${stats['enEchec'] ?? 0}',
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
                      onTap: () {
                        DependencyInjection.smsState.reinitialiser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SmsComposePage(
                              smsState: DependencyInjection.smsState,
                            ),
                          ),
                        ).then((_) {
                          DependencyInjection.smsState.chargerHistorique();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    CommunicationAction(
                      title: 'Message groupe',
                      subtitle: 'Envoyer a un groupe filtre',
                      icon: Icons.group_rounded,
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        DependencyInjection.smsState.reinitialiser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SmsComposePage(
                              smsState: DependencyInjection.smsState,
                            ),
                          ),
                        ).then((_) {
                          DependencyInjection.smsState.chargerHistorique();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    CommunicationAction(
                      title: 'Historique SMS',
                      subtitle: 'Consulter les messages envoyes',
                      icon: Icons.history_rounded,
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SmsHistoryPage(
                              smsState: DependencyInjection.smsState,
                            ),
                          ),
                        ).then((_) {
                          DependencyInjection.smsState.chargerHistorique();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionTitle(
                title: 'Derniers messages',
                actionLabel: 'Historique',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SmsHistoryPage(
                        smsState: DependencyInjection.smsState,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Derniers messages dynamiques
            if (historique.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Center(
                    child: Text(
                      'Aucun message envoye pour le moment.',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sms = historique[index];
                    final isSuccess = sms.statut == StatutEnvoi.envoye;
                    return SmsListItem(
                      data: SmsData(
                        sms.contenu.length > 40
                            ? '${sms.contenu.substring(0, 40)}...'
                            : sms.contenu,
                        '${sms.destinataires.length} destinataire${sms.destinataires.length > 1 ? 's' : ''}',
                        _formatDateCourte(sms.dateEnvoi),
                        isSuccess,
                      ),
                      isDark: isDark,
                    );
                  },
                  childCount: historique.length > 5 ? 5 : historique.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }

  String _formatDateCourte(DateTime date) {
    const mois = [
      'Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aout', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${mois[date.month - 1]}';
  }
}

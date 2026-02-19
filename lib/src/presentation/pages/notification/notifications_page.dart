import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/notification_item.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Page de notifications pour les administrateurs et encadreurs.
/// Affiche la liste des notifications avec filtrage par type,
/// marquage comme lu et suppression par glissement.
class NotificationsPage extends StatefulWidget {
  /// Role de l'utilisateur courant ('admin' ou 'encadreur').
  final String userRole;

  const NotificationsPage({super.key, required this.userRole});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    DependencyInjection.notificationState.chargerNotifications(widget.userRole);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListenableBuilder(
            listenable: DependencyInjection.notificationState,
            builder: (context, _) {
              final state = DependencyInjection.notificationState;
              final notifications = state.notificationsFiltrees;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(colorScheme, isDark)),
                  SliverToBoxAdapter(child: _buildFilters(colorScheme, isDark)),
                  if (state.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (notifications.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState(colorScheme))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final notification = notifications[index];
                          return _buildNotificationTile(
                            notification,
                            colorScheme,
                            isDark,
                            isLast: index == notifications.length - 1,
                          );
                        }, childCount: notifications.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// En-tete de la page avec titre, compteur et actions.
  Widget _buildHeader(ColorScheme colorScheme, bool isDark) {
    final state = DependencyInjection.notificationState;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notifications,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (state.nonLuesCount > 0)
                      Text(
                        l10n.unreadCount(state.nonLuesCount),
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              _buildHeaderAction(
                icon: Icons.done_all_rounded,
                tooltip: l10n.markAllAsRead,
                colorScheme: colorScheme,
                onTap: state.nonLuesCount > 0
                    ? () => state.marquerToutesCommeLues(widget.userRole)
                    : null,
              ),
              const SizedBox(width: 8),
              _buildHeaderAction(
                icon: Icons.delete_sweep_rounded,
                tooltip: l10n.deleteRead,
                colorScheme: colorScheme,
                onTap: () => _confirmerSuppression(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bouton d'action dans l'en-tete.
  Widget _buildHeaderAction({
    required IconData icon,
    required String tooltip,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Icon(
            icon,
            color: isDisabled
                ? colorScheme.onSurface.withValues(alpha: 0.2)
                : colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Barre de filtres horizontale.
  Widget _buildFilters(ColorScheme colorScheme, bool isDark) {
    final state = DependencyInjection.notificationState;
    final l10n = AppLocalizations.of(context)!;

    final filtres = <_FiltreOption>[
      _FiltreOption(label: l10n.all, type: null),
      _FiltreOption(label: l10n.sessions, type: NotificationType.seance),
      _FiltreOption(label: l10n.presences, type: NotificationType.presence),
      _FiltreOption(
        label: l10n.registrations,
        type: NotificationType.inscription,
      ),
      _FiltreOption(label: l10n.smsLabel, type: NotificationType.sms),
      _FiltreOption(label: l10n.reminders, type: NotificationType.rappel),
      _FiltreOption(label: l10n.system, type: NotificationType.systeme),
    ];

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filtres.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filtre = filtres[index];
              final isSelected = state.filtreType == filtre.type;
              return GestureDetector(
                onTap: () => state.setFiltreType(filtre.type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    filtre.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => state.toggleNonLuesUniquement(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: state.afficherNonLuesUniquement
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.afficherNonLuesUniquement
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.afficherNonLuesUniquement
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 14,
                        color: state.afficherNonLuesUniquement
                            ? AppColors.primary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.unreadOnly,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: state.afficherNonLuesUniquement
                              ? AppColors.primary
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tuile de notification individuelle avec swipe pour supprimer.
  Widget _buildNotificationTile(
    NotificationItem notification,
    ColorScheme colorScheme,
    bool isDark, {
    bool isLast = false,
  }) {
    final typeInfo = _getTypeInfo(notification.type);
    final prioriteColor = _getPrioriteColor(notification.priorite);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.delete_rounded,
            color: AppColors.error,
            size: 24,
          ),
        ),
        onDismissed: (_) {
          DependencyInjection.notificationState.supprimer(
            notification.id,
            widget.userRole,
          );
        },
        child: GlassmorphismCard(
          padding: const EdgeInsets.all(16),
          backgroundOpacity: notification.estLue ? 0.04 : 0.08,
          borderOpacity: notification.estLue ? 0.08 : 0.15,
          onTap: () {
            if (!notification.estLue) {
              DependencyInjection.notificationState.marquerCommeLue(
                notification.id,
                widget.userRole,
              );
            }
            _afficherDetail(notification);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icone du type
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeInfo.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(typeInfo.icon, color: typeInfo.color, size: 22),
              ),
              const SizedBox(width: 14),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!notification.estLue)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: notification.estLue
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Badge de priorite
                        if (notification.priorite !=
                            NotificationPriority.normale)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: prioriteColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getPrioriteLabel(notification.priorite),
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: prioriteColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        // Badge du type
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: typeInfo.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeInfo.label,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeInfo.color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Temps relatif
                        Text(
                          _formatTempsRelatif(notification.dateCreation),
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Etat vide lorsqu'aucune notification n'est disponible.
  Widget _buildEmptyState(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 48,
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noNotification,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationsUpToDate,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche le detail d'une notification dans un bottom sheet.
  void _afficherDetail(NotificationItem notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeInfo = _getTypeInfo(notification.type);
    final prioriteColor = _getPrioriteColor(notification.priorite);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignee
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tete avec icone
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: typeInfo.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              typeInfo.icon,
                              color: typeInfo.color,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.titre,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: typeInfo.color.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        typeInfo.label,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: typeInfo.color,
                                        ),
                                      ),
                                    ),
                                    if (notification.priorite !=
                                        NotificationPriority.normale) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: prioriteColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          _getPrioriteLabel(
                                            notification.priorite,
                                          ),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: prioriteColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Description complete
                      Text(
                        notification.description,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Date
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDateComplete(notification.dateCreation),
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bouton supprimer
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            DependencyInjection.notificationState.supprimer(
                              notification.id,
                              widget.userRole,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                          ),
                          label: Text(
                            AppLocalizations.of(
                              context,
                            )!.deleteThisNotification,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dialogue de confirmation pour la suppression des notifications lues.
  void _confirmerSuppression() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.deleteRead,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.deleteReadConfirmation,
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel, style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                DependencyInjection.notificationState.supprimerLues(
                  widget.userRole,
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(
                l10n.delete,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Retourne les informations visuelles associees a un type de notification.
  _TypeInfo _getTypeInfo(NotificationType type) {
    switch (type) {
      case NotificationType.seance:
        return _TypeInfo(
          icon: Icons.sports_soccer_rounded,
          color: const Color(0xFF10B981),
          label: AppLocalizations.of(context)!.sessions,
        );
      case NotificationType.presence:
        return _TypeInfo(
          icon: Icons.fact_check_rounded,
          color: const Color(0xFF3B82F6),
          label: AppLocalizations.of(context)!.presences,
        );
      case NotificationType.inscription:
        return _TypeInfo(
          icon: Icons.person_add_rounded,
          color: const Color(0xFF8B5CF6),
          label: AppLocalizations.of(context)!.registrations,
        );
      case NotificationType.sms:
        return _TypeInfo(
          icon: Icons.sms_rounded,
          color: const Color(0xFFF59E0B),
          label: AppLocalizations.of(context)!.smsLabel,
        );
      case NotificationType.bulletin:
        return _TypeInfo(
          icon: Icons.description_rounded,
          color: const Color(0xFFEC4899),
          label: AppLocalizations.of(context)!.bulletin,
        );
      case NotificationType.systeme:
        return _TypeInfo(
          icon: Icons.settings_rounded,
          color: const Color(0xFF6B7280),
          label: AppLocalizations.of(context)!.system,
        );
      case NotificationType.rappel:
        return _TypeInfo(
          icon: Icons.alarm_rounded,
          color: AppColors.primary,
          label: AppLocalizations.of(context)!.reminders,
        );
    }
  }

  /// Retourne la couleur associee a une priorite.
  Color _getPrioriteColor(NotificationPriority priorite) {
    switch (priorite) {
      case NotificationPriority.basse:
        return const Color(0xFF6B7280);
      case NotificationPriority.normale:
        return const Color(0xFF3B82F6);
      case NotificationPriority.haute:
        return const Color(0xFFF59E0B);
      case NotificationPriority.urgente:
        return AppColors.error;
    }
  }

  /// Retourne le libelle d'une priorite.
  String _getPrioriteLabel(NotificationPriority priorite) {
    final l10n = AppLocalizations.of(context)!;
    switch (priorite) {
      case NotificationPriority.basse:
        return l10n.low;
      case NotificationPriority.normale:
        return l10n.normal;
      case NotificationPriority.haute:
        return l10n.high;
      case NotificationPriority.urgente:
        return l10n.urgent;
    }
  }

  /// Formate une date en temps relatif.
  String _formatTempsRelatif(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inMinutes < 1) return l10n.justNow;
    if (difference.inMinutes < 60) return l10n.minutesAgo(difference.inMinutes);
    if (difference.inHours < 24) return l10n.hoursAgo(difference.inHours);
    if (difference.inDays == 1) return l10n.yesterday;
    if (difference.inDays < 7) return l10n.daysAgo(difference.inDays);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formate une date complete (ex: "Lundi 15 Fevrier 2026 a 14h30").
  String _formatDateComplete(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final jours = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
    final mois = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    final jour = jours[date.weekday - 1];
    final nomMois = mois[date.month - 1];
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$jour ${date.day} $nomMois ${date.year} ${l10n.at} ${heure}h$minute';
  }
}

/// Modele interne pour les informations visuelles d'un type de notification.
class _TypeInfo {
  final IconData icon;
  final Color color;
  final String label;

  const _TypeInfo({
    required this.icon,
    required this.color,
    required this.label,
  });
}

/// Modele interne pour les options de filtre.
class _FiltreOption {
  final String label;
  final NotificationType? type;

  const _FiltreOption({required this.label, required this.type});
}

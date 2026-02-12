import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Un Snackbar personnalisé inspiré du design "Toast" de Shadcn UI.
/// Plus moderne, flottant, et avec des micro-animations.
class AcademyToast extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AcademyToast({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onAction,
    this.actionLabel,
  });

  /// Méthode statique pour afficher le toast facilement.
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    IconData? icon,
    bool isError = false,
    bool isSuccess = false,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Détermination de la couleur de fond type Shadcn (Border + Background subtil)
    Color bgColor = colorScheme.surface;
    Color borderColor = colorScheme.outlineVariant.withValues(alpha: 0.5);
    Color primaryColor = colorScheme.onSurface;

    if (isError) {
      bgColor = colorScheme.errorContainer;
      borderColor = colorScheme.error.withValues(alpha: 0.2);
      primaryColor = colorScheme.onErrorContainer;
    } else if (isSuccess) {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.withValues(alpha: 0.2);
      primaryColor = Colors.green.shade900;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null || isError || isSuccess)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  icon ??
                      (isError
                          ? Icons.error_outline
                          : Icons.check_circle_outline),
                  color: primaryColor,
                  size: 20,
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  if (description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onAction != null && actionLabel != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: primaryColor,
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: primaryColor.withValues(alpha: 0.4),
              ),
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // Ce widget n'est pas utilisé directement car on utilise la méthode statique show()
    return const SizedBox.shrink();
  }
}

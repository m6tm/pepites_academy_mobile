import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../academy/academicien_list_page.dart';

/// Ecran Academie du dashboard administrateur.
/// Affiche directement la liste des academiciens.
class AdminAcademyScreen extends StatelessWidget {
  final GlobalKey<AcademicienListPageState>? academyListKey;
  final VoidCallback? onBackPressed;

  const AdminAcademyScreen({
    super.key,
    this.academyListKey,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AcademicienListPage(
      key: academyListKey,
      repository: DependencyInjection.academicienRepository,
      onBackPressed: onBackPressed,
    );
  }
}

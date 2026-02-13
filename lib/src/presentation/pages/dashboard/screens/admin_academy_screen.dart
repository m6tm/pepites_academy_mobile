import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../academy/academicien_list_page.dart';

/// Ecran Academie du dashboard administrateur.
/// Affiche directement la liste des academiciens.
class AdminAcademyScreen extends StatelessWidget {
  const AdminAcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AcademicienListPage(
      repository: DependencyInjection.academicienRepository,
    );
  }
}

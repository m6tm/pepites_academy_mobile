import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';
import '../../../domain/entities/exercice.dart';
import '../../state/exercice_state.dart';
import '../../widgets/glass_text_field.dart';
import '../../../injection_container.dart';
import '../../../domain/entities/permission.dart';
import '../../widgets/academy_toast.dart';

class ExerciceFormPage extends StatefulWidget {
  final String atelierId;
  final Exercice? exercice;
  final ExerciceState exerciceState;

  const ExerciceFormPage({
    super.key,
    required this.atelierId,
    this.exercice,
    required this.exerciceState,
  });

  @override
  State<ExerciceFormPage> createState() => _ExerciceFormPageState();
}

class _ExerciceFormPageState extends State<ExerciceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _nomController = TextEditingController(text: widget.exercice?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.exercice?.description ?? '');
  }

  Future<void> _checkPermissions() async {
    final role = await DependencyInjection.roleService.getCurrentUserRole();
    final requiredPermission = widget.exercice == null 
        ? Permission.exerciceCreate 
        : Permission.exerciceUpdate;
    
    if (!role.hasPermission(requiredPermission)) {
      if (mounted) {
        AcademyToast.show(
          context, 
          title: 'Permission insuffisante', 
          isError: true,
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    bool success;
    if (widget.exercice == null) {
      success = await widget.exerciceState.ajouterExercice(
        atelierId: widget.atelierId,
        nom: _nomController.text.trim(),
        description: _descriptionController.text.trim(),
        statut: ExerciceStatut.valide,
      );
    } else {
      success = await widget.exerciceState.modifierExercice(
        widget.exercice!.copyWith(
          nom: _nomController.text.trim(),
          description: _descriptionController.text.trim(),
          statut: ExerciceStatut.valide,
        ),
      );
    }

    if (mounted && success) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      // Les messages d'erreur sont gérés par le state via MessageStateMixin
      // mais on peut rajouter un toast si besoin
      if (widget.exerciceState.errorMessage != null) {
        AcademyToast.show(
          context,
          title: widget.exerciceState.errorMessage!,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(textColor),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(textColor),
                          const SizedBox(height: 32),
                          
                          GlassTextField(
                            label: 'Nom de l\'exercice *',
                            hint: 'Ex: Slalom entre les plots',
                            controller: _nomController,
                            prefixIcon: Icons.fitness_center_rounded,
                            validator: (val) => (val == null || val.isEmpty) 
                                ? 'Le nom est obligatoire' : null,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          GlassTextField(
                            label: 'Description',
                            hint: 'Consignes et variantes...',
                            controller: _descriptionController,
                            prefixIcon: Icons.description_rounded,
                            maxLines: 4,
                          ),
                          
                          const SizedBox(height: 40),
                          
                          _buildSubmitButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: textColor),
          ),
          if (widget.exercice != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'MODIFICATION',
                style: GoogleFonts.montserrat(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.exercice == null ? 'Créer un exercice' : 'Modifier l\'exercice',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'VALIDER L\'EXERCICE',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}

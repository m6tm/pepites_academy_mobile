import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/historique_parcours_sportif.dart';
import '../../../domain/entities/niveau_scolaire.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../injection_container.dart';
import '../../../infrastructure/services/upload_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/image_compressor.dart';
import '../../utils/image_cropper_helper.dart';
import '../../widgets/academy_toast.dart';
import 'registration/steps/signature_step.dart';

/// Page d'inscription pour un nouvel académicien.
/// Processus étape par étape (Step-by-Step) avec design premium.
class AcademicienRegistrationPage extends StatefulWidget {
  const AcademicienRegistrationPage({super.key});

  @override
  State<AcademicienRegistrationPage> createState() =>
      _AcademicienRegistrationPageState();
}

class _AcademicienRegistrationPageState
    extends State<AcademicienRegistrationPage> {
  final PageController _pageController = PageController();
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  int _currentStep = 0;
  final int _totalSteps = 8;
  bool _isLoading = false;
  Academicien? _createdAcademicien;

  // Photo academicien
  File? _photoFile;
  String? _photoUrl;
  bool _isUploadingPhoto = false;
  bool _hasPhotoUploadError = false;
  // Photo parent
  File? _photoParentFile;
  String? _photoParentUrl;
  bool _isUploadingPhotoParent = false;
  bool _hasPhotoParentUploadError = false;
  // Photo tuteur
  File? _photoTuteurFile;
  String? _photoTuteurUrl;
  bool _isUploadingPhotoTuteur = false;
  bool _hasPhotoTuteurUploadError = false;
  // Signatures
  File? _signatureAcademicienFile;
  String? _signatureAcademicienUrl;
  File? _signatureParentFile;
  String? _signatureParentUrl;
  final _picker = ImagePicker();

  // Form keys
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Data Controllers - Step 1 (Informations personnelles)
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _lieuNaissanceController = TextEditingController();
  final _nationaliteController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSexe;

  // Data Controllers - Step 2 (Contact)
  final _telephoneEleveController = TextEditingController();
  final _tailleController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _twitterController = TextEditingController();
  final _facebookController = TextEditingController();

  // Data Controllers - Step 3 (Parent/Tuteur)
  final _nomParentController = TextEditingController();
  final _prenomParentController = TextEditingController();
  final _fonctionParentController = TextEditingController();
  final _telephoneParentController = TextEditingController();
  final _nomTuteurController = TextEditingController();
  final _prenomTuteurController = TextEditingController();
  final _fonctionTuteurController = TextEditingController();
  final _telephoneTuteurController = TextEditingController();
  String? _garantType; // 'parent' | 'tuteur'
  final _emailGarantController = TextEditingController();
  final _adresseGarantController = TextEditingController();

  // Data - Step 4 (Football)
  String? _selectedPosteId;
  String? _selectedPiedFort;
  final _atoutsController = TextEditingController();
  final _faiblessesController = TextEditingController();
  bool? _aProblemesPeau;
  bool? _aAllergie;
  final _allergieDetailsController = TextEditingController();
  bool? _aimeTravailGroupe;
  final _descriptionPerformancesController = TextEditingController();

  // Data - Step 5 (Historique sportif)
  final List<HistoriqueParcoursSportif> _historiqueParcours = [];

  // Data - Step 6 (Scolaire)
  String? _selectedNiveauId;
  final _etablissementScolaireController = TextEditingController();
  final _anneeScolaireActuelleController = TextEditingController();
  final _remarquesScolairesController = TextEditingController();
  File? _certificatMedicalFile;
  String? _certificatMedicalUrl;
  bool _isUploadingCertificat = false;
  bool _hasCertificatUploadError = false;
  String? _certificatMedicalFileName;

  // Donnees chargees dynamiquement depuis les referentiels
  List<PosteFootball> _postes = [];
  List<NiveauScolaire> _niveaux = [];

  @override
  void initState() {
    super.initState();
    _chargerReferentiels();
  }

  Future<void> _chargerReferentiels() async {
    final postes = await DependencyInjection.referentielService.getAllPostes();
    final niveaux = await DependencyInjection.referentielService
        .getAllNiveaux();
    if (mounted) {
      setState(() {
        _postes = postes;
        _niveaux = niveaux;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _lieuNaissanceController.dispose();
    _nationaliteController.dispose();
    _telephoneEleveController.dispose();
    _tailleController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _nomParentController.dispose();
    _prenomParentController.dispose();
    _fonctionParentController.dispose();
    _telephoneParentController.dispose();
    _nomTuteurController.dispose();
    _prenomTuteurController.dispose();
    _fonctionTuteurController.dispose();
    _telephoneTuteurController.dispose();
    _emailGarantController.dispose();
    _adresseGarantController.dispose();
    _atoutsController.dispose();
    _faiblessesController.dispose();
    _allergieDetailsController.dispose();
    _descriptionPerformancesController.dispose();
    _etablissementScolaireController.dispose();
    _anneeScolaireActuelleController.dispose();
    _remarquesScolairesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    bool isValid = false;
    if (_currentStep == 0) {
      // Vérification de la photo de profil
      if (_photoFile == null) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.photoRequiredError,
          isError: true,
        );
        return;
      }
      isValid = _step1Key.currentState!.validate();
      if (isValid && _selectedSexe == null) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.genderRequiredError,
          isError: true,
        );
        isValid = false;
      }
    } else if (_currentStep == 1) {
      isValid = _step2Key.currentState!.validate();
    } else if (_currentStep == 2) {
      isValid = _step3Key.currentState!.validate();
      if (isValid && _garantType == null) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.guarantorRequiredError,
          isError: true,
        );
        isValid = false;
      }
    } else if (_currentStep == 3) {
      if (_selectedPosteId == null) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.selectPosteAndPiedError,
          isError: true,
        );
      } else {
        isValid = true;
      }
    } else if (_currentStep == 4) {
      isValid = true; // Historique step - optional
    } else if (_currentStep == 5) {
      if (_selectedNiveauId == null) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.selectSchoolLevelError,
          isError: true,
        );
      } else if (_etablissementScolaireController.text.trim().isEmpty ||
          _anneeScolaireActuelleController.text.trim().isEmpty) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.schoolFieldsRequiredError,
          isError: true,
        );
      } else {
        isValid = true;
      }
    } else if (_currentStep == 6) {
      // Validation signatures - verification basee sur l'URL serveur
      if (_signatureAcademicienUrl == null ||
          _signatureAcademicienUrl!.isEmpty) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.signatureRequiredError,
          isError: true,
        );
      } else {
        isValid = true;
      }
    }

    if (isValid && _currentStep < _totalSteps - 1) {
      if (_currentStep == 6) {
        _confirmAndCreate();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _confirmAndCreate() async {
    setState(() => _isLoading = true);

    try {
      final qrCode = _generateQrCode();

      final academicien = Academicien(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        dateNaissance: _selectedDate!,
        lieuNaissance: _lieuNaissanceController.text.trim(),
        nationalite: _nationaliteController.text.trim(),
        sexe: _selectedSexe ?? '',
        photoUrl: _photoUrl ?? _photoFile?.path ?? '',
        telephoneEleve: _telephoneEleveController.text.trim(),
        taille: int.tryParse(_tailleController.text.trim()) ?? 0,
        email: _emailController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        twitter: _twitterController.text.trim().isNotEmpty
            ? _twitterController.text.trim()
            : null,
        facebook: _facebookController.text.trim().isNotEmpty
            ? _facebookController.text.trim()
            : null,
        posteFootballId: _selectedPosteId!,
        niveauScolaireId: _selectedNiveauId!,
        codeQrUnique: qrCode,
        piedFort: _selectedPiedFort,
        nomParent: _nomParentController.text.trim(),
        prenomParent: _prenomParentController.text.trim(),
        fonctionParent: _fonctionParentController.text.trim(),
        telephoneParent: _telephoneParentController.text.trim(),
        photoParentUrl: _photoParentUrl ?? _photoParentFile?.path,
        nomTuteur: _nomTuteurController.text.trim(),
        prenomTuteur: _prenomTuteurController.text.trim(),
        fonctionTuteur: _fonctionTuteurController.text.trim(),
        telephoneTuteur: _telephoneTuteurController.text.trim(),
        photoTuteurUrl: _photoTuteurUrl ?? _photoTuteurFile?.path,
        garantType: _garantType,
        emailGarant: _emailGarantController.text.trim(),
        adresseGarant: _adresseGarantController.text.trim(),
        atouts: _atoutsController.text.trim().isNotEmpty
            ? _atoutsController.text.trim()
            : null,
        faiblesses: _faiblessesController.text.trim().isNotEmpty
            ? _faiblessesController.text.trim()
            : null,
        descriptionPerformances:
            _descriptionPerformancesController.text.trim().isNotEmpty
            ? _descriptionPerformancesController.text.trim()
            : null,
        aProblemesPeau: _aProblemesPeau,
        aAllergie: _aAllergie,
        allergieDetails: _allergieDetailsController.text.trim().isNotEmpty
            ? _allergieDetailsController.text.trim()
            : null,
        aimeTravailGroupe: _aimeTravailGroupe,
        historiqueParcours: _historiqueParcours,
        etablissementScolaire:
            _etablissementScolaireController.text.trim().isNotEmpty
            ? _etablissementScolaireController.text.trim()
            : null,
        anneeScolaireActuelle:
            _anneeScolaireActuelleController.text.trim().isNotEmpty
            ? _anneeScolaireActuelleController.text.trim()
            : null,
        remarquesScolaires: _remarquesScolairesController.text.trim().isNotEmpty
            ? _remarquesScolairesController.text.trim()
            : null,
        certificatMedicalUrl:
            _certificatMedicalUrl ?? _certificatMedicalFile?.path,
        signatureAcademicienUrl:
            _signatureAcademicienUrl ?? _signatureAcademicienFile?.path,
        signatureParentUrl: _signatureParentUrl ?? _signatureParentFile?.path,
      );

      final created = await DependencyInjection.academicienRepository.create(
        academicien,
      );

      if (mounted) {
        setState(() {
          _createdAcademicien = created;
          _isLoading = false;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AcademyToast.show(
          context,
          title: l10n.error,
          description: l10n.academicianSaveError(e.toString()),
          isError: true,
        );
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Qualite max, la compression se fait apres
      );
      if (pickedFile != null) {
        if (mounted) {
          final croppedFile = await ImageCropperHelper.cropImage(
            imageFile: File(pickedFile.path),
            context: context,
            title: l10n.academicianPhotoTitle,
          );

          if (croppedFile != null) {
            // Compresser l'image avant de la stocker
            final compressedFile = await ImageCompressor.compress(
              imageFile: croppedFile,
              quality: 85,
              maxWidth: 1024,
              maxHeight: 1024,
            );
            if (compressedFile != null) {
              await _uploadPhoto(compressedFile);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur selection image: $e');
      if (mounted) {
        AcademyToast.show(
          context,
          title: l10n.error,
          description: l10n.galleryOpenError,
          isError: true,
        );
      }
    }
  }

  Future<void> _pickParentImage() => _pickPersonImage(_PhotoTarget.parent);

  Future<void> _pickTuteurImage() => _pickPersonImage(_PhotoTarget.tuteur);

  Future<void> _pickPersonImage(_PhotoTarget target) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        if (mounted) {
          final croppedFile = await ImageCropperHelper.cropImage(
            imageFile: File(pickedFile.path),
            context: context,
            title: target == _PhotoTarget.parent
                ? l10n.parentPhotoTitle
                : l10n.tuteurPhotoTitle,
          );

          if (croppedFile != null) {
            final compressedFile = await ImageCompressor.compress(
              imageFile: croppedFile,
              quality: 85,
              maxWidth: 1024,
              maxHeight: 1024,
            );
            if (compressedFile != null) {
              await _uploadPhoto(compressedFile, target: target);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur selection image $target: $e');
      if (mounted) {
        AcademyToast.show(
          context,
          title: l10n.error,
          description: l10n.galleryOpenError,
          isError: true,
        );
      }
    }
  }

  /// Upload une photo avec gestion d'erreur
  Future<void> _uploadPhoto(File file, {_PhotoTarget? target}) async {
    final isAcademicien = target == null;
    final isTuteur = target == _PhotoTarget.tuteur;
    setState(() {
      if (isAcademicien) {
        _isUploadingPhoto = true;
        _hasPhotoUploadError = false;
      } else if (isTuteur) {
        _isUploadingPhotoTuteur = true;
        _hasPhotoTuteurUploadError = false;
      } else {
        _isUploadingPhotoParent = true;
        _hasPhotoParentUploadError = false;
      }
    });

    try {
      final uploadType = isAcademicien
          ? UploadType.portrait
          : isTuteur
          ? UploadType.photoTuteur
          : UploadType.photoParent;
      final result = await DependencyInjection.uploadService.uploadImage(
        file,
        uploadType,
      );
      if (mounted) {
        setState(() {
          if (isAcademicien) {
            _isUploadingPhoto = false;
            _photoFile = file;
            if (result.success && result.url != null) {
              _photoUrl = result.url;
              _hasPhotoUploadError = false;
            } else {
              _hasPhotoUploadError = true;
            }
          } else if (isTuteur) {
            _isUploadingPhotoTuteur = false;
            _photoTuteurFile = file;
            if (result.success && result.url != null) {
              _photoTuteurUrl = result.url;
              _hasPhotoTuteurUploadError = false;
            } else {
              _hasPhotoTuteurUploadError = true;
            }
          } else {
            _isUploadingPhotoParent = false;
            _photoParentFile = file;
            if (result.success && result.url != null) {
              _photoParentUrl = result.url;
              _hasPhotoParentUploadError = false;
            } else {
              _hasPhotoParentUploadError = true;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur upload photo: $e');
      if (mounted) {
        setState(() {
          if (isAcademicien) {
            _isUploadingPhoto = false;
            _photoFile = file;
            _hasPhotoUploadError = true;
          } else if (isTuteur) {
            _isUploadingPhotoTuteur = false;
            _photoTuteurFile = file;
            _hasPhotoTuteurUploadError = true;
          } else {
            _isUploadingPhotoParent = false;
            _photoParentFile = file;
            _hasPhotoParentUploadError = true;
          }
        });
      }
    }
  }

  /// Retry l'upload de la photo academicien
  Future<void> _retryPhotoUpload() async {
    if (_photoFile == null) return;
    await _uploadPhoto(_photoFile!);
  }

  /// Retry l'upload de la photo parent
  Future<void> _retryPhotoParentUpload() async {
    if (_photoParentFile == null) return;
    await _uploadPhoto(_photoParentFile!, target: _PhotoTarget.parent);
  }

  /// Retry l'upload de la photo tuteur
  Future<void> _retryPhotoTuteurUpload() async {
    if (_photoTuteurFile == null) return;
    await _uploadPhoto(_photoTuteurFile!, target: _PhotoTarget.tuteur);
  }

  Future<void> _pickCertificatMedical() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;
      if (picked.path == null) return;
      final file = File(picked.path!);
      await _uploadCertificatMedical(file, displayName: picked.name);
    } catch (e) {
      debugPrint('Erreur selection certificat: $e');
      if (mounted) {
        AcademyToast.show(
          context,
          title: l10n.error,
          description: l10n.medicalCertificatePickError,
          isError: true,
        );
      }
    }
  }

  Future<void> _uploadCertificatMedical(
    File file, {
    required String displayName,
  }) async {
    setState(() {
      _isUploadingCertificat = true;
      _hasCertificatUploadError = false;
      _certificatMedicalFile = file;
      _certificatMedicalFileName = displayName;
    });

    try {
      final uploadResult = await DependencyInjection.uploadService.uploadImage(
        file,
        UploadType.certificatMedical,
      );
      if (!mounted) return;
      setState(() {
        _isUploadingCertificat = false;
        if (uploadResult.success && uploadResult.url != null) {
          _certificatMedicalUrl = uploadResult.url;
          _hasCertificatUploadError = false;
        } else {
          _hasCertificatUploadError = true;
        }
      });
    } catch (e) {
      debugPrint('Erreur upload certificat: $e');
      if (!mounted) return;
      setState(() {
        _isUploadingCertificat = false;
        _hasCertificatUploadError = true;
      });
    }
  }

  Future<void> _retryCertificatUpload() async {
    final file = _certificatMedicalFile;
    final name = _certificatMedicalFileName;
    if (file == null || name == null) return;
    await _uploadCertificatMedical(file, displayName: name);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2012),
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textMainLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < _totalSteps - 1) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          l10n.academicianRegistrationTitle,
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barre de progression custom
          _buildProgressBar(colorScheme),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1(theme, colorScheme),
                _buildStep2(theme, colorScheme),
                _buildStep3(theme, colorScheme),
                _buildStep4(theme, colorScheme),
                _buildStep5(theme, colorScheme),
                _buildStep6(theme, colorScheme),
                _buildStep7(theme, colorScheme),
                _buildStep8(theme, colorScheme),
              ],
            ),
          ),

          // Navigation dock
          if (_currentStep < _totalSteps - 1)
            _buildNavigationDock(colorScheme, isDark),
        ],
      ),
    );
  }

  Widget _buildBooleanSelector({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildChoiceChip(
              label: l10n.yesLabel,
              isSelected: value == true,
              onSelected: (selected) => onChanged(selected ? true : null),
              colorScheme: colorScheme,
            ),
            _buildChoiceChip(
              label: l10n.noLabel,
              isSelected: value == false,
              onSelected: (selected) => onChanged(selected ? false : null),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 6,
            width:
                (MediaQuery.of(context).size.width *
                            ((_currentStep + 1) / _totalSteps) -
                        48)
                    .clamp(0.0, double.infinity),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDock(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            _buildSecondaryButton(l10n.previousLabel, _prevStep, colorScheme),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPrimaryButton(
              _currentStep == _totalSteps - 2
                  ? l10n.confirm_label
                  : l10n.continue_label,
              _nextStep,
              colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    String text,
    VoidCallback onPressed,
    ColorScheme colorScheme,
  ) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    VoidCallback onPressed,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(bool isDark) {
    final baseColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(57),
                      child: _isUploadingPhoto
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.uploadingLabel,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _hasPhotoUploadError && _photoFile != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 32,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: _retryPhotoUpload,
                                  child: Text(
                                    l10n.retry,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _photoFile != null
                          ? Image.file(_photoFile!, fit: BoxFit.cover)
                          : Icon(
                              Icons.person_outline_rounded,
                              size: 50,
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.academicianPhotoLabel,
            style: GoogleFonts.montserrat(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            l10n.optionalLabel,
            style: GoogleFonts.montserrat(
              color: isDark
                  ? AppColors.textMutedDark.withValues(alpha: 0.6)
                  : AppColors.textMutedLight.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Identité ---
  Widget _buildStep1(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              l10n.identityLabel,
              l10n.academicianPersonalDetails,
            ),
            const SizedBox(height: 32),

            _buildPhotoPicker(theme.brightness == Brightness.dark),
            const SizedBox(height: 32),

            _buildTextField(
              controller: _nomController,
              label: l10n.lastName,
              hint: l10n.enterLastName,
              icon: Icons.badge_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _prenomController,
              label: l10n.firstName,
              hint: l10n.enterFirstName,
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _dateNaissanceController,
                  label: l10n.birthDateLabel,
                  hint: l10n.birthDateFormat,
                  icon: Icons.calendar_today_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? l10n.requiredField : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _lieuNaissanceController,
              label: l10n.birthPlaceLabel,
              hint: l10n.birthPlaceHint,
              icon: Icons.place_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nationaliteController,
              label: l10n.nationalityLabel,
              hint: l10n.nationalityHint,
              icon: Icons.flag_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.genderLabel,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChoiceChip(
                  label: l10n.male,
                  icon: Icons.male_outlined,
                  isSelected: _selectedSexe == l10n.male,
                  onSelected: (s) =>
                      setState(() => _selectedSexe = s ? l10n.male : null),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 12),
                _buildChoiceChip(
                  label: l10n.female,
                  icon: Icons.female_outlined,
                  isSelected: _selectedSexe == l10n.female,
                  onSelected: (s) =>
                      setState(() => _selectedSexe = s ? l10n.female : null),
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 2: Contact ---
  Widget _buildStep2(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.contactLabel, l10n.contactSubtitle),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _telephoneEleveController,
              label: l10n.studentPhoneLabel,
              hint: l10n.phoneHint,
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _tailleController,
              label: l10n.heightLabel,
              hint: l10n.heightHint,
              icon: Icons.height_outlined,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: l10n.emailLabel,
              hint: l10n.emailHint,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _whatsappController,
              label: 'WhatsApp',
              hint: l10n.phoneHint,
              icon: Icons.chat_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _twitterController,
              label: 'Twitter',
              hint: '@username',
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _facebookController,
              label: 'Facebook',
              hint: l10n.facebookHint,
              icon: Icons.facebook_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoParentPicker(bool isDark) =>
      _buildPersonPhotoPicker(isDark, target: _PhotoTarget.parent);

  Widget _buildPhotoTuteurPicker(bool isDark) =>
      _buildPersonPhotoPicker(isDark, target: _PhotoTarget.tuteur);

  Widget _buildPersonPhotoPicker(
    bool isDark, {
    required _PhotoTarget target,
  }) {
    final baseColor = isDark ? Colors.white : Colors.black;
    final isParent = target == _PhotoTarget.parent;
    final file = isParent ? _photoParentFile : _photoTuteurFile;
    final isUploading = isParent
        ? _isUploadingPhotoParent
        : _isUploadingPhotoTuteur;
    final hasError = isParent
        ? _hasPhotoParentUploadError
        : _hasPhotoTuteurUploadError;
    final retry = isParent ? _retryPhotoParentUpload : _retryPhotoTuteurUpload;
    final onPick = isParent ? _pickParentImage : _pickTuteurImage;
    final label = isParent ? l10n.parentPhotoLabel : l10n.tuteurPhotoLabel;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(57),
                      child: isUploading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.uploadingLabel,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : hasError && file != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 32,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: retry,
                                  child: Text(
                                    l10n.retry,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : file != null
                          ? Image.file(file, fit: BoxFit.cover)
                          : Icon(
                              Icons.person_outline_rounded,
                              size: 50,
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onPick,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            l10n.optionalLabel,
            style: GoogleFonts.montserrat(
              color: isDark
                  ? AppColors.textMutedDark.withValues(alpha: 0.6)
                  : AppColors.textMutedLight.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Parent/Tuteur ---
  Widget _buildStep3(ThemeData theme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.parentInfoLabel, l10n.parentInfoSubtitle),
            const SizedBox(height: 32),

            // --- Section Parent ---
            _buildSubSectionHeader(l10n.parentSectionTitle, colorScheme),
            const SizedBox(height: 20),
            _buildPhotoParentPicker(isDark),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nomParentController,
              label: l10n.parentLastNameLabel,
              hint: l10n.parentLastNameHint,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _prenomParentController,
              label: l10n.parentFirstNameLabel,
              hint: l10n.parentFirstNameHint,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _fonctionParentController,
              label: l10n.parentFunctionLabel,
              hint: l10n.parentFunctionHint,
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _telephoneParentController,
              label: l10n.parentPhoneLabel,
              hint: l10n.phoneHint,
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // --- Section Tuteur ---
            _buildSubSectionHeader(l10n.tuteurSectionTitle, colorScheme),
            const SizedBox(height: 20),
            _buildPhotoTuteurPicker(isDark),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nomTuteurController,
              label: l10n.tuteurLastNameLabel,
              hint: l10n.tuteurLastNameHint,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _prenomTuteurController,
              label: l10n.tuteurFirstNameLabel,
              hint: l10n.tuteurFirstNameHint,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _fonctionTuteurController,
              label: l10n.tuteurFunctionLabel,
              hint: l10n.tuteurFunctionHint,
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _telephoneTuteurController,
              label: l10n.tuteurPhoneLabel,
              hint: l10n.phoneHint,
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // --- Section Garant ---
            _buildSubSectionHeader(
              l10n.guarantorSectionTitle,
              colorScheme,
              subtitle: l10n.guarantorSectionSubtitle,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.guarantorTypeLabel,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChoiceChip(
                  label: l10n.guarantorParentOption,
                  icon: Icons.family_restroom_outlined,
                  isSelected: _garantType == 'parent',
                  onSelected: (s) =>
                      setState(() => _garantType = s ? 'parent' : null),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 12),
                _buildChoiceChip(
                  label: l10n.guarantorTuteurOption,
                  icon: Icons.shield_outlined,
                  isSelected: _garantType == 'tuteur',
                  onSelected: (s) =>
                      setState(() => _garantType = s ? 'tuteur' : null),
                  colorScheme: colorScheme,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailGarantController,
              label: l10n.guarantorEmailLabel,
              hint: l10n.emailHint,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _adresseGarantController,
              label: l10n.guarantorAddressLabel,
              hint: l10n.guarantorAddressHint,
              icon: Icons.home_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSectionHeader(
    String title,
    ColorScheme colorScheme, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- Step 4: Football ---
  Widget _buildStep4(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.footballLabel, l10n.sportsProfileSubtitle),
          const SizedBox(height: 32),
          Text(
            l10n.preferredPositionLabel,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _postes
                .map(
                  (p) => _buildChoiceChip(
                    label: p.nom,
                    icon: Icons.sports_soccer_rounded,
                    isSelected: _selectedPosteId == p.id,
                    onSelected: (selected) {
                      setState(() => _selectedPosteId = selected ? p.id : null);
                    },
                    colorScheme: colorScheme,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.strongFootLabel,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChoiceChip(
                label: l10n.rightFooted,
                isSelected: _selectedPiedFort == l10n.rightFooted,
                onSelected: (s) => setState(
                  () => _selectedPiedFort = s ? l10n.rightFooted : null,
                ),
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: l10n.leftFooted,
                isSelected: _selectedPiedFort == l10n.leftFooted,
                onSelected: (s) => setState(
                  () => _selectedPiedFort = s ? l10n.leftFooted : null,
                ),
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: l10n.ambidextrous,
                isSelected: _selectedPiedFort == l10n.ambidextrous,
                onSelected: (s) => setState(
                  () => _selectedPiedFort = s ? l10n.ambidextrous : null,
                ),
                colorScheme: colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _atoutsController,
            label: l10n.strengthsLabel,
            hint: l10n.strengthsHint,
            icon: Icons.star_outline,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _faiblessesController,
            label: l10n.weaknessesLabel,
            hint: l10n.weaknessesHint,
            icon: Icons.trending_down_outlined,
          ),
          const SizedBox(height: 20),
          _buildBooleanSelector(
            label: l10n.skinProblemQuestion,
            value: _aProblemesPeau,
            onChanged: (value) => setState(() => _aProblemesPeau = value),
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          _buildBooleanSelector(
            label: l10n.allergyQuestion,
            value: _aAllergie,
            onChanged: (value) => setState(() => _aAllergie = value),
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _allergieDetailsController,
            label: l10n.allergyDetailsLabel,
            hint: l10n.allergyDetailsHint,
            icon: Icons.medical_information_outlined,
          ),
          const SizedBox(height: 20),
          _buildBooleanSelector(
            label: l10n.teamworkQuestion,
            value: _aimeTravailGroupe,
            onChanged: (value) => setState(() => _aimeTravailGroupe = value),
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionPerformancesController,
            label: l10n.performanceDescriptionLabel,
            hint: l10n.performanceDescriptionHint,
            icon: Icons.notes_outlined,
          ),
        ],
      ),
    );
  }

  // --- Step 5: Historique sportif ---
  Widget _buildStep5(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.sportsHistoryLabel,
            l10n.sportsHistorySubtitle,
          ),
          const SizedBox(height: 32),
          ..._historiqueParcours.asMap().entries.map((entry) {
            final index = entry.key;
            final historique = entry.value;
            return _buildHistoriqueCard(
              index,
              historique,
              colorScheme,
              theme.brightness == Brightness.dark,
            );
          }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _historiqueParcours.add(HistoriqueParcoursSportif());
              });
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addHistoryEntry),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueCard(
    int index,
    HistoriqueParcoursSportif historique,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.historyEntry} ${index + 1}',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _historiqueParcours.removeAt(index);
                  });
                },
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInlineTextField(
            initialValue: historique.centre,
            label: l10n.centerLabel,
            hint: l10n.centerHint,
            icon: Icons.sports_soccer_outlined,
            onChanged: (v) {
              _updateHistoriqueEntry(index, centre: v);
            },
          ),
          const SizedBox(height: 12),
          _buildInlineTextField(
            initialValue: historique.annee,
            label: l10n.historyAnneeLabel,
            hint: l10n.historyAnneeHint,
            icon: Icons.calendar_month_outlined,
            onChanged: (v) {
              _updateHistoriqueEntry(index, annee: v);
            },
          ),
          const SizedBox(height: 12),
          _buildInlineTextField(
            initialValue: historique.categorie,
            label: l10n.categoryLabel,
            hint: l10n.categoryHint,
            icon: Icons.category_outlined,
            onChanged: (v) {
              _updateHistoriqueEntry(index, categorie: v);
            },
          ),
          const SizedBox(height: 12),
          _buildInlineTextField(
            initialValue: historique.autresRemarques,
            label: l10n.historyAutresRemarquesLabel,
            hint: l10n.historyAutresRemarquesHint,
            icon: Icons.notes_outlined,
            onChanged: (v) {
              _updateHistoriqueEntry(index, autresRemarques: v);
            },
          ),
        ],
      ),
    );
  }

  void _updateHistoriqueEntry(
    int index, {
    String? centre,
    String? annee,
    String? categorie,
    String? autresRemarques,
  }) {
    final current = _historiqueParcours[index];
    _historiqueParcours[index] = HistoriqueParcoursSportif(
      id: current.id,
      academicienId: current.academicienId,
      centre: centre ?? current.centre,
      annee: annee ?? current.annee,
      categorie: categorie ?? current.categorie,
      autresRemarques: autresRemarques ?? current.autresRemarques,
    );
  }

  Widget _buildInlineTextField({
    String? initialValue,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- Step 6: Scolaire ---
  Widget _buildStep6(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.schoolingLabel,
            l10n.currentAcademicLevelSubtitle,
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _niveaux.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = _niveaux[index];
              final isSelected = _selectedNiveauId == n.id;
              return InkWell(
                onTap: () => setState(() => _selectedNiveauId = n.id),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : colorScheme.onSurface.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: isSelected
                            ? AppColors.primary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        n.nom,
                        style: GoogleFonts.montserrat(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _etablissementScolaireController,
            label: l10n.schoolEstablishmentLabel,
            hint: l10n.schoolEstablishmentHint,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _anneeScolaireActuelleController,
            label: l10n.schoolCurrentYearLabel,
            hint: l10n.schoolCurrentYearHint,
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _remarquesScolairesController,
            label: l10n.schoolRemarksLabel,
            hint: l10n.schoolRemarksHint,
            icon: Icons.notes_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          _buildCertificatMedicalPicker(colorScheme),
        ],
      ),
    );
  }

  Widget _buildCertificatMedicalPicker(ColorScheme colorScheme) {
    final hasFile =
        _certificatMedicalFile != null || _certificatMedicalUrl != null;
    final fileName =
        _certificatMedicalFileName ?? _certificatMedicalUrl?.split('/').last;
    final isPdf = (fileName ?? '').toLowerCase().endsWith('.pdf');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicalCertificateLabel,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.medicalCertificateHint,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _isUploadingCertificat ? null : _pickCertificatMedical,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasFile
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasFile
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : colorScheme.onSurface.withValues(alpha: 0.1),
                width: hasFile ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPdf
                        ? Icons.picture_as_pdf_outlined
                        : hasFile
                        ? Icons.image_outlined
                        : Icons.upload_file_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile
                            ? l10n.medicalCertificateImported
                            : l10n.medicalCertificateImport,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (fileName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_isUploadingCertificat)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else if (_hasCertificatUploadError)
                  TextButton(
                    onPressed: _retryCertificatUpload,
                    child: Text(
                      l10n.retry,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (hasFile)
                  Text(
                    l10n.medicalCertificateReplace,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (_hasCertificatUploadError) ...[
          const SizedBox(height: 8),
          Text(
            l10n.medicalCertificateUploadError,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: Colors.red.shade400,
            ),
          ),
        ],
      ],
    );
  }

  // --- Step 7: Signatures ---
  Widget _buildStep7(ThemeData theme, ColorScheme colorScheme) {
    return SignatureStep(
      signatureAcademicienFile: _signatureAcademicienFile,
      signatureAcademicienUrl: _signatureAcademicienUrl,
      signatureParentFile: _signatureParentFile,
      signatureParentUrl: _signatureParentUrl,
      onAcademicienSignatureChanged: (file, url) {
        setState(() {
          _signatureAcademicienFile = file;
          _signatureAcademicienUrl = url;
        });
      },
      onParentSignatureChanged: (file, url) {
        setState(() {
          _signatureParentFile = file;
          _signatureParentUrl = url;
        });
      },
    );
  }

  // --- Step 8: Recap & QR ---

  String? _generatedQrCode;

  String _generateQrCode() {
    if (_generatedQrCode != null) return _generatedQrCode!;
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final code =
        'PA-ACA-${timestamp.toString().substring(5)}-${random.nextInt(9999).toString().padLeft(4, '0')}';
    _generatedQrCode = code;
    return code;
  }

  String _getPosteName() {
    if (_selectedPosteId == null) {
      return l10n.notSpecified;
    }
    return _postes
        .firstWhere(
          (p) => p.id == _selectedPosteId,
          orElse: () => PosteFootball(id: '', nom: l10n.notSpecified),
        )
        .nom;
  }

  String _getNiveauName() {
    if (_selectedNiveauId == null) {
      return l10n.notSpecified;
    }
    return _niveaux
        .firstWhere(
          (n) => n.id == _selectedNiveauId,
          orElse: () =>
              NiveauScolaire(id: '', nom: l10n.notSpecified, ordre: 0),
        )
        .nom;
  }

  Widget _buildStep8(ThemeData theme, ColorScheme colorScheme) {
    if (_createdAcademicien == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = theme.brightness == Brightness.dark;
    final aca = _createdAcademicien!;
    final qrCode = aca.codeQrUnique;
    final nomComplet = '${aca.prenom} ${aca.nom}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Animation de succes
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.registrationSuccessTitle,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.academicianQrBadgeSubtitle,
            style: GoogleFonts.montserrat(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Badge QR premium
          _buildQrBadgeCard(qrCode, nomComplet, colorScheme, isDark),
          const SizedBox(height: 24),

          // Recapitulatif detaille
          _buildRecapCard(nomComplet, colorScheme, isDark),
          const SizedBox(height: 32),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    l10n.shareLabel,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    l10n.finishLabel,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQrBadgeCard(
    String qrCode,
    String nomComplet,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tete badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PEPITES ACADEMY',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.academicianBadgeType,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 2,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // QR Code reel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: qrCode,
              version: QrVersions.auto,
              size: 180,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1C1C1C),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1C1C1C),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nom complet
          Text(
            nomComplet,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getPosteName(),
            style: GoogleFonts.montserrat(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Code QR texte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              qrCode,
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapCard(
    String nomComplet,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final dateInscription = DateTime.now();
    final dateStr =
        '${dateInscription.day.toString().padLeft(2, '0')}/${dateInscription.month.toString().padLeft(2, '0')}/${dateInscription.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recapTitle,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecapRow(
            Icons.person_outline,
            l10n.fullNameLabel,
            nomComplet,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.cake_outlined,
            l10n.birthDateLabel,
            _dateNaissanceController.text.isNotEmpty
                ? _dateNaissanceController.text
                : l10n.notProvided,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.phone_android_outlined,
            l10n.parentPhoneLabel,
            _telephoneParentController.text.isNotEmpty
                ? _telephoneParentController.text
                : l10n.notProvided,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.sports_soccer_rounded,
            l10n.posteLabel,
            _getPosteName(),
            colorScheme,
          ),
          _buildRecapRow(
            Icons.directions_run_rounded,
            l10n.strongFootLabel,
            _selectedPiedFort ?? l10n.notSpecified,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.school_outlined,
            l10n.schoolLevels,
            _getNiveauName(),
            colorScheme,
          ),
          _buildRecapRow(
            Icons.shield_outlined,
            l10n.roleLabel,
            l10n.profileAcademician,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.calendar_today_outlined,
            l10n.registrationDateLabel,
            dateStr,
            colorScheme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRecapRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            height: 1,
          ),
      ],
    );
  }

  // --- Widgets Utilitaires ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Function(bool) onSelected,
    required ColorScheme colorScheme,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : colorScheme.onSurface,
            ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: colorScheme.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : colorScheme.onSurface.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      labelStyle: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : colorScheme.onSurface,
      ),
      showCheckmark: false,
    );
  }
}

enum _PhotoTarget { parent, tuteur }

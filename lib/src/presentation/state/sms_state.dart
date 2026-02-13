import 'package:flutter/material.dart';
import '../../application/services/sms_service.dart';
import '../../domain/entities/academicien.dart';
import '../../domain/entities/encadreur.dart';
import '../../domain/entities/sms_message.dart';
import '../../infrastructure/repositories/academicien_repository_impl.dart';
import '../../infrastructure/repositories/encadreur_repository_impl.dart';

/// State management pour le module SMS.
/// Gere la composition, la selection des destinataires,
/// l'envoi et l'historique des messages.
class SmsState extends ChangeNotifier {
  final SmsService _smsService;
  final AcademicienRepositoryImpl _academicienRepository;
  final EncadreurRepositoryImpl _encadreurRepository;

  SmsState({
    required SmsService smsService,
    required AcademicienRepositoryImpl academicienRepository,
    required EncadreurRepositoryImpl encadreurRepository,
  }) : _smsService = smsService,
       _academicienRepository = academicienRepository,
       _encadreurRepository = encadreurRepository;

  // --- Donnees ---
  List<Academicien> _academiciens = [];
  List<Academicien> get academiciens => _academiciens;

  List<Encadreur> _encadreurs = [];
  List<Encadreur> get encadreurs => _encadreurs;

  final List<Destinataire> _destinatairesSelectionnes = [];
  List<Destinataire> get destinatairesSelectionnes =>
      _destinatairesSelectionnes;

  List<SmsMessage> _historique = [];
  List<SmsMessage> get historique => _historique;

  Map<String, int> _statistiques = {
    'totalEnvoyes': 0,
    'envoyesCeMois': 0,
    'enEchec': 0,
  };
  Map<String, int> get statistiques => _statistiques;

  String _contenuMessage = '';
  String get contenuMessage => _contenuMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // --- Chargement des contacts ---

  /// Charge les academiciens et encadreurs disponibles.
  Future<void> chargerContacts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _academiciens = await _academicienRepository.getAll();
      _encadreurs = await _encadreurRepository.getAll();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des contacts : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge l'historique des SMS et les statistiques.
  Future<void> chargerHistorique() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historique = await _smsService.getHistorique();
      _statistiques = await _smsService.getStatistiques();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement de l\'historique : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Selection des destinataires ---

  /// Ajoute un academicien comme destinataire.
  void ajouterAcademicien(Academicien academicien) {
    final existe = _destinatairesSelectionnes.any(
      (d) => d.id == academicien.id,
    );
    if (!existe) {
      _destinatairesSelectionnes.add(
        Destinataire(
          id: academicien.id,
          nom: '${academicien.prenom} ${academicien.nom}',
          telephone: academicien.telephoneParent,
          type: TypeDestinataire.academicien,
        ),
      );
      notifyListeners();
    }
  }

  /// Ajoute un encadreur comme destinataire.
  void ajouterEncadreur(Encadreur encadreur) {
    final existe = _destinatairesSelectionnes.any((d) => d.id == encadreur.id);
    if (!existe) {
      _destinatairesSelectionnes.add(
        Destinataire(
          id: encadreur.id,
          nom: '${encadreur.prenom} ${encadreur.nom}',
          telephone: encadreur.telephone,
          type: TypeDestinataire.encadreur,
        ),
      );
      notifyListeners();
    }
  }

  /// Retire un destinataire de la selection.
  void retirerDestinataire(String id) {
    _destinatairesSelectionnes.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  /// Verifie si un contact est selectionne.
  bool estSelectionne(String id) {
    return _destinatairesSelectionnes.any((d) => d.id == id);
  }

  /// Selectionne tous les academiciens.
  void selectionnerTousAcademiciens() {
    for (final a in _academiciens) {
      ajouterAcademicien(a);
    }
  }

  /// Selectionne tous les encadreurs.
  void selectionnerTousEncadreurs() {
    for (final e in _encadreurs) {
      ajouterEncadreur(e);
    }
  }

  /// Selectionne les academiciens par poste de football.
  void selectionnerParPoste(String posteId) {
    final filtres = _academiciens.where((a) => a.posteFootballId == posteId);
    for (final a in filtres) {
      ajouterAcademicien(a);
    }
  }

  /// Selectionne les academiciens par niveau scolaire.
  void selectionnerParNiveau(String niveauId) {
    final filtres = _academiciens.where((a) => a.niveauScolaireId == niveauId);
    for (final a in filtres) {
      ajouterAcademicien(a);
    }
  }

  /// Vide la selection des destinataires.
  void viderSelection() {
    _destinatairesSelectionnes.clear();
    notifyListeners();
  }

  // --- Composition du message ---

  /// Met a jour le contenu du message.
  void setContenuMessage(String contenu) {
    _contenuMessage = contenu;
    notifyListeners();
  }

  // --- Envoi ---

  /// Envoie le SMS aux destinataires selectionnes.
  Future<bool> envoyerSms() async {
    if (_contenuMessage.trim().isEmpty) {
      _errorMessage = 'Le message ne peut pas etre vide.';
      notifyListeners();
      return false;
    }
    if (_destinatairesSelectionnes.isEmpty) {
      _errorMessage = 'Veuillez selectionner au moins un destinataire.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _smsService.envoyerSms(
        contenu: _contenuMessage.trim(),
        destinataires: List.from(_destinatairesSelectionnes),
      );

      _successMessage =
          'SMS envoye a ${_destinatairesSelectionnes.length} destinataire(s).';

      // Reinitialiser apres envoi
      _contenuMessage = '';
      _destinatairesSelectionnes.clear();

      // Rafraichir les stats
      _statistiques = await _smsService.getStatistiques();
      _historique = await _smsService.getHistorique();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi : $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime un SMS de l'historique.
  Future<void> supprimerSms(String id) async {
    try {
      await _smsService.supprimerSms(id);
      _historique.removeWhere((m) => m.id == id);
      _statistiques = await _smsService.getStatistiques();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      notifyListeners();
    }
  }

  /// Efface les messages de succes/erreur.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Reinitialise completement l'etat de composition.
  void reinitialiser() {
    _contenuMessage = '';
    _destinatairesSelectionnes.clear();
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

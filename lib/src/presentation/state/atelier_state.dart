import 'package:flutter/material.dart';
import '../../application/services/atelier_service.dart';
import '../../core/events/atelier_events.dart';
export '../../core/events/atelier_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../domain/entities/atelier.dart';
import 'message_state_mixin.dart';
import '../../../l10n/app_localizations.dart';

/// State management pour les ateliers d'une seance.
/// Gere le chargement, l'ajout, la modification, la suppression
/// et la reorganisation des ateliers.
class AtelierState extends ChangeNotifier
    with MessageStateMixin, EventBusSubscriberMixin {
  final AtelierService _service;
  final DomainEventBus _eventBus;
  AppLocalizations? _l10n;
  bool _isDisposed = false;

  AtelierState(this._service, this._eventBus);

  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  List<Atelier> _ateliers = [];
  List<Atelier> get ateliers => _ateliers;

  String? _seanceId;
  String? get seanceId => _seanceId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  @override
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  @override
  String? get successMessage => _successMessage;

  /// Charge les ateliers d'une seance.
  Future<void> chargerAteliers(String seanceId) async {
    _seanceId = seanceId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ateliers = await _service.getAteliersParSeance(seanceId);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des ateliers : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force un re-fetch depuis le serveur en bypassant le cache.
  Future<void> rafraichirDepuisServeur(String seanceId) async {
    _seanceId = seanceId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ateliers = await _service.getAteliersParSeance(seanceId, forceRefresh: true);
    } catch (e) {
      _errorMessage = 'Erreur lors du rafraichissement : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute un atelier a la seance courante.
  Future<bool> ajouterAtelier({
    required String nom,
    required AtelierType type,
    String? typeCustom,
    String description = '',
    String? icone,
    List<ConfigurationElementEvaluation>? configurationEvaluation,
    String? seanceId,
  }) async {
    final targetSeanceId = seanceId ?? _seanceId;
    if (targetSeanceId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await _service.ajouterAtelier(
        seanceId: targetSeanceId,
        nom: nom,
        type: type,
        typeCustom: typeCustom,
        description: description,
        icone: icone,
        configurationEvaluation: configurationEvaluation,
      );
      _successMessage = 'Atelier "$nom" ajoute avec succes.';
      _eventBus.emit(AtelierCreeEvent(
        atelierId: created.id,
        seanceId: targetSeanceId,
      ));
      await chargerAteliers(targetSeanceId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Modifie un atelier existant.
  Future<bool> modifierAtelier(Atelier atelier) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.modifierAtelier(atelier);
      _successMessage = 'Atelier "${atelier.nom}" modifie avec succes.';
      if (_seanceId != null) {
        await chargerAteliers(_seanceId!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Ferme un atelier directement.
  Future<bool> fermerAtelier(String atelierId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.fermerAtelier(atelierId);
      _successMessage = 'Atelier clôturé avec succès.';
      if (_seanceId != null) {
        await chargerAteliers(_seanceId!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la clôture : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Applique un atelier en seance.
  Future<bool> appliquerAtelier(String atelierId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.appliquerAtelier(atelierId);
      _successMessage = _l10n?.serviceAtelierAppliedSuccess ?? 'Atelier appliqué avec succès en séance.';
      if (_seanceId != null) {
        await chargerAteliers(_seanceId!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'application : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Supprime un atelier.
  Future<bool> supprimerAtelier(String atelierId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.supprimerAtelier(atelierId);
      _successMessage = 'Atelier supprime avec succes.';
      if (_seanceId != null) {
        await chargerAteliers(_seanceId!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reordonne les ateliers par glisser-deposer.
  Future<void> reordonnerAteliers(int oldIndex, int newIndex) async {
    if (_seanceId == null) return;

    // Ajustement de l'index pour ReorderableListView/SliverReorderableList
    // newIndex pointe vers la position AVANT le retrait de l'element
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Eviter les operations inutiles
    if (oldIndex == newIndex) return;

    final atelier = _ateliers.removeAt(oldIndex);
    _ateliers.insert(newIndex, atelier);
    notifyListeners();

    try {
      final ids = _ateliers.map((a) => a.id).toList();
      await _service.reordonnerAteliers(_seanceId!, ids);
      await chargerAteliers(_seanceId!);
    } catch (e) {
      _errorMessage = 'Erreur lors de la reorganisation : $e';
      notifyListeners();
    }
  }

  /// Sauvegarde la configuration d'evaluation d'un atelier et emet
  /// ConfigurationAtelierModifieeEvent pour notifier les composants dependants.
  Future<bool> sauvegarderConfigurationEvaluation(Atelier atelier) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.modifierAtelier(atelier);
      _successMessage = 'Configuration d\'evaluation sauvegardee.';
      if (_seanceId != null) {
        await chargerAteliers(_seanceId!);
      }
      _eventBus.emit(ConfigurationAtelierModifieeEvent(
        atelierId: atelier.id,
        seanceId: atelier.seanceId,
      ));
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la sauvegarde de la configuration : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Efface les messages de succes/erreur.
  @override
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

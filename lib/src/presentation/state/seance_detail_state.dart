import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/events/app_events.dart';
import '../../core/events/atelier_events.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../core/events/presence_events.dart';
import '../../core/events/seance_events.dart';
import '../../domain/entities/academicien.dart';
import '../../domain/entities/atelier.dart';
import '../../domain/entities/encadreur.dart';
import '../../domain/entities/presence.dart';
import '../../domain/entities/seance.dart';
import '../../injection_container.dart';

/// State de la page de detail d'une seance.
/// Gere le chargement initial, le pull-to-refresh et la reaction aux evenements
/// de domaine. Suit la strategie de fraicheur : les repositories gerent le cache,
/// ce state lit toujours par les repositories et s'abonne au bus.
class SeanceDetailState extends ChangeNotifier with EventBusSubscriberMixin {
  SeanceDetailState(this._seance) {
    _subscribeToEvents();
  }

  bool _disposed = false;

  Seance _seance;
  Seance get seance => _seance;

  List<Atelier> _ateliers = [];
  List<Atelier> get ateliers => _ateliers;

  List<Academicien> _academiciens = [];
  List<Academicien> get academiciens => _academiciens;

  List<Encadreur> _encadreursPresents = [];
  List<Encadreur> get encadreursPresents => _encadreursPresents;

  List<Encadreur> _encadreursInvites = [];
  List<Encadreur> get encadreursInvites => _encadreursInvites;

  /// Alias historique ; garde la compatibilite avec les anciens appels.
  List<Encadreur> get encadreurs => _encadreursPresents;

  Encadreur? _responsable;
  Encadreur? get responsable => _responsable;

  String? _responsableNom;
  String? get responsableNom => _responsableNom;

  int? _nbPresents;
  int? get nbPresents => _nbPresents;

  List<Presence>? _presences;
  List<Presence>? get presences => _presences;

  bool _isLoadingAteliers = false;
  bool get isLoadingAteliers => _isLoadingAteliers;

  bool _isLoadingPersonnes = false;
  bool get isLoadingPersonnes => _isLoadingPersonnes;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  DateTime? _lastFetchedAt;

  /// Future du refresh en cours, utilisee pour faire patienter un
  /// pull-to-refresh explicite jusqu'a la fin de la requete en vol.
  Future<void>? _refreshEnCours;

  void _subscribeToEvents() {
    listenTo<PresenceCreatedEvent>(
      DependencyInjection.domainEventBus,
      (_) => _refreshIfRelevant(),
    );
    listenTo<PresenceRecordedEvent>(
      DependencyInjection.domainEventBus,
      (_) => _refreshIfRelevant(),
    );
    listenTo<SeanceUpdatedEvent>(
      DependencyInjection.domainEventBus,
      (e) {
        if (e.seanceId == _seance.id) _refreshIfRelevant();
      },
    );
    listenTo<SeanceClosedEvent>(
      DependencyInjection.domainEventBus,
      (e) {
        if (e.seanceId == _seance.id) _refreshIfRelevant();
      },
    );
    listenTo<AtelierCreeEvent>(
      DependencyInjection.domainEventBus,
      (e) {
        if (e.seanceId == _seance.id) _refreshIfRelevant();
      },
    );
    listenTo<AtelierUpdatedEvent>(
      DependencyInjection.domainEventBus,
      (e) {
        if (e.seanceId == _seance.id) _refreshIfRelevant();
      },
    );
    listenTo<AtelierDeletedEvent>(
      DependencyInjection.domainEventBus,
      (e) {
        if (e.seanceId == _seance.id) _refreshIfRelevant();
      },
    );
    listenTo<AtelierAppliedEvent>(
      DependencyInjection.domainEventBus,
      (e) {
        if (e.seanceId == _seance.id) _refreshIfRelevant();
      },
    );
    listenTo<AtelierClosedEvent>(
      DependencyInjection.domainEventBus,
      (e) {
        if (e.seanceId == _seance.id) _refreshIfRelevant();
      },
    );
    listenTo<AppResumedEvent>(
      DependencyInjection.domainEventBus,
      (_) => _onAppResumed(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  void _refreshIfRelevant() {
    _loadLocalFast();
  }

  Future<void> loadInitial() async {
    await _loadLocalFast();
    Future.microtask(() => refreshFromBackend());
  }

  Future<void> _onAppResumed() async {
    if (_isRefreshing) return;
    if (_lastFetchedAt == null) return;
    final age = DateTime.now().difference(_lastFetchedAt!);
    if (age > const Duration(minutes: 2)) {
      await refreshFromBackend();
    }
  }

  /// Charge les donnees locales via les repositories puis notifie les listeners.
  Future<void> _loadLocalFast() async {
    _presences = null;
   _safeNotifyListeners();

    await _rafraichirSeance();
    await Future.wait([
      _chargerAteliers(),
      _chargerPersonnes(),
      _chargerResponsableNom(),
    ]);
  }

  /// Rafraichit les donnees depuis le backend si connecte, puis recharge
  /// l'interface avec les donnees locales fraiches.
  /// [force] ignore l'anti-rebond de 3 secondes (pull-to-refresh explicite).
  /// Si un refresh est deja en cours (ex. chargement initial), le pull-to-refresh
  /// attend sa fin pour que l'indicateur reste visible pendant la requete.
  Future<void> refreshFromBackend({bool force = false}) async {
    final enCours = _refreshEnCours;
    if (enCours != null) {
      if (force) await enCours;
      return;
    }
    if (!force && _lastFetchedAt != null) {
      final age = DateTime.now().difference(_lastFetchedAt!);
      if (age < const Duration(seconds: 3)) return;
    }
    _isRefreshing = true;
   _safeNotifyListeners();

    final future = _executerRefresh();
    _refreshEnCours = future;
    try {
      await future;
    } finally {
      _refreshEnCours = null;
      _isRefreshing = false;
      _lastFetchedAt = DateTime.now();
     _safeNotifyListeners();
    }
  }

  Future<void> _executerRefresh() async {
    final online = await DependencyInjection.connectivityGuard.isOnline;
    if (!online) {
      await _loadLocalFast();
      return;
    }

    final seanceId = _seance.id;

    await DependencyInjection.seanceRepository.getById(
      seanceId,
      forceRefresh: true,
    );
    await DependencyInjection.atelierRepository.getBySeanceId(
      seanceId,
      forceRefresh: true,
    );
    await DependencyInjection.presenceRepository.syncBySeanceFromApi(seanceId);
    await DependencyInjection.academicienRepository.syncFromApi();
    await DependencyInjection.encadreurRepository.syncFromApi();

    await _loadLocalFast();
  }

  Future<void> _rafraichirSeance() async {
    var updated = await DependencyInjection.seanceRepository.getById(_seance.id);

    if (updated == null && RegExp(r'^\d{10,}$').hasMatch(_seance.id)) {
      updated = await DependencyInjection.seanceRepository.getSeanceOuverte();
    }

    if (updated != null) {
      _seance = updated;
     _safeNotifyListeners();
    }
  }

  Future<void> _chargerResponsableNom() async {
    final responsableId = _seance.encadreurResponsableId;
    if (responsableId.isEmpty) return;

    try {
      final currentUserId = await DependencyInjection.preferences.getUserId();
      if (responsableId == 'current_user' ||
          (currentUserId != null && currentUserId == responsableId)) {
        final fullName = await DependencyInjection.preferences.getUserFullName();
        _responsableNom = fullName;
       _safeNotifyListeners();
        return;
      }

      final enc = await DependencyInjection.encadreurRepository.getById(
        responsableId,
      );
      _responsableNom = enc?.nomComplet;
     _safeNotifyListeners();
    } catch (_) {
      // Ignore
    }
  }

  Future<void> _chargerAteliers() async {
    _isLoadingAteliers = true;
   _safeNotifyListeners();

    try {
      final ateliers = await DependencyInjection.atelierService
          .getAteliersParSeance(_seance.id);
      _ateliers = ateliers;
    } catch (_) {
      // Garder les ateliers precedents en cas d'erreur
    } finally {
      _isLoadingAteliers = false;
     _safeNotifyListeners();
    }
  }

  Future<void> _chargerPersonnes() async {
    _isLoadingPersonnes = true;
   _safeNotifyListeners();

    try {
      final presences =
          _presences ??
          await DependencyInjection.presenceRepository.getBySeance(_seance.id);

      final encadreurPresentsIds = presences
          .where((p) => p.typeProfil == ProfilType.encadreur)
          .map((p) => p.profilId)
          .toSet();

      // Le responsable est implicitement present des l'ouverture.
      final responsableId = _seance.encadreurResponsableId;
      if (responsableId.isNotEmpty && responsableId != 'current_user') {
        encadreurPresentsIds.add(responsableId);
      }

      final encadreurInvitesIds = _seance.encadreurIds
          .where((id) => !encadreurPresentsIds.contains(id))
          .toList();

      final academicienIds = presences.isNotEmpty
          ? presences
                .where((p) => p.typeProfil == ProfilType.academicien)
                .map((p) => p.profilId)
                .toSet()
                .toList()
          : _seance.academicienIds;

      final tousAcademiciens = await DependencyInjection.academicienRepository
          .getAll();
      final tousEncadreurs = await DependencyInjection.encadreurRepository
          .getAll();

      final academiciensById = <String, Academicien>{
        for (final a in tousAcademiciens) a.id: a,
      };
      final encadreursById = <String, Encadreur>{
        for (final e in tousEncadreurs) e.id: e,
      };

      final loadedAcademiciens = <Academicien>[];
      for (final id in academicienIds) {
        final fromAll = academiciensById[id];
        if (fromAll != null) {
          loadedAcademiciens.add(fromAll);
          continue;
        }
        final fromRepo = await DependencyInjection.academicienRepository
            .getById(id);
        if (fromRepo != null) loadedAcademiciens.add(fromRepo);
      }

      final loadedEncadreursPresents = <Encadreur>[];
      for (final id in encadreurPresentsIds) {
        final fromAll = encadreursById[id];
        if (fromAll != null) {
          loadedEncadreursPresents.add(fromAll);
          continue;
        }
        final fromRepo = await DependencyInjection.encadreurRepository.getById(
          id,
        );
        if (fromRepo != null) loadedEncadreursPresents.add(fromRepo);
      }

      final loadedEncadreursInvites = <Encadreur>[];
      for (final id in encadreurInvitesIds) {
        final fromAll = encadreursById[id];
        if (fromAll != null) {
          loadedEncadreursInvites.add(fromAll);
          continue;
        }
        final fromRepo = await DependencyInjection.encadreurRepository.getById(
          id,
        );
        if (fromRepo != null) loadedEncadreursInvites.add(fromRepo);
      }

      Encadreur? responsable;
      if (_seance.encadreurResponsableId.isNotEmpty &&
          _seance.encadreurResponsableId != 'current_user') {
        responsable =
            encadreursById[_seance.encadreurResponsableId] ??
            await DependencyInjection.encadreurRepository.getById(
              _seance.encadreurResponsableId,
            );
      }

      _academiciens = loadedAcademiciens;
      _encadreursPresents = loadedEncadreursPresents;
      _encadreursInvites = loadedEncadreursInvites;
      _responsable = responsable;
      _nbPresents = presences.length;
      _presences = presences;
    } catch (_) {
      // Ignore
    } finally {
      _isLoadingPersonnes = false;
     _safeNotifyListeners();
    }
  }
}

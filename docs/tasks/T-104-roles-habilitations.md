# T-104 : Système de Rôles et Habilitations

Ce ticket définit et implémente le système de rôles qui permet de contrôler les autorisations et les fonctionnalités accessibles à chaque profil utilisateur.

## Référence

Voir `docs/roles-matrix.md` pour la matrice complète des permissions.

---

## Sous-tickets

### [T-104.1] Modèle de données - Rôles et Permissions [DONE]

- **Objectif :** Créer les entités métier pour les rôles et permissions.
- **Actions :**
  - Créer l'entité `Role` avec les 7 rôles définis
  - Créer l'entité `Permission` avec les permissions granulaires
  - Étendre l'entité `User` pour inclure un rôle
  - Définir les contrats de repository pour l'accès aux données

---

### [T-104.2] Service d'autorisation [DONE]

- **Objectif :** Mettre en place la logique de vérification des permissions.
- **Actions :**
  - Créer un service centralisé de vérification des autorisations
  - Permettre la vérification d'une ou plusieurs permissions
  - Gérer la hiérarchie des rôles
  - Implémenter l'attribution de rôles avec contrôle des droits
- **Important :**
  - Les permissions doivent être vérifiées côté backend pour des raisons de sécurité.
  - La validation finale reste côté serveur.

---

### [T-104.3] Intégration avec l'authentification [DONE]

- **Objectif :** Intégrer le système de rôles au système d'authentification existant (T-201).
- **Actions :**
  - Charger le rôle de l'utilisateur lors de la connexion
  - Stocker le rôle dans la session persistante
  - Rediriger vers le dashboard approprié selon le rôle
- **Important :**
  - Le cache local des rôles est essentiel pour le mode hors-ligne (T-603).

---

### [T-104.4] Interface de gestion des rôles [DONE]

- **Objectif :** Permettre aux administrateurs de gérer les rôles utilisateurs.
- **Pré-requis :** Permission `user:assign_role` (SupAdmin, Admin)
- **Actions :**
  - Page de liste des utilisateurs avec leur rôle
  - Formulaire de modification de rôle
  - Filtres par rôle
  - Confirmation avant changement de rôle
- **Important :**
  - L'UI masque les éléments non autorisés, mais la validation finale reste côté serveur.

---

### [T-104.5] Composants UI conditionnels [DONE]

- **Objectif :** Afficher/masquer les éléments UI selon les permissions.
- **Actions :**
  - Widget `PermissionGuard` pour affichage conditionnel
  - Badge visuel pour afficher le rôle de l'utilisateur
  - Sélecteur de rôle pour les formulaires
  - Page d'erreur pour accès non autorisé
- **Fichiers créés :**
  - `lib/src/presentation/widgets/permission_guard.dart` - Widget d'affichage conditionnel
  - `lib/src/presentation/widgets/role_badge.dart` - Badge visuel pour les rôles
  - `lib/src/presentation/widgets/role_selector.dart` - Sélecteur de rôle pour formulaires
  - `lib/src/presentation/pages/error/unauthorized_page.dart` - Page d'erreur accès non autorisé
- **Important :**
  - L'UI masque les éléments non autorisés, mais la validation finale reste côté serveur.
  - Les permissions doivent être vérifiées côté backend pour des raisons de sécurité.

---

### [T-104.6] Dashboards par Rôle

#### T-104.6.1 - Dashboard Administratif (SupAdmin & Admin)

- **Rôles concernés :** SupAdmin, Admin
- **Objectif :** Dashboard administratif complet avec toutes les fonctionnalités.
- **Fonctionnalités accessibles :**
  - Vue globale de l'académie
  - Gestion des saisons (ouverture/fermeture)
  - Gestion des utilisateurs et rôles
  - Gestion des académiciens
  - Gestion des encadreurs
  - Gestion des séances
  - Entraînements, ateliers, exercices
  - Évaluations et bulletins
  - Suivi médical
  - Gestion du matériel
  - Discipline et incidents
  - Communication (SMS)
  - Référentiels
  - Statistiques globales

##### T-104.6.1.1 - Modèle de données Dashboard Stats [DONE]

- **Objectif :** Créer l'entité domaine pour les statistiques globales du dashboard SupAdmin.
- **Actions :**
  - Créer l'entité `DashboardStats` dans `lib/src/domain/entities/`
  - Créer l'entité `GlobalStats` (statistiques de base)
  - Créer l'entité `Season` avec enum `SeasonStatus`
  - Inclure les champs : nombre total académiciens, encadreurs, séances, annotations, présences
  - Inclure les métriques saison en cours (ouverte/fermée)
  - Définir le contrat de repository `DashboardRepository`
- **Fichiers créés :**
  - `lib/src/domain/entities/dashboard_stats.dart` - Entité principale
  - `lib/src/domain/entities/global_stats.dart` - Statistiques globales
  - `lib/src/domain/repositories/dashboard_repository.dart` - Contrat repository
- **Connexion Backend :**
  - Endpoint : `GET /dashboard/stats` Implémenté dans `backend/src/presentation/routes/dashboard_routes.py`
  - Endpoint : `GET /seasons/current` Implémenté dans `backend/src/presentation/routes/seasons_routes.py`
  - Endpoint : `POST /seasons` Implémenté
  - Endpoint : `PUT /seasons/:id/close` Implémenté
- **Cache :**
  - Persistance locale via `SharedPreferences` pour mode hors-ligne
  - Durée de validité : 5 minutes
- **Tests :**
  - Tests unitaires `DashboardStats` Créé dans `test/domain/entities/dashboard_stats_test.dart`
  - Tests unitaires `GlobalStats` Créé dans `test/domain/entities/global_stats_test.dart`
  - Tests unitaires `Season` Inclus dans `dashboard_stats_test.dart`
- **Action restante :**
  - Exécuter `flutter pub get` pour installer mocktail
  - Exécuter `flutter test` pour valider les tests

##### T-104.6.1.2 - Repository Dashboard avec Cache [DONE]

- **Objectif :** Implémenter le repository avec gestion du cache et synchronisation.
- **Actions réalisées :**
  - Créer `DashboardRepositoryImpl` dans `lib/src/infrastructure/repositories/`
  - Implémenter la stratégie cache-first : vérifier le cache local avant appel API
  - Gérer l'invalidation du cache lors des mutations (nouvelle séance, présence, etc.)
  - Intégrer avec `SyncService` pour les opérations hors-ligne via `setSyncService()`
  - Ajouter `SyncEntityType.dashboard` et `SyncEntityType.season` dans l'enum
- **Connexion Backend :**
  - Appel `DioClient.get(ApiEndpoints.dashboardStats)`
  - Gestion des erreurs réseau avec fallback sur cache
- **Backend :**
  - Endpoint `GET /dashboard/stats` fonctionnel dans `backend/src/presentation/routes/dashboard_routes.py`
  - Le backend calcule et retourne les statistiques agrégées (academiciens, encadreurs, séances, présences, annotations, saison en cours)
- **Synchronisation :**
  - `SyncEntityType.dashboard` et `SyncEntityType.season` ajoutés dans `lib/src/domain/entities/sync_operation.dart`
  - Synchronisation automatique au retour de connexion via `ConnectivityService`
- **Tests :**
  - Tests unitaires du repository Créé dans `test/infrastructure/repositories/dashboard_repository_impl_test.dart`

##### T-104.6.1.3 - Service Dashboard SupAdmin [DONE]

- **Objectif :** Créer le service applicatif pour la logique métier du dashboard.
- **État :** Complet (mobile + backend + tests)
- **Implémentation mobile :**
  - Service utilise `DashboardRepository` au lieu de `DioClient` direct
  - Retourne `DashboardStats` au lieu de `GlobalStats`
- **Actions réalisées :**
  - Refactoré `DashboardService` pour utiliser `DashboardRepository`
  - Méthode `getStats()` retournant `DashboardStats`
  - Méthode `getCurrentSeason()` pour la saison en cours
  - Méthode `refreshStats()` pour forcer le rafraîchissement
  - Méthode `openSeason()` et `closeSeason()` déléguant au repository
  - Getters utilitaires : `nbAcademiciens`, `nbEncadreurs`, `nbSeancesJour`, `nbPresencesJour`, `hasActiveSeason`
- **Injection des dépendances :**
  - `lib/src/injection_container.dart` : `DashboardRepository` initialisé avant `DashboardService`
- **UI :**
  - `lib/src/presentation/pages/dashboard/screens/admin_home_screen.dart` : migré vers `DashboardStats`
- **Backend :**
  - `GET /seasons/current` fonctionnel dans `backend/src/presentation/routes/seasons_routes.py`
- **Cache :**
  - `Stream<DashboardStats>` exposé via `statsStream`
- **Tests :**
  - Tests unitaires dans `test/application/services/dashboard_service_test.dart`
- **Dépendance :**
  - `mocktail: ^1.0.4` ajouté dans `pubspec.yaml`

##### T-104.6.1.4 - Vue Globale de l'Académie [DONE]

- **Objectif :** Afficher les KPIs globaux sur le dashboard SupAdmin.
- **Actions :**
  - Créer le widget `GlobalStatsCard` dans `lib/src/presentation/widgets/`
  - Afficher : total académiciens, encadreurs, séances du jour
  - Indicateur visuel de connectivité (via `ConnectivityIndicator`)
  - Bouton de rafraîchissement avec animation de chargement
- **Connexion Backend :**
  - Charger les données via `DashboardService.getGlobalStats()`
  - Afficher les données en cache immédiatement, puis rafraîchir
- **Backend à implémenter :**
  - Aucun endpoint direct, dépend de `GET /dashboard/stats`
  - S'assurer que les données retournées incluent `nbSeancesJour` et `nbPresencesJour`
- **Cache :**
  - Afficher les données en cache pendant le chargement
  - Indiquer si les données proviennent du cache (badge "Hors-ligne")

##### T-104.6.1.5 - Gestion des Saisons (Ouverture/Fermeture) [DONE]

- **Objectif :** Permettre au SupAdmin d'ouvrir/fermer une saison.
- **Actions :**
  - L'entité `Season` est déjà créée dans `dashboard_stats.dart`
  - Utiliser `DashboardRepository` existant pour les opérations saison
  - Widget `SeasonManagementCard` avec boutons ouvrir/fermer
  - Modal de confirmation avant action
- **Connexion Backend :**
  - Endpoint `GET/POST /seasons` déjà ajouté dans `ApiEndpoints`
  - Validation des permissions côté backend (`season:manage`)
- **Backend à implémenter :**
  - `GET /seasons/current` : Retourner la saison active courante
  - `POST /seasons` : Créer/ouvrir une nouvelle saison (body: `{name, start_date, status}`)
  - `PUT /seasons/:id/close` : Fermer une saison (body: `{end_date}`)
  - Ajouter la permission `season:manage` pour SupAdmin uniquement
  - Vérifier qu'une seule saison peut être active à la fois
- **Synchronisation :**
  - Ajouter `SyncEntityType.season` dans l'enum existant
  - File d'attente pour opérations hors-ligne
  - Notification de confirmation après synchronisation

##### T-104.6.1.6 - Gestion des Utilisateurs et Rôles [DONE]

- **Objectif :** Interface de gestion des utilisateurs avec attribution de rôles.
- **Actions :**
  - Intégrer la page existante `UsersRolesPage` dans le dashboard
  - Ajouter filtres par rôle avec badges visuels
  - Formulaire de modification de rôle avec validation
  - Historique des changements de rôle
- **Connexion Backend :**
  - Endpoints existants : `GET/PUT ${ApiEndpoints.roleUsers}/:id/role`
  - Pagination avec chargement progressif
- **Backend à implémenter :**
  - `GET /roles/users/history/:userId` : Historique des changements de rôle (à créer si non existant)
  - Vérifier que la pagination fonctionne correctement sur `GET /roles/users`
- **Cache :**
  - Utiliser le cache existant dans `RoleRepositoryImpl.getCachedUsersSync()`
  - Invalider le cache après modification (`invalidateUsersCache()`)

##### T-104.6.1.7 - Accès à Tous les Modules [DONE]

- **Objectif :** Navigation rapide vers tous les modules de l'application.
- **Actions :**
  - Créer `SupAdminModuleGrid` avec icônes pour chaque module
  - Modules : Académiciens, Encadreurs, Séances, Ateliers, Bulletins, SMS, Référentiels
  - Badge indiquant le nombre d'éléments en attente de synchronisation
  - Indicateur d'accès autorisé via `PermissionGuard`
- **Connexion Backend :**
  - Pas d'appel direct, navigation vers les pages existantes
- **Backend à implémenter :**
  - Aucun endpoint requis, utilise les données de synchronisation locales
- **Synchronisation :**
  - Afficher le compteur d'opérations en attente via `SyncService.getPendingCount()`

##### T-104.6.1.8 - Statistiques Globales avec Graphiques [DONE]

- **Objectif :** Afficher des graphiques de statistiques globales.
- **Actions :**
  - Créer `StatsChartWidget` avec graphiques (fl_chart ou équivalent)
  - Graphiques : évolution des présences, répartition par poste, performance mensuelle
  - Export des statistiques en PDF/Image
- **Connexion Backend :**
  - Endpoint : `GET /dashboard/stats/charts` (à ajouter dans `ApiEndpoints`)
  - Paramètres : période (mois, trimestre, saison)
- **Backend à implémenter :**
  - `GET /dashboard/stats/charts?period=month|quarter|season` : Retourner les données graphiques
  - Structure de réponse attendue :
    ```json
    {
      "presence_evolution": [{"date": "2024-01", "count": 45}, ...],
      "repartition_postes": [{"poste": "Gardien", "count": 5}, ...],
      "performance_mensuelle": [{"mois": "Janvier", "moyenne": 78.5}, ...]
    }
    ```
  - Ajouter l'endpoint dans `ApiEndpoints.dashboardStatsCharts`
- **Cache :**
  - Cache des données graphiques avec TTL de 10 minutes
  - Régénération au rafraîchissement

##### T-104.6.1.9 - Indicateur de Synchronisation [DONE]

- **Objectif :** Afficher le statut de synchronisation en temps réel.
- **Actions :**
  - Intégrer `SyncNotificationBanner` existant dans le dashboard
  - Badge avec nombre d'opérations en attente
  - Animation pendant la synchronisation
  - Notification de succès/échec après synchronisation
- **Backend à implémenter :**
  - Aucun endpoint requis, utilise le système de synchronisation existant
- **Synchronisation :**
  - Écouter `SyncService.onPendingCountChanged`
  - Écouter `SyncService.onSyncCompleted` pour les notifications
  - Déclencher `SyncService.syncPendingOperations()` au démarrage

##### T-104.6.1.10 - Page Dashboard SupAdmin Finale

- **Objectif :** Assembler tous les composants dans la page finale.
- **Actions :**
  - Créer `SupAdminDashboardPage` dans `lib/src/presentation/pages/dashboard/`
  - Layout responsive avec `ScrollView` et sections organisées
  - Intégrer tous les widgets créés (stats, saisons, utilisateurs, modules, graphiques)
  - Gestion du refresh avec `RefreshIndicator`
- **Connexion Backend :**
  - Chargement initial des données au montage
  - Rafraîchissement périodique configurable
- **Backend à implémenter :**
  - Récapitulatif des endpoints backend à créer/vérifier :
    - `GET /dashboard/stats` - Vérifier existence et format
    - `GET /seasons/current` - À créer
    - `POST /seasons` - À créer
    - `PUT /seasons/:id/close` - À créer
    - `GET /dashboard/stats/charts` - À créer
    - `GET /roles/users/history/:userId` - À créer (optionnel)
- **Cache :**
  - Affichage immédiat du cache pendant le chargement
  - État de chargement géré par `AsyncValue`

###### Dépendances T-104.6.1

| Sous-ticket | Dépendances |
|------------|-------------|
| T-104.6.1.1 | Aucune |
| T-104.6.1.2 | T-104.6.1.1 |
| T-104.6.1.3 | T-104.6.1.2 |
| T-104.6.1.4 | T-104.6.1.3 |
| T-104.6.1.5 | T-104.6.1.3 |
| T-104.6.1.6 | T-104.6.1.3 (existant partiel) |
| T-104.6.1.7 | T-104.6.1.3 |
| T-104.6.1.8 | T-104.6.1.3 |
| T-104.6.1.9 | Aucune (existant) |
| T-104.6.1.10 | Tous les précédents |


#### T-104.6.2 - Dashboard Encadrement (EncadreurChef & Encadreur)

- **Rôles concernés :** EncadreurChef, Encadreur
- **Objectif :** Dashboard encadrement pour la gestion des séances et le suivi des académiciens.
- **Fonctionnalités accessibles :**
  - Séances du jour
  - Scanner QR
  - Ouverture/fermeture des séances
  - Entraînements, ateliers, exercices (application)
  - Annotations et observations
  - Évaluations (EncadreurChef : validation)
  - Bulletins de formation
  - Suivi des académiciens à charge
  - Présences
  - Rapports de progression

#### T-104.6.3 - Dashboard MedecinChef

- **Objectif :** Dashboard médical.
- **Fonctionnalités accessibles :**
  - Fiches médicales des académiciens
  - Fiches médicales des encadreurs
  - Suivi des blessures
  - Conseils aux encadreurs
  - Alertes sanitaires


#### T-104.6.4 - Dashboard SurveillantGeneral

- **Objectif :** Dashboard logistique et discipline.
- **Fonctionnalités accessibles :**
  - Gestion du matériel
  - Affectation du matériel aux séances
  - Incidents disciplinaires
  - Suivi comportemental
  - Présences

#### T-104.6.5 - Dashboard Visiteur

- **Objectif :** Dashboard consultation en lecture seule.
- **Restrictions importantes :**
  - **Accès utilisateurs interdit** : Le Visiteur ne peut ni voir ni accéder à la liste des utilisateurs ni aux profils utilisateurs.
- **Fonctionnalités accessibles :**
  - Consultation des académiciens
  - Consultation des encadreurs
  - Consultation des entraînements
  - Consultation des résultats
  - Statistiques publiques

---

### [T-104.7] Tests

- **Objectif :** Valider le fonctionnement du système de rôles.
- **Actions :**
  - Tests des entités Role et Permission
  - Tests du service d'autorisation
  - Tests des composants UI conditionnels
  - Tests de navigation avec contrôle d'accès
- **Important :**
  - Les permissions doivent être vérifiées côté backend pour des raisons de sécurité.
  - Tests unitaires et d'intégration côté backend obligatoires.

---

### [T-104.8] Documentation API

- **Objectif :** Documenter les endpoints liés aux rôles pour le backend.
- **Endpoints à prévoir :**
  - Liste et détail des rôles
  - Liste des permissions par rôle
  - Attribution de rôle à un utilisateur

---

## Dépendances

### Tickets pré-requis

- **T-103** : Fondations Flutter & Architecture Hexagonale
- **T-201** : Système d'Authentification

### Tickets impactés

Tous les tickets utilisant des fonctionnalités nécessitant des permissions devront intégrer les vérifications appropriées.

---

## Estimation

| Sous-ticket | Estimation |
|-------------|------------|
| T-104.1 - Modèle de données | 2 jours |
| T-104.2 - Service d'autorisation | 2 jours |
| T-104.3 - Intégration authentification | 1 jour |
| T-104.4 - Interface gestion rôles | 2 jours |
| T-104.5 - Composants UI | 2 jours |
| T-104.6 - Dashboards (5) | 4 jours |
| T-104.7 - Tests | 2 jours |
| T-104.8 - Documentation | 1 jour |
| **Total** | **17 jours** |

---

## Notes

- Les permissions doivent être vérifiées côté backend pour des raisons de sécurité.
- L'UI masque les éléments non autorisés, mais la validation finale reste côté serveur.
- Le cache local des rôles est essentiel pour le mode hors-ligne (T-603).
- **Cycle de vie Ateliers/Exercices** : Créer → Modifier → Valider → Appliquer → Fermer. Un atelier se ferme automatiquement quand tous ses exercices sont fermés.
- **Restriction Visiteur** : Le Visiteur n'a aucun accès aux données utilisateurs (liste ou profil).

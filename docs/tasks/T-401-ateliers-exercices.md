# T-401 : Configuration des Ateliers et Exercices

Ce ticket permet à l'EncadreurChef de créer et structurer les ateliers et exercices qui composent une séance d'entraînement.

---

## Référence

Voir `docs/tasks.md` pour la liste principale des tâches.

---

## Sous-tickets

### [T-401.1] Modèle de données - Atelier et Exercice [DONE]

- **Objectif :** Créer les entités métier pour les ateliers et exercices.
- **Actions :**
  - Créer l'entité `Atelier` avec les attributs : nom, description, icône, ordre, statut, séance parente
  - Créer l'entité `Exercice` avec les attributs : nom, description, ordre, statut, atelier parent
  - Définir l'enum `AtelierStatut` : cree, modifie, valide, applique, ferme
  - Définir l'enum `ExerciceStatut` : cree, modifie, valide, applique, ferme
  - Définir les contrats de repository `AtelierRepository` et `ExerciceRepository`
- **Fichiers à créer (Mobile) :**
  - `lib/src/domain/entities/atelier.dart`
  - `lib/src/domain/entities/exercice.dart`
  - `lib/src/domain/entities/enums/atelier_statut.dart`
  - `lib/src/domain/entities/enums/exercice_statut.dart`
  - `lib/src/domain/repositories/atelier_repository.dart`
  - `lib/src/domain/repositories/exercice_repository.dart`

---

### [T-401.2] Endpoints Backend - Ateliers et Exercices

- **Objectif :** Définir et implémenter les endpoints backend pour la gestion des ateliers et exercices.
- **Permissions requises :**
  - `atelier:create` - EncadreurChef, Admin, SupAdmin
  - `atelier:update` - EncadreurChef, Admin, SupAdmin
  - `atelier:validate` - EncadreurChef uniquement
  - `atelier:apply` - Encadreur, EncadreurChef
  - `atelier:close` - Encadreur, EncadreurChef
  - `atelier:read` - Tous les rôles sauf Visiteur
  - `exercice:create` - EncadreurChef, Admin, SupAdmin
  - `exercice:update` - EncadreurChef, Admin, SupAdmin
  - `exercice:validate` - EncadreurChef uniquement
  - `exercice:apply` - Encadreur, EncadreurChef
  - `exercice:close` - Encadreur, EncadreurChef
  - `exercice:read` - Tous les rôles sauf Visiteur

#### Endpoints Ateliers [DONE]

| Méthode | Endpoint | Description | Permission |
|---------|----------|-------------|------------|
| POST | `/seances/:seanceId/ateliers` | Créer un atelier | `atelier:create` |
| PUT | `/ateliers/:id` | Modifier un atelier | `atelier:update` |
| PUT | `/ateliers/:id/validate` | Valider un atelier | `atelier:validate` |
| PUT | `/ateliers/:id/apply` | Appliquer un atelier en séance | `atelier:apply` |
| PUT | `/ateliers/:id/close` | Fermer un atelier | `atelier:close` |
| GET | `/seances/:seanceId/ateliers` | Liste des ateliers d'une séance | `atelier:read` |
| GET | `/ateliers/:id` | Détail d'un atelier | `atelier:read` |
| PUT | `/ateliers/reorder` | Réordonner les ateliers | `atelier:update` |

#### Endpoints Exercices

| Méthode | Endpoint | Description | Permission |
|---------|----------|-------------|------------|
| POST | `/ateliers/:atelierId/exercices` | Créer un exercice | `exercice:create` |
| PUT | `/exercices/:id` | Modifier un exercice | `exercice:update` |
| PUT | `/exercices/:id/validate` | Valider un exercice | `exercice:validate` |
| PUT | `/exercices/:id/apply` | Appliquer un exercice en séance | `exercice:apply` |
| PUT | `/exercices/:id/close` | Fermer un exercice | `exercice:close` |
| GET | `/ateliers/:atelierId/exercices` | Liste des exercices d'un atelier | `exercice:read` |
| GET | `/exercices/:id` | Détail d'un exercice | `exercice:read` |
| PUT | `/exercices/reorder` | Réordonner les exercices | `exercice:update` |

#### Structures de réponse JSON

**Atelier :**
```json
{
  "id": 1,
  "nom": "Drible",
  "description": "Techniques de dribble et conduite de balle",
  "icone": "sports_soccer",
  "ordre": 1,
  "statut": "cree",
  "seance_id": 42,
  "exercices": [
    { "id": 1, "nom": "Passement de jambes", "statut": "cree" },
    { "id": 2, "nom": "Crochet intérieur", "statut": "cree" }
  ],
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

**Exercice :**
```json
{
  "id": 1,
  "nom": "Passement de jambes",
  "description": "Exercice de feinte avec passement de jambes",
  "ordre": 1,
  "statut": "cree",
  "atelier_id": 1,
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

#### Règles métier Backend

- **Fermeture automatique d'atelier :** Un atelier passe en statut "ferme" automatiquement lorsque tous ses exercices sont fermés.
- **Validation préalable :** Un atelier/exercice doit être validé avant d'être appliqué.
- **Ordre unique :** L'ordre d'un atelier/exercice doit être unique dans son contexte parent.
- **Contrôle de séance :** Un atelier ne peut être créé que sur une séance ouverte ou à venir.

---

### [T-401.3] Repository Atelier/Exercice avec Cache [DONE]

- **Objectif :** Implémenter les repositories avec gestion du cache et synchronisation.
- **Actions :**
  - Créer `AtelierRepositoryImpl` dans `lib/src/infrastructure/repositories/`
  - Créer `ExerciceRepositoryImpl` dans `lib/src/infrastructure/repositories/`
  - Implémenter la stratégie cache-first : vérifier le cache local avant appel API
  - Gérer l'invalidation du cache lors des mutations
  - Intégrer avec `SyncService` pour les opérations hors-ligne
- **Fichiers à créer (Mobile) :**
  - `lib/src/infrastructure/repositories/atelier_repository_impl.dart`
  - `lib/src/infrastructure/repositories/exercice_repository_impl.dart`
- **Connexion Backend :**
  - Appels `DioClient.get/post/put` sur les endpoints définis
  - Gestion des erreurs réseau avec fallback sur cache
- **Cache :**
  - Persistance locale via SQLite (drift)
  - Invalidation du cache après mutation
- **Synchronisation :**
  - Ajouter `SyncEntityType.atelier` et `SyncEntityType.exercice`
  - File d'attente pour opérations hors-ligne
  - Synchronisation automatique au retour de connexion

---

### [T-401.4] Service Atelier/Exercice [DONE]

- **Objectif :** Créer les services applicatifs pour la logique métier.
- **Actions :**
  - Créer `AtelierService` dans `lib/src/application/services/`
  - Créer `ExerciceService` dans `lib/src/application/services/`
  - Méthodes CRUD complètes avec support cache/refresh
  - Méthode `reorderAteliers(String seanceId, List<String> ids)` pour réorganisation
  - Méthode `reorderExercices(String atelierId, List<String> ids)` pour réorganisation
  - Méthode `checkAutoClose(String atelierId)` pour vérifier la fermeture automatique
- **Fichiers à créer (Mobile) :**
  - `lib/src/application/services/atelier_service.dart`
  - `lib/src/application/services/exercice_service.dart`
- **Cache :**
  - Exposer des `Stream` pour réactivité UI
  - Notifier les changements via callbacks

---

### [T-401.5] Écran de composition des ateliers [DONE]

- **Objectif :** Interface de gestion hiérarchique ateliers > exercices.
- **Pré-requis :** Permission `atelier:read`
- **Actions :**
  - Créer `AteliersPage` avec liste des ateliers d'une séance
  - Afficher les ateliers sous forme de cards expansibles
  - Chaque card révèle la liste des exercices associés
  - Indicateurs visuels de statut (icônes colorées)
  - Bouton d'ajout d'atelier (visible si permission `atelier:create`)
- **Fichiers à créer (Mobile) :**
  - `lib/src/presentation/pages/ateliers/ateliers_page.dart`
  - `lib/src/presentation/widgets/atelier_card.dart`
  - `lib/src/presentation/widgets/exercice_list_tile.dart`
  - `lib/src/presentation/widgets/statut_indicator.dart`

---

### [T-401.6] Création/Modification d'un atelier

- **Objectif :** Formulaire de création et modification d'atelier.
- **Pré-requis :** Permission `atelier:create` ou `atelier:update`
- **Actions :**
  - Créer `AtelierFormPage` avec formulaire complet
  - Champs : nom (obligatoire), description, icône (sélecteur)
  - Validation côté client avant soumission
  - Mode création vs modification (même page, données pré-remplies)
  - Bouton de validation (change le statut en "valide")
- **Fichiers à créer (Mobile) :**
  - `lib/src/presentation/pages/ateliers/atelier_form_page.dart`
  - `lib/src/presentation/widgets/icon_selector.dart`

---

### [T-401.7] Création/Modification d'un exercice

- **Objectif :** Formulaire de création et modification d'exercice.
- **Pré-requis :** Permission `exercice:create` ou `exercice:update`
- **Actions :**
  - Créer `ExerciceFormPage` avec formulaire complet
  - Champs : nom (obligatoire), description
  - Validation côté client avant soumission
  - Mode création vs modification
  - Bouton de validation (change le statut en "valide")
- **Fichiers à créer (Mobile) :**
  - `lib/src/presentation/pages/exercices/exercice_form_page.dart`

---

### [T-401.8] Application d'un atelier/exercice en séance

- **Objectif :** Permettre à l'Encadreur d'appliquer un atelier validé en séance.
- **Pré-requis :** Permission `atelier:apply` ou `exercice:apply`
- **Rôles concernés :** Encadreur, EncadreurChef
- **Actions :**
  - Bouton "Appliquer" sur les ateliers/exercices validés
  - Confirmation avant application
  - Mise à jour du statut en "applique"
  - Notification de succès
- **Règles métier :**
  - Seuls les ateliers/exercices avec statut "valide" peuvent être appliqués
  - L'application se fait uniquement sur une séance en cours

---

### [T-401.9] Fermeture d'un exercice avec mise à jour automatique

- **Objectif :** Fermer un exercice et mettre à jour automatiquement le statut de l'atelier parent.
- **Pré-requis :** Permission `exercice:close`
- **Rôles concernés :** Encadreur, EncadreurChef
- **Actions :**
  - Bouton "Fermer" sur les exercices appliqués
  - Confirmation avant fermeture
  - Mise à jour du statut de l'exercice en "ferme"
  - Vérification automatique : si tous les exercices de l'atelier sont fermés, fermer l'atelier
  - Notification de fermeture (exercice + atelier si applicable)
- **Backend :**
  - Endpoint `PUT /exercices/:id/close` doit déclencher la vérification côté serveur
  - Retourner un flag `atelier_closed: true` si l'atelier a été fermé automatiquement

---

### [T-401.10] Réorganisation par glisser-déposer

- **Objectif :** Permettre de réorganiser l'ordre des ateliers et exercices.
- **Pré-requis :** Permission `atelier:update` ou `exercice:update`
- **Actions :**
  - Implémenter le drag-and-drop avec `ReorderableListView`
  - Poignée de glissement sur chaque item
  - Mise à jour de l'ordre côté backend après chaque déplacement
  - Animation fluide pendant le réordonnancement
- **Fichiers à modifier (Mobile) :**
  - `lib/src/presentation/pages/ateliers/ateliers_page.dart`
- **Backend :**
  - Endpoint `PUT /ateliers/reorder` avec body `{ "order": [3, 1, 2] }` (IDs dans le nouvel ordre)
  - Endpoint `PUT /exercices/reorder` avec body `{ "order": [5, 4, 6] }`

---

### [T-401.11] Affichage récapitulatif avec indicateurs de progression

- **Objectif :** Vue récapitulative avec progression globale.
- **Pré-requis :** Permission `atelier:read`
- **Actions :**
  - Widget `AteliersProgressCard` affichant :
    - Nombre total d'ateliers
    - Nombre d'ateliers par statut (créés, validés, appliqués, fermés)
    - Barre de progression globale
  - Intégration dans le dashboard de séance
- **Fichiers à créer (Mobile) :**
  - `lib/src/presentation/widgets/ateliers_progress_card.dart`

---

### [T-401.12] Tests

- **Objectif :** Valider le fonctionnement du module ateliers/exercices.
- **Actions :**
  - Tests unitaires des entités Atelier et Exercice
  - Tests des repositories avec mock API
  - Tests des services (CRUD, réorganisation, fermeture automatique)
  - Tests des widgets UI (cards, formulaires, drag-and-drop)
  - Tests d'intégration avec le backend
- **Fichiers à créer (Mobile) :**
  - `test/domain/entities/atelier_test.dart`
  - `test/domain/entities/exercice_test.dart`
  - `test/infrastructure/repositories/atelier_repository_test.dart`
  - `test/infrastructure/repositories/exercice_repository_test.dart`
  - `test/application/services/atelier_service_test.dart`
  - `test/presentation/widgets/atelier_card_test.dart`
- **Backend :**
  - Tests unitaires des endpoints
  - Tests de la fermeture automatique d'atelier
  - Tests des permissions par rôle

---

### [T-401.13] Documentation API

- **Objectif :** Documenter les endpoints pour Swagger/OpenAPI.
- **Actions :**
  - Documenter tous les endpoints ateliers et exercices
  - Inclure les schémas de requête/réponse
  - Documenter les codes d'erreur possibles
  - Documenter les permissions requises par endpoint
- **Codes d'erreur :**
  - `400` - Données invalides
  - `401` - Non authentifié
  - `403` - Permission insuffisante
  - `404` - Atelier/Exercice non trouvé
  - `409` - Conflit (ex: action impossible dans le statut actuel)
  - `422` - Règle métier violée (ex: validation d'un atelier non créé)

---

## Dépendances

### Tickets pré-requis

- **T-102** : Modèle de Données (Entités Métier) - Entité Seance
- **T-104** : Système de Rôles et Habilitations - Permissions
- **T-302** : Flux de Séance (Ouverture/Fermeture) - Séance parente

### Tickets impactés

- **T-402** : Module d'Annotations et Observations - Les annotations sont rattachées aux ateliers
- **T-501** : Bulletin de Formation Périodique - Utilise les données des ateliers

---

## Estimation

| Sous-ticket | Estimation |
|-------------|------------|
| T-401.1 - Modèle de données | 1 jour |
| T-401.2 - Endpoints Backend | 3 jours |
| T-401.3 - Repository avec Cache | 2 jours |
| T-401.4 - Service | 1 jour |
| T-401.5 - Écran composition | 2 jours |
| T-401.6 - Formulaire atelier | 1 jour |
| T-401.7 - Formulaire exercice | 1 jour |
| T-401.8 - Application en séance | 1 jour |
| T-401.9 - Fermeture automatique | 1 jour |
| T-401.10 - Drag-and-drop | 1 jour |
| T-401.11 - Récapitulatif | 0.5 jour |
| T-401.12 - Tests | 2 jours |
| T-401.13 - Documentation | 0.5 jour |
| **Total** | **17 jours** |

---

## Notes

- La fermeture automatique d'un atelier est une règle métier critique à implémenter côté backend.
- Le drag-and-drop doit être fluide et responsive, même avec beaucoup d'éléments.
- Les icônes des ateliers doivent être choisies parmi un ensemble prédéfini (Material Icons).
- Le mode hors-ligne doit permettre la création/modification d'ateliers/exercices avec synchronisation ultérieure.

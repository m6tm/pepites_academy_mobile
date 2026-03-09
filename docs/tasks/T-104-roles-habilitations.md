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

### [T-104.3] Intégration avec l'authentification

- **Objectif :** Intégrer le système de rôles au système d'authentification existant (T-201).
- **Actions :**
  - Charger le rôle de l'utilisateur lors de la connexion
  - Stocker le rôle dans la session persistante
  - Rediriger vers le dashboard approprié selon le rôle
- **Important :**
  - Le cache local des rôles est essentiel pour le mode hors-ligne (T-603).

---

### [T-104.4] Interface de gestion des rôles

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

### [T-104.5] Composants UI conditionnels

- **Objectif :** Afficher/masquer les éléments UI selon les permissions.
- **Actions :**
  - Widget `PermissionGuard` pour affichage conditionnel
  - Badge visuel pour afficher le rôle de l'utilisateur
  - Sélecteur de rôle pour les formulaires
  - Page d'erreur pour accès non autorisé
- **Important :**
  - L'UI masque les éléments non autorisés, mais la validation finale reste côté serveur.
  - Les permissions doivent être vérifiées côté backend pour des raisons de sécurité.

---

### [T-104.6] Dashboards par Rôle

#### T-104.6.1 - Dashboard SupAdmin

- **Objectif :** Dashboard complet avec toutes les fonctionnalités.
- **Fonctionnalités accessibles :**
  - Vue globale de l'académie
  - Gestion des saisons (ouverture/fermeture)
  - Gestion des utilisateurs et rôles
  - Tous les modules de l'application
  - Statistiques globales

#### T-104.6.2 - Dashboard Admin

- **Objectif :** Dashboard administratif avec gestion complète.
- **Fonctionnalités accessibles :**
  - Gestion des académiciens
  - Gestion des encadreurs
  - Gestion des séances
  - Rapports et statistiques
  - Communication (SMS)

#### T-104.6.3 - Dashboard EncadreurChef

- **Objectif :** Dashboard structuration et validation.
- **Fonctionnalités accessibles :**
  - Création d'entraînements, ateliers, exercices
  - Ouverture/fermeture des séances
  - Validation des évaluations
  - Suivi des encadreurs
  - Rapports de progression

#### T-104.6.4 - Dashboard MedecinChef

- **Objectif :** Dashboard médical.
- **Fonctionnalités accessibles :**
  - Fiches médicales des académiciens
  - Fiches médicales des encadreurs
  - Suivi des blessures
  - Conseils aux encadreurs
  - Alertes sanitaires

#### T-104.6.5 - Dashboard Encadreur

- **Objectif :** Dashboard terrain.
- **Fonctionnalités accessibles :**
  - Séances du jour
  - Scanner QR
  - Annotations et observations
  - Suivi des académiciens à charge
  - Présences

#### T-104.6.6 - Dashboard SurveillantGeneral

- **Objectif :** Dashboard logistique et discipline.
- **Fonctionnalités accessibles :**
  - Gestion du matériel
  - Affectation du matériel aux séances
  - Incidents disciplinaires
  - Suivi comportemental
  - Présences

#### T-104.6.7 - Dashboard Visiteur

- **Objectif :** Dashboard consultation en lecture seule.
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
| T-104.6 - Dashboards (7) | 5 jours |
| T-104.7 - Tests | 2 jours |
| T-104.8 - Documentation | 1 jour |
| **Total** | **17 jours** |

---

## Notes

- Les permissions doivent être vérifiées côté backend pour des raisons de sécurité.
- L'UI masque les éléments non autorisés, mais la validation finale reste côté serveur.
- Le cache local des rôles est essentiel pour le mode hors-ligne (T-603).

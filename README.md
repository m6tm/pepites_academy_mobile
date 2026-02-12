# Pepites Academy Mobile

## Présentation du Projet

Pepites Academy Mobile est l'application officielle de gestion de l'académie de football Pépites Academy. Cet outil est conçu pour digitaliser le suivi pédagogique et opérationnel sur le terrain, permettant aux encadreurs et administrateurs de gérer les effectifs, les séances d'entraînement et les évaluations de manière fluide et professionnelle.

L'application met l'accent sur une expérience utilisateur premium, utilisant des principes de design moderne tels que le Glassmorphism, tout en garantissant une robustesse technique via une architecture logicielle rigoureuse.

## Fonctionnalités Principales

### Gestion des Utilisateurs et Authentification

- Système d'authentification sécurisé avec rôles (Administrateur et Encadreur).
- Gestion des sessions et persistance locale des accès.
- Flux de récupération de mot de passe intégré.

### Suivi des Académiciens

- Enregistrement détaillé des élèves (informations personnelles, sportives et scolaires).
- Attribution automatique d'un badge numérique unique via QR Code.
- Consultation de la fiche de profil complète incluant l'historique des présences et des évaluations.

### Gestion du Terrain (Séances et Ateliers)

- Ouverture et clôture de séances d'entraînement avec contrôle d'intégrité.
- Composition dynamique de séances par l'ajout d'ateliers thématiques (dribble, technique, physique, etc.).
- Réorganisation intuitive de l'ordre des exercices.

### Scanner de Présence et Évaluations

- Validation des accès au stade via scanner QR intégré.
- Module d'annotations en temps réel permettant aux coaches de noter les performances individuelles durant les ateliers.
- Système de tags rapides pour une saisie fluide sur le terrain.

### Communication et Rapports

- Génération de bulletins de formation périodiques avec graphiques de progression (diagrammes radar).
- Module d'envoi de SMS groupés filtrés par poste, niveau scolaire ou statut.

## Architecture Technique

Le projet suit les principes de l'Architecture Hexagonale (Clean Architecture) afin de garantir une séparation stricte des préoccupations et de faciliter la testabilité ainsi que l'évolution du système.

### Structure des Couches (lib/src/)

1.  **Domain (Noyau métier)**
    - Entities : Modèles de données purs (Academician, Séance, etc.).
    - Repositories : Interfaces définissant les contrats de stockage et de récupération des données.
    - Value Objects : Logique métier spécifique aux types de données.

2.  **Application (Cas d'utilisation)**
    - Orchestration de la logique métier et transition entre le domaine et l'infrastructure.

3.  **Infrastructure (Adaptateurs de sortie)**
    - Implementations : Réalisation concrète des repositories (intégration API, base de données locale).
    - Data Sources : Clients HTTP, services de stockage sécurisé, intégration de Supabase ou autres services externes.
    - Mappers : Transformation des données brutes en entités du domaine.

4.  **Presentation (Interface Utilisateur)**
    - UI/Widgets : Composants graphiques réutilisables.
    - Pages : Écrans complets de l'application.
    - State Management : Gestion des états de l'interface (Provider / Bloc).

## Stack Technique

- **Framework** : Flutter SDK (Canal Stable)
- **Langage** : Dart
- **Design System** : Custom Premium UI (Glassmorphism)
- **Typographie** : Google Fonts (Inter, Roboto)
- **Persistence** : Shared Preferences, SQLite (via Drift/Hive pour le mode hors-ligne)
- **Scanner** : Mobile Scanner
- **Gestion d'état** : Provider / Bloc

## Installation et Configuration

### Prérequis

- Flutter SDK (dernière version stable recommandée)
- Dart SDK
- Android Studio ou VS Code avec extensions Flutter/Dart

### Procédure d'installation

1. Cloner le dépôt :

```bash
git clone [URL_DU_DEPOT]
cd pepites_academy_mobile
```

2. Installer les dépendances :

```bash
flutter pub get
```

3. Lancer l'application :

```bash
flutter run
```

## Structure du Code

```text
lib/
├── main.dart
└── src/
    ├── application/        # Logique des cas d'utilisation
    ├── domain/             # Entités et contrats (noyau)
    │   ├── entities/
    │   └── repositories/
    ├── infrastructure/      # Implémentations techniques
    │   ├── datasources/
    │   └── models/
    └── presentation/       # UI, Pages et State Management
        ├── components/
        ├── pages/
        └── theme/
```

## Documentation

La documentation complémentaire est disponible dans le dossier `docs/` :

- `tasks.md` : Backlog de développement et spécifications des tickets.
- `releases/` : Journal des modifications et notes de version.

---

© 2026 i-Tech - Pepites Academy. Tous droits réservés.

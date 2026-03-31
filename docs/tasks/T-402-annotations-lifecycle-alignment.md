# T-402 : Alignement des Annotations sur le Cycle de Vie des Ateliers et Exercices

Ce ticket vise à synchroniser le module d'annotations avec la structure hiérarchique (Séance > Atelier > Exercice) et le cycle de vie opérationnel (Cree > Valide > Applique > Ferme).

## Problématique
Actuellement, les annotations sont rattachées à l'Atelier de manière globale. Pour un suivi précis, elles doivent pouvoir être rattachées à un Exercice spécifique et ne doivent être autorisées que lorsque l'élément est dans l'état "Appliqué".

---

## Sous-tickets

### [T-402.1] Backend : Évolution du modèle et validation des statuts

- **Objectif :** Permettre le rattachement aux exercices et garantir l'intégrité métier.
- **Actions :**
  - Modifier le modèle `Annotation` pour ajouter un champ `exercice_id` (nullable pour compatibilité descendante).
  - Mettre à jour le schéma de création d'annotation pour accepter `exercice_id`.
  - Implémenter une règle métier dans le service d'annotation :
    - Vérifier que l'Atelier (ou l'Exercice si fourni) est au statut `applique`.
    - Interdire l'annotation si le statut est `cree`, `valide` ou `ferme`.
  - Mettre à jour la migration SQL pour la base de données.
- **Fichiers impactés :**
  - `backend/src/domain/entities/models.py`
  - `backend/src/presentation/routes/annotation_routes.py`
  - `backend/src/presentation/schemas/schemas.py`

---

### [T-402.2] Mobile : Mise à jour du Domaine et des DataSources

- **Objectif :** Refléter les changements du backend dans l'application mobile.
- **Actions :**
  - Mettre à jour l'entité `Annotation` dans `lib/src/domain/entities/annotation.dart` pour inclure `exerciceId`.
  - Mettre à jour la base de données locale (Drift/SQLite) pour inclure la colonne `exercice_id`.
  - Modifier le `AnnotationRepository` et le `AnnotationService` pour gérer ce nouveau champ.
  - Mettre à jour le mécanisme de synchronisation (`SyncService`).
- **Fichiers impactés :**
  - `mobile/lib/src/domain/entities/annotation.dart`
  - `mobile/lib/src/infrastructure/datasources/annotation_local_datasource.dart`
  - `mobile/lib/src/application/services/annotation_service.dart`

---

### [T-402.3] Mobile : UI - Annotation par Exercice

- **Objectif :** Permettre à l'encadreur d'annoter depuis un exercice spécifique.
- **Actions :**
  - Dans `AtelierCard`, ajouter une option d'annotation au niveau de chaque `ExerciceListTile`.
  - Mettre à jour `AnnotationSidePanel` pour :
    - Afficher le nom de l'exercice en cours si applicable.
    - Filtrer l'historique pour montrer les annotations du même exercice en priorité.
    - Désactiver le bouton d'enregistrement si l'élément (Atelier/Exercice) n'est pas au statut `applique`.
- **Fichiers impactés :**
  - `mobile/lib/src/presentation/widgets/atelier_card.dart`
  - `mobile/lib/src/presentation/widgets/exercice_list_tile.dart`
  - `mobile/lib/src/presentation/pages/annotation/widgets/annotation_side_panel.dart`

---

### [T-402.4] Mobile : Logique de contrôle des statuts dans l'UI

- **Objectif :** Guider l'utilisateur en masquant/désactivant l'annotation selon le cycle de vie.
- **Actions :**
  - Empêcher l'ouverture du panneau d'annotation si l'atelier/exercice n'est pas `applique`.
  - Afficher un message informatif (ex: "Veuillez appliquer l'atelier pour commencer les annotations").
  - Gérer visuellement le passage au statut `ferme` (lecture seule des annotations précédentes).
- **Fichiers impactés :**
  - `mobile/lib/src/presentation/pages/seance/seance_detail_page.dart`
  - `mobile/lib/src/presentation/state/annotation_state.dart`

---

## Dépendances

- **T-401** : Configuration des Ateliers et Exercices (Terminé)
- **T-104** : Système de Rôles et Habilitations (Terminé)

---

## Estimation

| Sous-ticket | Estimation |
|-------------|------------|
| T-402.1 - Backend | 1 jour |
| T-402.2 - Mobile Domaine/Data | 1 jour |
| T-402.3 - Mobile UI (Exercice) | 1.5 jour |
| T-402.4 - Mobile Logique Statuts | 0.5 jour |
| **Total** | **4 jours** |

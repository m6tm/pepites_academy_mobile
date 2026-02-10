# Cahier des Charges Fonctionnel et Technique - Pépites Academy

## 1. Introduction et Objectifs

Le projet consiste en la création d'une application mobile "supra attractive" destinée à la gestion d'une académie de football. L'objectif principal est de moderniser et de faciliter le suivi des entraînements, des académiciens et des encadreurs via une interface intuitive, fluide et premium.

L'application communiquera avec un backend dédié (projet séparé) via une API REST. Ce document détaille les spécifications fonctionnelles, techniques et les directions artistiques de l'application mobile.

## 2. Directions Artistiques et Expérience Utilisateur (UX/UI)

L'application doit dégager une impression de professionnalisme et d'innovation.

- **Esthétique Premium (Glassmorphism & Blur) :** Utilisation intensive d'effets de transparence floutée (_Backdrop Blur_) pour les surfaces de premier plan. Les cartes, volets et barres de navigation adopteront un aspect "verre dépoli" laissant transparaître les couleurs d'arrière-plan tout en conservant une lisibilité parfaite.
- **Palette de Couleurs :** Identité forte basée sur le **Rouge Académie (`#C8102E`)** pour les actions primaires, contrasté par un **Anthracite profond (`#1C1C1C`)** et des surfaces structurées (`#F8F8F8` en clair).
- **Animations Dynamiques :** Micro-interactions lors des validations (scan QR, fermeture de séance), transitions fluides entre les écrans.
- **Typographie :** Utilisation systématique de la police **Montserrat** pour son caractère moderne et sportif, assurant une lisibilité maximale sur le terrain.
- **Accessibilité :** Boutons larges et zones tactiles optimisées pour une utilisation dans un environnement sportif (parfois à une main).

## 3. Spécifications Fonctionnelles Détaillées

Ce chapitre décrit de manière exhaustive les fonctionnalités attendues de l'application, organisées par modules logiques.

### 3.1 Architecture et Modèle de Données

L'application repose sur un modèle de données structuré autour des entités métier suivantes :

- **Académicien** : Élève inscrit à l'académie (Nom, Prénom, Photo, Poste de football, Niveau scolaire, QR Code unique).
- **Encadreur** : Coach ou formateur (Nom, Prénom, Photo, Spécialité, Rôle, QR Code unique).
- **Séance** : Unité d'entraînement (Date, Horaires, Statut, Encadreur responsable).
- **Atelier** : Exercice spécifique au sein d'une séance (Nom, Description, Ordre d'exécution).
- **Annotation** : Observation qualifiée sur un académicien dans un atelier donné (Contenu, Tags, Note, Horodatage).
- **Présence** : Enregistrement d'accès au stade (Horodatage, Profil scanné).
- **Bulletin** : Synthèse périodique des performances d'un académicien.

### 3.2 Authentification et Sécurité

L'accès à l'application est strictement contrôlé pour garantir la confidentialité des données sensibles (informations personnelles, évaluations).

- **Contrôle d'accès :** Seuls les administrateurs et les encadreurs disposent d'un compte utilisateur. Les académiciens sont gérés mais ne se connectent pas.
- **Gestion des Sessions :** Authentification via Email/Mot de passe avec persistance de session sécurisée pour éviter les reconnexions fréquentes sur le terrain.
- **Rôles et Permissions :**
  - _Administrateur_ : Accès complet (Gestion des référentiels, Inscriptions, SMS, Bulletins).
  - _Encadreur_ : Accès opérationnel (Gestion des séances, Ateliers, Annotations, Scanner QR).
- **Interface de Connexion :** Design soigné (Glassmorphism) avec gestion explicite des erreurs (réseau, identifiants).

### 3.3 Gestion des Utilisateurs (Académiciens et Encadreurs)

Le système permet l'enregistrement complet des acteurs de l'académie via des formulaires assistés ("Step-by-Step") pour éviter la surcharge cognitive.

**Module Académiciens :**

- Saisie des informations personnelles (Identité, Contact parent, Photo).
- Attribution du profil sportif (Poste favori via référentiel, Pied fort).
- Attribution du niveau scolaire (via référentiel).
- **Génération de QR Code :** Création automatique d'un badge numérique unique à la validation, exportable pour impression ou partage.

**Module Encadreurs :**

- Saisie du profil professionnel (Identité, Contact, Photo, Spécialité sportive).
- Génération similaire d'un badge QR pour l'accès au stade et l'identification lors des séances.
- Consultation de l'historique des activités (séances dirigées).

### 3.4 Contrôle d'Accès et Présence (Module QR)

Le système remplace les feuilles de présence par un scan numérique rapide et fiable.

- **Scanner Intelligent :** Interface plein écran avec viseur graphique ("Verre dépoli").
- **Identification Instantanée :** Reconnaissance du QR Code (Académicien ou Encadreur) avec affichage immédiat de l'identité et du statut (Accès Autorisé/Refusé).
- **Validation Contextuelle :** L'encadreur scanne pour ouvrir sa session de travail, l'académicien scanne pour valider sa présence à la séance en cours.
- **Mode "Rafale" :** Possibilité d'enchaîner les scans rapidement pour gérer l'arrivée d'un groupe (Entrée Rapide).

### 3.5 Gestion des Séances d'Entraînement

La séance est l'unité centrale de l'activité pédagogique. Le système gère son cycle de vie complet pour assurer l'intégrité des données.

- **Ouverture de Séance :** Action explicite de l'encadreur. Le système vérifie qu'aucune séance précédente n'est restée ouverte (blocage ou alerte en cas de conflit).
- **Configuration des Ateliers :** Composition flexible du programme de la séance (Ajout/Modification/Suppression d'ateliers, réorganisation par glisser-déposer).
- **Fermeture de Séance :** Clôture obligatoire en fin d'entraînement. Cette action fige les données (présences, annotations) et génère le rapport de séance.
- **Tableau de Bord :** Vue synthétique des séances (En cours, À venir, Terminées) avec filtres chronologiques.

### 3.6 Suivi Pédagogique (Ateliers et Annotations)

Ce module permet l'évaluation continue et contextualisée des académiciens.

- **Évaluation en Temps Réel :** Interface optimisée pour la saisie terrain (boutons larges, interactions rapides).
- **Annotations Contextualisées :** Chaque observation est liée à un triptyque : _Académicien + Atelier + Séance_.
- **Outils de Saisie Rapide :**
  - Tags prédéfinis (Positif/Négatif, ex: "Application", "Technique").
  - Champ libre pour observations détaillées.
  - Volet latéral rappelant l'historique récent de l'élève pour mesurer sa progression immédiate.

### 3.7 Rapports et Bulletins

Le système exploite les données collectées pour produire des bilans de performance.

- **Bulletin de Formation :** Génération de rapports périodiques (mensuels, trimestriels, saisonniers) agrégeant les annotations.
- **Visualisation de Données :**
  - Graphiques radar (Spider charts) pour les compétences (Technique, Physique, Tactique, Mental).
  - Courbes d'évolution comparant les périodes.
- **Export et Partage :** Formatage du bulletin pour export PDF ou image, facilitant la communication avec les familles.

### 3.8 Communication (Module SMS)

Outil intégré pour faciliter les échanges sans quitter l'application.

- **Envoi Ciblé :** Module d'envoi de SMS (via passerelle backend).
- **Filtres Intelligents :** Sélection des destinataires par critères métier (Par poste, Par niveau scolaire, Par statut présence, etc.).
- **Historique :** Suivi des messages envoyés par l'administration ou les coachs.

### 3.9 Administration et Paramétrage

Le système offre des outils transverses pour la maintenance des données de référence.

- **Recherche Universelle :** Barre de recherche globale permettant d'accéder instantanément à n'importe quelle entité (Académicien, Encadreur, Séance) avec auto-complétion.
- **Gestion des Référentiels :** Interfaces CRUD (Création, Lecture, Mise à jour, Suppression) pour les listes de paramètres :
  - _Postes de Football_ (ex: Gardien, Ailier...).
  - _Niveaux Scolaires_ (ex: 6ème, 5ème...).
    Ceci garantit l'évolutivité de l'application sans intervention technique.

### 3.10 Mode Hors-ligne

Pour répondre aux contraintes terrain (zones à faible couverture réseau), l'application intègre une stratégie "Offline-First".

- **Continuité de Service :** Possibilité de réaliser toutes les actions terrain (Scan, Annotations, Création de séance) sans connexion internet.
- **Synchronisation Différée :** Stockage local des données et synchronisation automatique avec le backend dès le rétablissement de la connexion.
- **Gestion des Conflits :** Mécanismes pour assurer la cohérence des données lors de la fusion avec le serveur.

## 4. Parcours Utilisateurs (User Flows)

1.  **L'Encadreur arrive au stade :** Ouvre l'app -> Clique sur "Scan Entrée" -> Présente son QR ou scanne celui du stade -> Accès validé -> Redirection vers le tableau de bord de la séance.
2.  **L'Encadreur évalue un élève :** Séance en cours -> Choix de l'atelier -> Clic sur l'élève -> Ajout d'une annotation "Progrès en endurance" -> Enregistrement automatique.
3.  **L'Administrateur consulte un bulletin :** Recherche élève -> Onglet "Bulletins" -> Sélection période -> Affichage du bulletin interactif.

## 5. Propositions Complémentaires

- **Gamification :** Attribution de "badges" de mérite aux académiciens consultables sur leur profil pour les motiver.
- **Notifications Push :** Rappel automatique aux encadreurs de fermer la séance si elle dure plus de 3 heures.
- **Scanner Multifonction :** Le scanner QR pourrait aussi servir à scanner les équipements (ballons, chasubles) en début et fin de séance.
- **Calendrier Prévisionnel :** Une vue calendrier pour planifier les séances sur le mois et notifier les parents automatiquement par SMS.

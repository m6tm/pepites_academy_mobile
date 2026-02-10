# Cahier des Charges UI/UX - Pépites Academy

## 1. Introduction et Objectifs
Le projet consiste en la création d'une application mobile "supra attractive" destinée à la gestion d'une académie de football. L'objectif principal est de moderniser et de faciliter le suivi des entraînements, des académiciens et des encadreurs via une interface intuitive, fluide et premium.

## 2. Directions Artistiques et Expérience Utilisateur (UX/UI)
L'application doit dégager une impression de professionnalisme et d'innovation.

*   **Esthétique Premium :** Utilisation de modes sombres élégants (Dark Mode par défaut ou optionnel), de dégradés subtils et de flous de type "glassmorphism".
*   **Animations Dynamiques :** Micro-interactions lors des validations (scan QR, fermeture de séance), transitions fluides entre les écrans.
*   **Typographie :** Utilisation de polices modernes et sportives (ex: Inter, Montserrat ou Roboto Condensed) pour une lisibilité maximale sur le terrain.
*   **Accessibilité :** Boutons larges et zones tactiles optimisées pour une utilisation dans un environnement sportif (parfois à une main).

## 3. Fonctionnalités Détaillées (Focus Interface)

### 3.1. Gestion des Accès (Scan QR)
*   **Écran Scanner :** Interface de scan plein écran avec un viseur animé. Retour haptique (vibration) et visuel immédiat lors de la détection.
*   **Badges de Statut :** Affichage d'un badge "Accès Autorisé" (Vert) ou "Accès Refusé" (Rouge) avec la photo de l'académicien ou de l'encadreur après le scan.
*   **Mode "Entrée Rapide" :** Possibilité d'enchaîner les scans sans quitter l'interface du scanner.

### 3.2. Gestion des Séances d'Entraînement
*   **Tableau de bord des séances :** Liste chronologique des séances avec indicateurs de statut (En cours, Terminée, À venir).
*   **Contrôle de Flux :** Bouton "Ouvrir séance" actif uniquement si la séance précédente est clôturée. Message d'avertissement contextuel si une séance est restée ouverte.
*   **Détails de Séance :** Vue récapitulative affichant les encadreurs présents et les ateliers programmés.

### 3.3. Ateliers et Annotations
*   **Gestion des Ateliers :** Interface permettant d'ajouter des ateliers à une séance via des icônes représentatifs (ex: icône cône pour le dribble, icône cage pour la finition).
*   **Fiche de Suivi Temps Réel :** Lors d'un atelier, liste des académiciens présents. Possibilité de cliquer sur un nom pour ouvrir un volet latéral d'annotations.
*   **Annotations Rapides :** Système de tags pour des observations fréquentes ("Manque de concentration", "Excellente technique", etc.) et champ de texte pour des notes détaillées.

### 3.4. Inscriptions et Profils
*   **Formulaire d'Enregistrement :** Formulaires segmentés par étapes pour éviter la surcharge cognitive lors de l'inscription d'un académicien ou d'un encadreur.
*   **Profil Académicien :** Vue d'ensemble incluant photo, poste favori, niveau scolaire, et un graphique radar d'évolution des compétences.
*   **Profil Encadreur :** Historique des séances dirigées et spécialités.

### 3.5. Bulletin de Formation Périodique
*   **Générateur de Bulletin :** Interface permettant de sélectionner une période (trimestre/mois) et de prévisualiser le bulletin avant export/consultation.
*   **Visualisation de Données :** Utilisation de graphiques (courbes d'évolution, diagrammes) pour rendre le bulletin "parlant" pour les parents et les élèves.

### 3.6. Paramétrages de l'Académie
*   **Référentiels :** Listes éditables pour les postes de football (Gardien, Défenseur, etc.) et les niveaux scolaires (CM1, 6ème, etc.).
*   **Interface SMS :** Module d'envoi de messages groupés ou individuels. Interface de type messagerie moderne avec sélection facile des destinataires par filtres (ex: "Tous les attaquants", "Tous les CM2").

## 4. Parcours Utilisateurs (User Flows)
1.  **L'Encadreur arrive au stade :** Ouvre l'app -> Clique sur "Scan Entrée" -> Présente son QR ou scanne celui du stade -> Accès validé -> Redirection vers le tableau de bord de la séance.
2.  **L'Encadreur évalue un élève :** Séance en cours -> Choix de l'atelier -> Clic sur l'élève -> Ajout d'une annotation "Progrès en endurance" -> Enregistrement automatique.
3.  **L'Administrateur consulte un bulletin :** Recherche élève -> Onglet "Bulletins" -> Sélection période -> Affichage du bulletin interactif.

## 5. Propositions Complémentaires (Suggestions)
*   **Mode Hors-ligne :** Possibilité de faire les annotations sans connexion (fréquent sur les terrains) et synchronisation automatique une fois le Wi-Fi/4G retrouvé.
*   **Gamification :** Attribution de "badges" de mérite aux académiciens consultables sur leur profil pour les motiver.
*   **Notifications Push :** Rappel automatique aux encadreurs de fermer la séance si elle dure plus de 3 heures.
*   **Scanner Multifonction :** Le scanner QR pourrait aussi servir à scanner les équipements (ballons, chasubles) en début et fin de séance.
*   **Calendrier Prévisionnel :** Une vue calendrier pour planifier les séances sur le mois et notifier les parents automatiquement par SMS.

# Liste des Tâches (Backlog de Développement) - Pépites Academy

Ce document liste l'ensemble des tickets nécessaires à la réalisation de l'application mobile, organisés par modules.

## PHASE 1 : Infrastructure & Design System

### [T-102] Modèle de Données (Entités Métier)

- **Objectif :** Définir et créer les entités métier qui structurent toute l'application. Chaque entité correspond à un concept fonctionnel manipulé par les utilisateurs. Elles sont au centre de l'architecture hexagonale et seront implémentées dans `lib/src/domain/entities/`.
- **Description :** Création des classes Dart représentant les entités du domaine. La partie base de données (tables SQL, migrations, politiques RLS) sera gérée dans le projet backend dédié.
- **Entités identifiées :**
  - **Academicien** : Représente un élève inscrit à l'académie. Attributs : nom, prénom, date de naissance, photo, téléphone du parent, poste de football (ref. PosteFootball), niveau scolaire (ref. NiveauScolaire), code QR unique. _(Tickets liés : T-202, T-301, T-402, T-501)_
  - **Encadreur** : Représente un coach/formateur. Attributs : nom, prénom, téléphone, photo, spécialité sportive, rôle (admin/encadreur), code QR unique. _(Tickets liés : T-203, T-301, T-302)_
  - **Seance** : Représente une séance d'entraînement. Attributs : date, heure de début, heure de fin, statut (ouverte/fermée/à venir), encadreur responsable. _(Tickets liés : T-302, T-401, T-601)_
  - **Atelier** : Représente un exercice au sein d'une séance. Attributs : nom, description, icône, ordre d'exécution, séance parente. _(Tickets liés : T-401, T-402)_
  - **Annotation** : Représente une observation faite sur un académicien dans un atelier. Attributs : contenu textuel, tags (positif/négatif), note optionnelle, académicien concerné, atelier concerné, séance parente, encadreur auteur, horodatage. _(Tickets liés : T-402, T-501)_
  - **Presence** : Représente l'enregistrement d'accès au stade via scan QR. Attributs : horodatage d'arrivée, type de profil (académicien/encadreur), profil concerné, séance rattachée. _(Tickets liés : T-301, T-302)_
  - **PosteFootball** : Représente un poste de jeu (Gardien, Défenseur central, etc.). Attributs : nom, description optionnelle, icône optionnelle. _(Tickets liés : T-602, T-202)_
  - **NiveauScolaire** : Représente un niveau scolaire ou académique (CM1, 6ème, etc.). Attributs : nom, ordre d'affichage. _(Tickets liés : T-602, T-202)_
  - **SmsMessage** : Représente un SMS envoyé depuis l'application. Attributs : contenu, liste des destinataires, date d'envoi, statut d'envoi. _(Ticket lié : T-502)_
  - **Bulletin** : Représente un bulletin de formation périodique. Attributs : période (début/fin), académicien concerné, observations générales, compétences agrégées (technique, physique, tactique, mental, esprit d'équipe). _(Ticket lié : T-501)_
- **Sous-tâches :**
  - Création des fichiers Dart pour chaque entité dans `lib/src/domain/entities/`.
  - Définition des relations entre entités (Seance -> Ateliers, Atelier -> Annotations, etc.).
  - Création des interfaces de repository dans `lib/src/domain/repositories/` (contrats que le backend implémentera).

### [T-103] Fondations Flutter & Architecture Hexagonale

- **Description :** Mise en place du socle technique.
- **Sous-tâches :**
  - Mise à jour du fichier `pubspec.yaml` avec les dépendances (provider/flutter_bloc, google_fonts, http/dio).
  - Finalisation des dossiers `lib/src` (domain, application, infrastructure, presentation).
  - Création des constantes de spacing et radius basées sur le cahier des charges.

## PHASE 2 : Authentification & Inscriptions (Points 6, 7)

### [T-201] Système d'Authentification

- **Objectif :** L'application gère des données sensibles (informations personnelles des académiciens, évaluations, contacts). L'accès doit être sécurisé et réservé aux utilisateurs autorisés. Ce ticket met en place le système d'authentification qui constitue la porte d'entrée de l'application :
  - **Contrôler l'accès** : Seuls les administrateurs et les encadreurs enregistrés peuvent se connecter. Les académiciens n'ont pas de compte utilisateur (leurs données sont gérées par les encadreurs).
  - **Différencier les rôles** : Après connexion, l'application redirige vers l'interface adaptée au rôle. L'administrateur accède à toutes les fonctionnalités (inscriptions, référentiels, SMS, bulletins). L'encadreur accède aux fonctions terrain (séances, ateliers, annotations, scanner QR).
  - **Sécuriser les sessions** : La session reste active tant que l'utilisateur ne se déconnecte pas, évitant de retaper ses identifiants à chaque ouverture de l'app sur le terrain.
  - Sans authentification, n'importe qui pourrait consulter ou modifier les données de l'académie.
- **Description :** Écran de connexion Premium avec design Glassmorphism (fond Anthracite, logo de l'académie, champs de saisie avec effet verre dépoli) et gestion des erreurs élégante.
- **Sous-tâches :**
  - Écran de connexion avec champs Email/Mot de passe et bouton de connexion stylisé (Rouge Académie).
  - Appel à l'API backend pour l'authentification (login avec email/password).
  - Gestion des erreurs de connexion (identifiants incorrects, compte inexistant, réseau indisponible) avec messages clairs en français.
  - Persistance de la session locale (stockage sécurisé du token, auto-login au redémarrage de l'app).
  - Redirection automatique selon le rôle (Admin vers le dashboard complet, Encadreur vers le dashboard terrain).
  - Bouton de déconnexion accessible depuis les paramètres.
  - Écran de mot de passe oublié (optionnel).

### [T-202] Écran d'Enregistrement Académicien (Step-by-Step) [DONE]

- **Objectif :** L'académicien est l'acteur central de l'application. Avant de pouvoir être scanné, évalué, annoté ou apparaître dans un bulletin, il doit être enregistré dans le système. Ce formulaire permet de :
  - **Constituer la fiche de l'élève** : Recueillir toutes les informations nécessaires au suivi (identité, photo, contact, poste de football, niveau scolaire).
  - **Générer son badge QR** : À la fin de l'inscription, un code QR unique est automatiquement attribué à l'académicien. Ce QR servira ensuite pour valider son accès au stade (ticket T-301) et enregistrer sa présence aux séances.
  - **Alimenter les référentiels** : Le poste de football et le niveau scolaire sont sélectionnés depuis les référentiels existants (tickets T-602), garantissant la cohérence des données pour les filtres SMS et les bulletins.
  - Sans cette inscription préalable, l'académicien ne peut ni accéder au stade, ni être évalué, ni recevoir de bulletin.
- **Description :** Formulaire segmenté par étapes (Step-by-Step) pour éviter la surcharge cognitive, avec validation progressive et aperçu du profil avant confirmation.
- **Sous-tâches :**
  - Étape 1 : Informations personnelles (Nom, Prénom, Date de naissance, Numéro de téléphone du parent, Photo).
  - Étape 2 : Informations football (Poste favori via le référentiel des postes, pied fort).
  - Étape 3 : Informations scolaires (Niveau scolaire/académique via le référentiel des niveaux).
  - Écran de récapitulatif avec aperçu du profil complet avant validation.
  - Génération automatique du code QR unique après confirmation.
  - Possibilité de partager ou imprimer le QR généré (envoi par SMS ou export image).

### [T-203] Gestion des Encadreurs

- **Objectif :** L'encadreur est le pilote opérationnel de l'application. C'est lui qui ouvre les séances, compose les ateliers, scanne les académiciens et rédige les annotations. Pour exercer ces fonctions, il doit d'abord être enregistré dans le système. Ce formulaire permet de :
  - **Créer le profil du coach** : Recueillir ses informations personnelles (identité, photo, contact, spécialité sportive).
  - **Générer son badge QR** : Comme pour l'académicien, un code QR unique est attribué à l'encadreur pour valider son accès au stade (ticket T-301) et le rattacher automatiquement aux séances qu'il dirige.
  - **Définir ses droits** : L'encadreur accède aux fonctionnalités de gestion (ouverture/fermeture de séance, annotations) tandis que l'administrateur conserve un contrôle global.
  - Sans encadreur enregistré, aucune séance ne peut être ouverte, aucun atelier ne peut être dirigé, et aucune annotation ne peut être rédigée.
- **Description :** Formulaire d'inscription avec les mêmes standards visuels que celui des académiciens (Step-by-Step, Glassmorphism), adapté aux informations spécifiques d'un coach.
- **Sous-tâches :**
  - Étape 1 : Informations personnelles (Nom, Prénom, Numéro de téléphone, Photo).
  - Étape 2 : Informations sportives (Spécialité : technique, physique, gardien, etc.).
  - Écran de récapitulatif avec aperçu du profil avant validation.
  - Génération automatique du code QR unique après confirmation.
  - Consultation du profil encadreur avec historique des séances dirigées et statistiques.

## PHASE 3 : Gestion des Accès QR & Séances (Points 1, 2, 3)

### [T-301] Implémentation du Scanner QR (Glassmorphism)

- **Objectif :** Chaque académicien et chaque encadreur dispose d'un code QR unique attribué lors de son inscription. Ce code QR sert de badge d'accès numérique au stade d'entraînement. L'application permet de scanner ce QR via la caméra du téléphone pour :
  - **Académiciens :** Valider leur présence à l'entraînement et enregistrer automatiquement leur arrivée dans la séance en cours.
  - **Encadreurs :** Confirmer leur prise de poste au stade et les rattacher à la séance qu'ils vont diriger.
  - Cela remplace les feuilles de présence papier, assure un suivi fiable et instantané des entrées, et alimente automatiquement les statistiques de présence.
- **Description :** Interface de scan plein écran avec effets Glassmorphism (viseur en verre dépoli, flou d'arrière-plan) et retour visuel immédiat (badge Autorisé/Refusé avec photo).
- **Sous-tâches :**
  - Intégration de la caméra via `mobile_scanner`.
  - Design du viseur "Verre dépoli" avec bordures lumineuses animées.
  - Logique de vérification en temps réel via l'API backend (identification du profil, enregistrement de la présence).
  - Affichage du badge de statut avec photo et nom après scan.
  - Mode "Entrée Rapide" pour enchaîner les scans sans quitter l'interface.

### [T-302] Flux de Séance (Ouverture/Fermeture)

- **Objectif :** Une séance d'entraînement est l'unité centrale de l'application. Elle structure tout le travail sur le terrain : ateliers, annotations, présences. Ce ticket gère le cycle de vie complet d'une séance pour les académiciens et les encadreurs :
  - **Ouverture :** Un encadreur ouvre une nouvelle séance. Le système vérifie automatiquement que la séance précédente a bien été clôturée avant d'autoriser l'ouverture. Si ce n'est pas le cas, un message d'avertissement s'affiche et l'ouverture est bloquée.
  - **Fermeture :** L'encadreur clôture la séance une fois l'entraînement terminé. La fermeture fige les données (présences, annotations, ateliers) et rend la séance consultable en lecture seule.
  - Cette mécanique garantit l'intégrité des données et évite les chevauchements de séances, assurant un historique propre et exploitable pour les bulletins de formation.
- **Description :** Dashboard de contrôle des séances avec indicateurs visuels de statut (En cours, Terminée, A venir) et boutons d'action contextuels.
- **Sous-tâches :**
  - Écran "Tableau de bord des séances" avec liste chronologique et filtres.
  - Bouton "Ouvrir séance" avec vérification de l'état de la séance précédente.
  - Message d'avertissement contextuel si une séance est restée ouverte.
  - Bouton "Fermer séance" avec récapitulatif de la séance (nombre de présents, ateliers réalisés).
  - Vue détaillée d'une séance affichant les encadreurs présents, les académiciens et les ateliers programmés.

## PHASE 4 : Ateliers & Évaluation (Points 4, 5)

### [T-401] Configuration des Ateliers de Séance

- **Objectif :** Chaque séance d'entraînement est composée de plusieurs ateliers (exercices thématiques). Un atelier représente un bloc d'activité précis durant la séance : dribble, passes, finition, condition physique, jeu en situation, etc. Ce ticket permet à l'encadreur de :
  - **Composer la séance** : Ajouter, modifier ou supprimer les ateliers prévus pour une séance donnée, directement depuis l'application.
  - **Structurer le terrain** : Organiser l'ordre des ateliers pour refléter le déroulement réel de l'entraînement.
  - **Préparer l'évaluation** : Les ateliers servent de cadre pour les annotations individuelles sur chaque académicien (ticket T-402). Sans atelier défini, aucune évaluation ne peut être rattachée.
  - Cela permet d'avoir un historique précis de ce qui a été travaillé séance après séance, facilitant le suivi de la progression et la rédaction des bulletins de formation.
- **Description :** Interface de gestion des ateliers au sein d'une séance, avec des icônes représentatifs par type d'exercice et une organisation par glisser-déposer.
- **Sous-tâches :**
  - Écran de composition des ateliers rattaché à une séance ouverte.
  - Sélection des ateliers via des icônes visuels (cone pour dribble, cage pour finition, chronomètre pour physique, etc.).
  - Possibilité d'ajouter un atelier personnalisé avec nom et description libre.
  - Réorganisation de l'ordre des ateliers par glisser-déposer.
  - Affichage récapitulatif du programme de la séance avec le nombre d'ateliers.

### [T-402] Module d'Annotations et Observations

- **Objectif :** L'encadreur doit pouvoir évaluer individuellement chaque académicien dans le cadre d'un atelier bien spécifique. Les annotations et observations constituent la matière première du suivi pédagogique. Ce module permet de :
  - **Annoter en temps réel** : Pendant ou juste après un atelier, l'encadreur sélectionne un académicien et rédige une observation (ex: "Bonne lecture du jeu", "Manque d'appui sur le pied gauche").
  - **Contextualiser chaque note** : Chaque annotation est rattachée à un académicien, un atelier et une séance. On sait donc exactement quand, dans quel exercice et par quel encadreur l'observation a été faite.
  - **Faire ressortir l'évolution** : En accumulant les annotations séance après séance, l'application construit un historique de progression consultable. C'est cette donnée qui alimente le bulletin de formation périodique (ticket T-501) et permet aux parents et encadreurs de mesurer les progrès concrets de l'académicien.
  - Sans ce module, aucune évaluation individuelle n'est possible et le bulletin de formation resterait vide.
- **Description :** Interface d'évaluation rapide et intuitive, utilisable sur le terrain (gros boutons, tags en un clic), avec volet latéral par académicien affichant l'historique de ses annotations précédentes.
- **Sous-tâches :**
  - Liste des académiciens présents dans l'atelier avec photo et nom.
  - Ouverture d'un volet latéral au clic sur un académicien.
  - Système de tags d'observations rapides catégorisés (Positif : "Excellent", "En progrès" / Négatif : "A travailler", "Insuffisant").
  - Champ de texte libre pour les observations détaillées et personnalisées.
  - Attribution d'une note ou appréciation globale par atelier (optionnel).
  - Affichage de l'historique des annotations précédentes de l'académicien dans le volet (pour contextualiser l'évaluation).
  - Enregistrement automatique des annotations (pas de bouton "Sauvegarder" pour fluidifier l'usage sur le terrain).

## PHASE 5 : Rapports et Communication (Points 8, 10)

### [T-501] Bulletin de Formation Périodique

- **Objectif :** Le bulletin de formation est l'équivalent d'un bulletin de notes scolaire, mais appliqué au football. Il synthétise l'ensemble des annotations et observations recueillies sur un académicien au cours d'une période donnée (mois, trimestre, saison). Ce module permet de :
  - **Consolider les évaluations** : Agréger toutes les annotations des différents ateliers et séances sur la période sélectionnée pour produire un bilan clair et lisible.
  - **Visualiser la progression** : Présenter l'évolution de l'académicien sous forme de graphiques (diagramme radar des compétences, courbes de progression par domaine : technique, physique, tactique, mental).
  - **Communiquer avec les parents** : Offrir un document consultable et partageable, permettant aux parents de suivre concrètement les progrès de leur enfant à l'académie.
  - **Motiver l'académicien** : Le bulletin met en avant les points forts et identifie les axes d'amélioration, donnant à l'élève des objectifs concrets pour la période suivante.
  - Sans les annotations du module T-402, le bulletin serait vide. C'est la finalité de tout le processus d'évaluation.
- **Description :** Interface de consultation et de génération du bulletin avec sélection de période, prévisualisation interactive et possibilité d'export/partage.
- **Sous-tâches :**
  - Sélecteur de période (mois, trimestre, saison) avec calendrier visuel.
  - Écran de prévisualisation du bulletin avec mise en page type scolaire (en-tête académie, identité de l'élève, tableau des appréciations par domaine).
  - Widget graphique radar des compétences (Technique, Physique, Tactique, Mental, Esprit d'équipe).
  - Courbes d'évolution comparant la période actuelle aux périodes précédentes.
  - Section "Observations générales" rédigée par l'encadreur principal.
  - Export du bulletin en PDF ou image partageable (WhatsApp, SMS, impression).

### [T-502] Module d'Envoi SMS

- **Objectif :** La communication avec les académiciens (ou leurs parents) et les encadreurs est essentielle pour le bon fonctionnement de l'académie. Ce module permet d'envoyer des SMS directement depuis l'application, sans passer par le répertoire téléphonique personnel. Il couvre les cas suivants :
  - **SMS individuel** : Envoyer un message à un académicien précis (ex: "Votre fils est convoqué pour un match amical samedi") ou à un encadreur (ex: "Séance décalée à 16h demain").
  - **SMS groupé** : Envoyer un message à un groupe filtré de destinataires. Par exemple : "Tous les attaquants", "Tous les académiciens de niveau 6ème", "Tous les encadreurs", ou encore "Tous les présents à la dernière séance".
  - **Gain de temps** : L'administrateur ou l'encadreur n'a plus besoin de chercher les numéros un par un. Les contacts sont déjà dans l'application grâce aux inscriptions (T-202, T-203).
  - Sans ce module, la communication reposerait sur des groupes WhatsApp informels ou des appels manuels, ce qui est peu professionnel et chronophage.
- **Description :** Interface de type messagerie moderne avec sélection de destinataires par filtres intelligents, rédaction du message et envoi via l'API backend.
- **Sous-tâches :**
  - Écran de composition de SMS avec champ de texte et compteur de caractères.
  - Sélection individuelle d'un destinataire (recherche par nom).
  - Sélection groupée par filtres (par poste de football, par niveau scolaire, par statut Académicien/Encadreur).
  - Prévisualisation du nombre de destinataires sélectionnés avant envoi.
  - Confirmation avant envoi avec récapitulatif (nombre de SMS, liste des destinataires).
  - Appel à l'API backend pour l'envoi effectif des SMS (la passerelle SMS est gérée côté backend).
  - Historique des SMS envoyés avec date, contenu et destinataires.

## PHASE 6 : Paramètres & Consultation (Points 9, 11, 12, 13)

### [T-601] Recherche Universelle & Consultation

- **Objectif :** L'application contient de nombreuses données (académiciens, encadreurs, séances passées). Ce module offre un point d'accès unique pour consulter n'importe quelle entité rapidement, sans naviguer dans plusieurs menus. Il permet de :
  - **Consulter un académicien** : Accéder à sa fiche complète (photo, poste, niveau scolaire, historique de présence, annotations reçues, bulletins).
  - **Consulter un encadreur** : Voir son profil, les séances qu'il a dirigées, ses spécialités et ses statistiques.
  - **Consulter une séance d'entraînement** : Retrouver le détail d'une séance passée (date, encadreurs présents, académiciens présents, ateliers réalisés, annotations enregistrées).
  - **Rechercher efficacement** : Une barre de recherche universelle avec suggestions en temps réel permet de trouver instantanément un élève par son nom, un encadreur ou une séance par sa date.
  - Sans cette fonctionnalité, il faudrait naviguer manuellement dans des listes pour retrouver une information, ce qui serait fastidieux au quotidien.
- **Description :** Barre de recherche globale accessible depuis la page d'accueil avec filtres par type (Académicien, Encadreur, Séance) et résultats en temps réel.
- **Sous-tâches :**
  - Barre de recherche avec auto-complétion et suggestions instantanées.
  - Filtres par catégorie (Académiciens, Encadreurs, Séances).
  - Fiche de consultation détaillée pour un académicien (onglets : Infos, Présences, Annotations, Bulletins).
  - Fiche de consultation détaillée pour un encadreur (onglets : Infos, Séances dirigées, Statistiques).
  - Fiche de consultation détaillée pour une séance (récapitulatif complet en lecture seule).
  - Historique des recherches récentes pour un accès rapide.

### [T-602] Gestion des Référentiels

- **Objectif :** Les référentiels sont les listes de base qui alimentent tout le reste de l'application. Ils regroupent deux types de données fondamentales :
  - **Postes de football en vigueur** : Gardien, Défenseur central, Latéral droit, Latéral gauche, Milieu défensif, Milieu offensif, Ailier droit, Ailier gauche, Avant-centre, etc. Ces postes sont attribués aux académiciens lors de leur inscription (T-202) et servent de filtre pour l'envoi de SMS ciblés (T-502) et pour l'évaluation par atelier (T-402).
  - **Niveaux scolaires ou académiques** : Primaire (CP, CE1, CE2, CM1, CM2), Collège (6ème, 5ème, 4ème, 3ème), Lycée (2nde, 1ère, Terminale), Université, etc. Ces niveaux sont renseignés lors de l'inscription et permettent de regrouper les académiciens par tranche d'âge/niveau pour les filtres SMS et les statistiques.
  - L'administrateur doit pouvoir ajouter, modifier ou supprimer des entrées dans ces listes à tout moment, sans intervention technique. Si un nouveau poste émerge dans le football ou si l'académie s'ouvre à un nouveau niveau scolaire, la mise à jour se fait directement depuis l'application.
  - Sans ces référentiels, les formulaires d'inscription seraient des champs libres sans cohérence, rendant les filtres et les statistiques inexploitables.
- **Description :** Écrans d'administration dédiés à la gestion des listes de postes de football et de niveaux scolaires, avec opérations CRUD complètes.
- **Sous-tâches :**
  - Écran "Postes de Football" avec liste des postes existants et bouton d'ajout.
  - Ajout d'un nouveau poste (nom, description optionnelle, icône optionnelle).
  - Modification et suppression d'un poste existant (avec vérification des académiciens rattachés avant suppression).
  - Écran "Niveaux Scolaires" avec liste des niveaux existants et bouton d'ajout.
  - Ajout d'un nouveau niveau (nom, ordre d'affichage).
  - Modification et suppression d'un niveau existant (avec vérification des académiciens rattachés avant suppression).
  - Pré-remplissage des référentiels avec les valeurs par défaut lors de la première installation.

### [T-603] Mode Hors-ligne (Proposition)

- **Objectif :** Les terrains d'entraînement sont souvent situés dans des zones où la couverture réseau est faible voire inexistante (stades en périphérie, terrains en terre battue, zones rurales). Si l'application ne fonctionne qu'en ligne, l'encadreur ne pourrait pas enregistrer les présences ni rédiger les annotations pendant l'entraînement. Ce module permet de :
  - **Travailler sans connexion** : L'encadreur peut scanner les QR, ouvrir une séance, ajouter des ateliers et rédiger des annotations même sans réseau mobile ni Wi-Fi.
  - **Stocker localement** : Toutes les données saisies hors-ligne sont enregistrées dans une base de données locale sur le téléphone (SQLite ou Hive).
  - **Synchroniser automatiquement** : Dès que le téléphone retrouve une connexion (Wi-Fi ou 4G), les données en attente sont envoyées vers l'API backend automatiquement, sans action de l'utilisateur.
  - **Gérer les conflits** : Si une même donnée a été modifiée en ligne et hors-ligne, un mécanisme de résolution de conflits (dernière écriture prioritaire ou alerte manuelle) empêche la perte de données.
  - Sans ce mode, l'application serait inutilisable sur de nombreux terrains, rendant le retour aux feuilles papier inévitable.
- **Description :** Couche de persistance locale avec file d'attente de synchronisation et indicateur visuel du statut de connexion dans l'interface.
- **Sous-tâches :**
  - Mise en place d'une base de données locale (SQLite via `drift` ou `hive`).
  - File d'attente de synchronisation pour les opérations en attente (annotations, présences, ateliers).
  - Indicateur visuel permanent du statut réseau dans la barre d'application (connecté / hors-ligne / synchronisation en cours).
  - Synchronisation automatique en arrière-plan dès le retour de la connexion.
  - Notification de confirmation une fois la synchronisation terminée ("X annotations synchronisées").
  - Gestion des conflits de données avec stratégie de résolution configurable.

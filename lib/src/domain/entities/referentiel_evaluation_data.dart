import 'critere_evaluation.dart';

/// Referentiel complet des criteres et elements d'evaluation.
/// Source de verite unique pour le systeme d'evaluation multicritere.
/// Synchronise avec backend/scripts/seed_evaluation_referentiel.py
class ReferentielEvaluationData {
  ReferentielEvaluationData._();

  static const String critereIdTechnique = 'critere_technique';
  static const String critereIdTactique = 'critere_tactique';
  static const String critereIdPhysique = 'critere_physique';
  static const String critereIdDisciplineMental = 'critere_discipline_mental';
  static const String critereIdPossessionGlobale = 'critere_possession_globale';

  static final List<CritereEvaluation> criteres = [
    _technique,
    _tactique,
    _physique,
    _disciplineMental,
    _possessionGlobale,
  ];

  // --- Technique ---

  static final CritereEvaluation _technique = CritereEvaluation(
    id: critereIdTechnique,
    nom: 'Technique',
    description: 'Maitrise des gestes techniques individuels',
    ordre: 0,
    elements: [
      ElementEvaluation(
        id: 'technique_1',
        libelle: 'Conduite de balle',
        description: 'Capacite a controllrer le ballon lors des deplacements avec les pieds, en ligne droite et en changeant de direction',
        critereId: critereIdTechnique,
        ordre: 0,
      ),
      ElementEvaluation(
        id: 'technique_2',
        libelle: 'Dribbles',
        description: 'Abitete a eliminer un adversaire par des feintes et changements de rythme, balle au pied',
        critereId: critereIdTechnique,
        ordre: 1,
      ),
      ElementEvaluation(
        id: 'technique_3',
        libelle: 'Passes courtes',
        description: 'Precision et dosage des passes a courte distance (moins de 10m), controle du rythme de jeu',
        critereId: critereIdTechnique,
        ordre: 2,
      ),
      ElementEvaluation(
        id: 'technique_4',
        libelle: 'Passes longues',
        description: 'Precision et puissance des passes a longue distance (plus de 10m), jeu long et transitions',
        critereId: critereIdTechnique,
        ordre: 3,
      ),
      ElementEvaluation(
        id: 'technique_5',
        libelle: 'Controle',
        description: 'Qualite de la premiere touche de balle, aptitude a dominer le ballon sous pression',
        critereId: critereIdTechnique,
        ordre: 4,
      ),
      ElementEvaluation(
        id: 'technique_6',
        libelle: 'Tirs',
        description: 'Puissance et precision des frappes au but, placement du ballon dans les angles',
        critereId: critereIdTechnique,
        ordre: 5,
      ),
      ElementEvaluation(
        id: 'technique_7',
        libelle: 'Jeu de tete',
        description: 'Maitrise du jeu aerien offensit et defensif, timing et placement pour les duels aeriens',
        critereId: critereIdTechnique,
        ordre: 6,
      ),
      ElementEvaluation(
        id: 'technique_8',
        libelle: 'Utilisation du pied faible',
        description: 'Aptitude a jouer correctement des deux pieds, justesse des passes et tirs du pied faible',
        critereId: critereIdTechnique,
        ordre: 7,
      ),
    ],
  );

  // --- Tactique ---

  static final CritereEvaluation _tactique = CritereEvaluation(
    id: critereIdTactique,
    nom: 'Tactique',
    description: 'Intelligence de jeu et prise de decision collective',
    ordre: 1,
    elements: [
      ElementEvaluation(
        id: 'tactique_1',
        libelle: 'Placement',
        description: 'Positionnement judicieux sur le terrain en fonction de la phase de jeu et de la position du ballon',
        critereId: critereIdTactique,
        ordre: 0,
      ),
      ElementEvaluation(
        id: 'tactique_2',
        libelle: 'Vision du jeu',
        description: 'Lecture du jeu a distance, capacite a anticiper les/developpements et voir les solutions de passe',
        critereId: critereIdTactique,
        ordre: 1,
      ),
      ElementEvaluation(
        id: 'tactique_3',
        libelle: 'Comprehension des consignes',
        description: 'Application des instructions de l\'encadreur et respect du plan de jeu eta bli',
        critereId: critereIdTactique,
        ordre: 2,
      ),
      ElementEvaluation(
        id: 'tactique_4',
        libelle: 'Intelligence de jeu',
        description: 'Capacite a faire les bons choix en fonction des situations, prise de decision rapide et adapte',
        critereId: critereIdTactique,
        ordre: 3,
      ),
      ElementEvaluation(
        id: 'tactique_5',
        libelle: 'Jeu colectif',
        description: 'Aptitude a jouer en equipe, coordination avec les partenaires, passes et mouvements synchronises',
        critereId: critereIdTactique,
        ordre: 4,
      ),
      ElementEvaluation(
        id: 'tactique_6',
        libelle: 'Transitions attaque/defense',
        description: 'Rapidite et organisation lors du basculement entre phases offensives et defensives',
        critereId: critereIdTactique,
        ordre: 5,
      ),
    ],
  );

  // --- Physique ---

  static final CritereEvaluation _physique = CritereEvaluation(
    id: critereIdPhysique,
    nom: 'Physique',
    description: 'Capacites physiques et condition athletique',
    ordre: 2,
    elements: [
      ElementEvaluation(
        id: 'physique_1',
        libelle: 'Vitesse',
        description: 'Rapidite sur courte et moyenne distance, capacite d\'acceleration et de pointe',
        critereId: critereIdPhysique,
        ordre: 0,
      ),
      ElementEvaluation(
        id: 'physique_2',
        libelle: 'Endurance',
        description: 'Capacite a maintenir un effort intense et prolonge sans perte d\'intensite',
        critereId: critereIdPhysique,
        ordre: 1,
      ),
      ElementEvaluation(
        id: 'physique_3',
        libelle: 'Coordination',
        description: 'Harmonie des mouvements, precision gestuelle et capacite a executer des actions complexes',
        critereId: critereIdPhysique,
        ordre: 2,
      ),
      ElementEvaluation(
        id: 'physique_4',
        libelle: 'Agilité',
        description: 'Aptitude a changer rapidement de direction, esquive et reactivite',
        critereId: critereIdPhysique,
        ordre: 3,
      ),
      ElementEvaluation(
        id: 'physique_5',
        libelle: 'Equilibre',
        description: 'Stabilite corporelle en mouvement et lors des duels, capacite a garder l\'assise',
        critereId: critereIdPhysique,
        ordre: 4,
      ),
      ElementEvaluation(
        id: 'physique_6',
        libelle: 'Puissance',
        description: 'Force explosive, capacite de saut et de traction, impact dans les duels',
        critereId: critereIdPhysique,
        ordre: 5,
      ),
    ],
  );

  // --- Discipline et Mental ---

  static final CritereEvaluation _disciplineMental = CritereEvaluation(
    id: critereIdDisciplineMental,
    nom: 'Discipline et Mental',
    description: 'Comportement, attitude mentale et discipline personnelle',
    ordre: 3,
    elements: [
      ElementEvaluation(
        id: 'discipline_mental_1',
        libelle: 'Ponctualité',
        description: 'Respect des horaires, arrivee a l\'heure aux entrainements et seances, serieux',
        critereId: critereIdDisciplineMental,
        ordre: 0,
      ),
      ElementEvaluation(
        id: 'discipline_mental_2',
        libelle: 'Respect',
        description: 'Attitude respectueuse envers les partenaires, adversaires, encadreurs et arbitres',
        critereId: critereIdDisciplineMental,
        ordre: 1,
      ),
      ElementEvaluation(
        id: 'discipline_mental_3',
        libelle: 'Concentration',
        description: 'Capacite a rester attentif durant toute la seance, maintien de la vigilance',
        critereId: critereIdDisciplineMental,
        ordre: 2,
      ),
      ElementEvaluation(
        id: 'discipline_mental_4',
        libelle: 'Motivation',
        description: 'Energie et implication dans les exercices, desir de progres et d\'apprentissage',
        critereId: critereIdDisciplineMental,
        ordre: 3,
      ),
      ElementEvaluation(
        id: 'discipline_mental_5',
        libelle: 'Leadership',
        description: 'Capacite a guider et encourager les partenaires, prise d\'initiative positive',
        critereId: critereIdDisciplineMental,
        ordre: 4,
      ),
      ElementEvaluation(
        id: 'discipline_mental_6',
        libelle: 'Collectif',
        description: 'Esprit d\'equipe, mise en avant du groupe avant l\'individuel, entraide',
        critereId: critereIdDisciplineMental,
        ordre: 5,
      ),
      ElementEvaluation(
        id: 'discipline_mental_7',
        libelle: 'Gestion emotionnelle',
        description: 'Maitrise des emotions en situation de pression ou de frustration, autocontrol',
        critereId: critereIdDisciplineMental,
        ordre: 6,
      ),
    ],
  );

  // --- Possession globale ---

  static final CritereEvaluation _possessionGlobale = CritereEvaluation(
    id: critereIdPossessionGlobale,
    nom: 'Possession globale',
    description: 'Maitrise collective du ballon et gestion des phases de jeu',
    ordre: 4,
    elements: [
      ElementEvaluation(
        id: 'possession_globale_1',
        libelle: 'Maitrise du ballon',
        description: 'Capacite a garder le ballon sous pression, protection du ballon face aux adversaires',
        critereId: critereIdPossessionGlobale,
        ordre: 0,
      ),
      ElementEvaluation(
        id: 'possession_globale_2',
        libelle: 'Gestion des phases de jeu',
        description: 'Aptitude a alterner entre jeu court et jeu long, controle du rythme de partie',
        critereId: critereIdPossessionGlobale,
        ordre: 1,
      ),
      ElementEvaluation(
        id: 'possession_globale_3',
        libelle: 'Creation de possibilites',
        description: 'Capacite a generer des espaces et des occasions de jeu, inspiration offensive',
        critereId: critereIdPossessionGlobale,
        ordre: 2,
      ),
      ElementEvaluation(
        id: 'possession_globale_4',
        libelle: 'Communication',
        description: 'Echanges verbaux et non-verbaux avec les partenaires, verbalisation des intentions',
        critereId: critereIdPossessionGlobale,
        ordre: 3,
      ),
      ElementEvaluation(
        id: 'possession_globale_5',
        libelle: 'Strategie',
        description: 'Comprehension et application des plans de jeu, lecture des schemes tactiques',
        critereId: critereIdPossessionGlobale,
        ordre: 4,
      ),
      ElementEvaluation(
        id: 'possession_globale_6',
        libelle: 'Adaptation',
        description: 'Flexibilite face aux aleas du match, capacite a s\'ajuster aux situations nouvelles',
        critereId: critereIdPossessionGlobale,
        ordre: 5,
      ),
      ElementEvaluation(
        id: 'possession_globale_7',
        libelle: 'Esprit d\'initiative',
        description: 'Proactivite dans les actions, prise d\'initiative justifiee et risque controle',
        critereId: critereIdPossessionGlobale,
        ordre: 6,
      ),
    ],
  );
}
import 'critere_evaluation.dart';

/// Referentiel complet des criteres et elements d'evaluation.
/// Source de verite unique pour le systeme d'evaluation multicritere.
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
    elements: [
      ElementEvaluation(
        id: 'tech_dribble',
        libelle: 'Dribble',
        description: 'Capacite a eliminer un adversaire balle au pied',
        critereId: critereIdTechnique,
      ),
      ElementEvaluation(
        id: 'tech_passe_courte',
        libelle: 'Passe courte',
        description: 'Precision et dosage des passes a courte distance',
        critereId: critereIdTechnique,
      ),
      ElementEvaluation(
        id: 'tech_passe_longue',
        libelle: 'Passe longue',
        description: 'Precision et dosage des passes a longue distance',
        critereId: critereIdTechnique,
      ),
      ElementEvaluation(
        id: 'tech_controle',
        libelle: 'Controle',
        description: 'Qualite de la premiere touche de balle',
        critereId: critereIdTechnique,
      ),
      ElementEvaluation(
        id: 'tech_frappe',
        libelle: 'Frappe',
        description: 'Puissance et precision du tir au but',
        critereId: critereIdTechnique,
      ),
      ElementEvaluation(
        id: 'tech_tete',
        libelle: 'Jeu de tete',
        description: 'Maitrise du jeu aerien offensif et defensif',
        critereId: critereIdTechnique,
      ),
      ElementEvaluation(
        id: 'tech_jonglerie',
        libelle: 'Jonglerie',
        description: 'Habilete a maintenir le ballon en l\'air',
        critereId: critereIdTechnique,
      ),
    ],
  );

  // --- Tactique ---

  static final CritereEvaluation _tactique = CritereEvaluation(
    id: critereIdTactique,
    nom: 'Tactique',
    description: 'Intelligence de jeu et prise de decision collective',
    elements: [
      ElementEvaluation(
        id: 'tact_placement',
        libelle: 'Placement',
        description: 'Positionnement sur le terrain en fonction du jeu',
        critereId: critereIdTactique,
      ),
      ElementEvaluation(
        id: 'tact_appel_balle',
        libelle: 'Appel de balle',
        description: 'Qualite des courses pour se rendre disponible',
        critereId: critereIdTactique,
      ),
      ElementEvaluation(
        id: 'tact_couverture',
        libelle: 'Couverture',
        description: 'Capacite a couvrir les espaces et les partenaires',
        critereId: critereIdTactique,
      ),
      ElementEvaluation(
        id: 'tact_marquage',
        libelle: 'Marquage',
        description: 'Rigueur dans le suivi des adversaires',
        critereId: critereIdTactique,
      ),
      ElementEvaluation(
        id: 'tact_transition',
        libelle: 'Transition',
        description: 'Rapidite de basculement entre phases offensives et defensives',
        critereId: critereIdTactique,
      ),
      ElementEvaluation(
        id: 'tact_vision_jeu',
        libelle: 'Vision du jeu',
        description: 'Lecture du jeu et anticipation des situations',
        critereId: critereIdTactique,
      ),
    ],
  );

  // --- Physique ---

  static final CritereEvaluation _physique = CritereEvaluation(
    id: critereIdPhysique,
    nom: 'Physique',
    description: 'Capacites physiques et condition athletique',
    elements: [
      ElementEvaluation(
        id: 'phys_endurance',
        libelle: 'Endurance',
        description: 'Capacite a maintenir un effort prolonge',
        critereId: critereIdPhysique,
      ),
      ElementEvaluation(
        id: 'phys_vitesse',
        libelle: 'Vitesse',
        description: 'Rapidite sur courte et moyenne distance',
        critereId: critereIdPhysique,
      ),
      ElementEvaluation(
        id: 'phys_coordination',
        libelle: 'Coordination',
        description: 'Harmonie des mouvements et agilite motrice',
        critereId: critereIdPhysique,
      ),
      ElementEvaluation(
        id: 'phys_souplesse',
        libelle: 'Souplesse',
        description: 'Amplitude articulaire et flexibilite musculaire',
        critereId: critereIdPhysique,
      ),
      ElementEvaluation(
        id: 'phys_puissance',
        libelle: 'Puissance',
        description: 'Force explosive et capacite de saut',
        critereId: critereIdPhysique,
      ),
      ElementEvaluation(
        id: 'phys_equilibre',
        libelle: 'Equilibre',
        description: 'Stabilite corporelle en mouvement et en duel',
        critereId: critereIdPhysique,
      ),
    ],
  );

  // --- Discipline et Mental ---

  static final CritereEvaluation _disciplineMental = CritereEvaluation(
    id: critereIdDisciplineMental,
    nom: 'Discipline et Mental',
    description: 'Comportement, attitude mentale et discipline personnelle',
    elements: [
      ElementEvaluation(
        id: 'disc_concentration',
        libelle: 'Concentration',
        description: 'Capacite a rester attentif durant toute la seance',
        critereId: critereIdDisciplineMental,
      ),
      ElementEvaluation(
        id: 'disc_respect_consignes',
        libelle: 'Respect des consignes',
        description: 'Application des instructions de l\'encadreur',
        critereId: critereIdDisciplineMental,
      ),
      ElementEvaluation(
        id: 'disc_perseverance',
        libelle: 'Perseverance',
        description: 'Determination face a la difficulte et capacite a ne pas abandonner',
        critereId: critereIdDisciplineMental,
      ),
      ElementEvaluation(
        id: 'disc_gestion_stress',
        libelle: 'Gestion du stress',
        description: 'Maitrise des emotions en situation de pression',
        critereId: critereIdDisciplineMental,
      ),
      ElementEvaluation(
        id: 'disc_fair_play',
        libelle: 'Fair-play',
        description: 'Respect des adversaires, des partenaires et des regles',
        critereId: critereIdDisciplineMental,
      ),
      ElementEvaluation(
        id: 'disc_leadership',
        libelle: 'Leadership',
        description: 'Capacite a guider et encourager les partenaires',
        critereId: critereIdDisciplineMental,
      ),
    ],
  );

  // --- Possession globale ---

  static final CritereEvaluation _possessionGlobale = CritereEvaluation(
    id: critereIdPossessionGlobale,
    nom: 'Possession globale',
    description: 'Maitrise collective du ballon et gestion des phases de jeu',
    elements: [
      ElementEvaluation(
        id: 'poss_conservation',
        libelle: 'Conservation',
        description: 'Capacite a garder le ballon collectivement',
        critereId: critereIdPossessionGlobale,
      ),
      ElementEvaluation(
        id: 'poss_circulation',
        libelle: 'Circulation',
        description: 'Fluidite dans les echanges de balle',
        critereId: critereIdPossessionGlobale,
      ),
      ElementEvaluation(
        id: 'poss_pressing',
        libelle: 'Pressing',
        description: 'Intensite et organisation du pressing collectif',
        critereId: critereIdPossessionGlobale,
      ),
      ElementEvaluation(
        id: 'poss_recuperation',
        libelle: 'Recuperation',
        description: 'Efficacite dans la reconquete du ballon',
        critereId: critereIdPossessionGlobale,
      ),
      ElementEvaluation(
        id: 'poss_relance',
        libelle: 'Relance',
        description: 'Qualite de la sortie de balle depuis la defense',
        critereId: critereIdPossessionGlobale,
      ),
      ElementEvaluation(
        id: 'poss_jeu_profondeur',
        libelle: 'Jeu en profondeur',
        description: 'Capacite a projeter le jeu vers l\'avant rapidement',
        critereId: critereIdPossessionGlobale,
      ),
    ],
  );
}

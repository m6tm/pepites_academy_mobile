/// Types d'ateliers possibles.
enum AtelierType {
  dribble,
  passes,
  finition,
  physique,
  jeuEnSituation,
  tactique,
  gardien,
  echauffement,
  personnalise,
}

extension AtelierTypeExtension on AtelierType {
  String get label {
    switch (this) {
      case AtelierType.dribble:
        return 'Dribble';
      case AtelierType.passes:
        return 'Passes';
      case AtelierType.finition:
        return 'Finition';
      case AtelierType.physique:
        return 'Physique';
      case AtelierType.jeuEnSituation:
        return 'Jeu en situation';
      case AtelierType.tactique:
        return 'Tactique';
      case AtelierType.gardien:
        return 'Gardien';
      case AtelierType.echauffement:
        return 'Échauffement';
      case AtelierType.personnalise:
        return 'Personnalisé';
    }
  }
}

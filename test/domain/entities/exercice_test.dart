import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';

void main() {
  group('Exercice Entity', () {
    const tExercice = Exercice(
      id: '1',
      nom: 'Passement de jambes',
      description: 'Exercice de feinte',
      ordre: 1,
      statut: ExerciceStatut.cree,
      atelierId: '1',
    );

    test('should return a valid Map when toJson is called', () {
      final result = tExercice.toJson();

      final expectedMap = {
        'id': '1',
        'nom': 'Passement de jambes',
        'description': 'Exercice de feinte',
        'ordre': 1,
        'statut': 'cree',
        'atelierId': '1',
      };

      expect(result, expectedMap);
    });

    test('should return a valid Exercice when fromJson is called', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'nom': 'Passement de jambes',
        'description': 'Exercice de feinte',
        'ordre': 1,
        'statut': 'cree',
        'atelier_id': '1',
      };

      final result = Exercice.fromJson(jsonMap);

      expect(result.id, tExercice.id);
      expect(result.nom, tExercice.nom);
      expect(result.statut, tExercice.statut);
      expect(result.atelierId, tExercice.atelierId);
    });

    test('copyWith should return an updated Exercice', () {
      final updatedExercice = tExercice.copyWith(nom: 'Nouveau Nom', statut: ExerciceStatut.valide);

      expect(updatedExercice.nom, 'Nouveau Nom');
      expect(updatedExercice.statut, ExerciceStatut.valide);
      expect(updatedExercice.id, tExercice.id);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';

void main() {
  group('Atelier Entity', () {
    const tAtelier = Atelier(
      id: '1',
      nom: 'Dribble',
      icone: 'technique',
      ordre: 1,
      statut: AtelierStatut.cree,
      seanceId: '42',
    );

    test('should return a valid Map when toJson is called', () {
      final result = tAtelier.toJson();

      final expectedMap = {
        'id': '1',
        'nom': 'Dribble',
        'theme': '',
        'objectifs': '',
        'duree_minutes': null,
        'icone': 'technique',
        'ordre': 1,
        'statut': 'cree',
        'seance_id': '42',
        'categorie_ids': [],
        'configuration_evaluation': null,
      };

      expect(result, expectedMap);
    });

    test('should return a valid Atelier when fromJson is called', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'nom': 'Dribble',
        'icone': 'technique',
        'ordre': 1,
        'statut': 'cree',
        'seance_id': '42',
      };

      final result = Atelier.fromJson(jsonMap);

      expect(result.id, tAtelier.id);
      expect(result.nom, tAtelier.nom);
      expect(result.icone, tAtelier.icone);
      expect(result.seanceId, tAtelier.seanceId);
    });

    test('copyWith should return an updated Atelier', () {
      final updatedAtelier = tAtelier.copyWith(nom: 'Nouveau Nom', statut: AtelierStatut.valide);

      expect(updatedAtelier.nom, 'Nouveau Nom');
      expect(updatedAtelier.statut, AtelierStatut.valide);
      expect(updatedAtelier.id, tAtelier.id); // Should remain same
    });

    test('fromJson should ignore legacy fields if present', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'nom': 'Dribble',
        'description': 'Legacy description',
        'type': 'dribble',
        'type_custom': 'Legacy custom',
        'icone': 'technique',
        'ordre': 1,
        'statut': 'cree',
        'seance_id': '42',
      };

      final result = Atelier.fromJson(jsonMap);

      expect(result.icone, 'technique');
      expect(result.nom, 'Dribble');
    });
  });
}

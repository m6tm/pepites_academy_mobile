import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/global_stats.dart';

void main() {
  group('GlobalStats', () {
    test('doit creer des stats avec tous les champs', () {
      const stats = GlobalStats(
        nbAcademiciens: 50,
        nbEncadreurs: 10,
        nbSeancesMois: 12,
        tauxPresenceMoyen: 85.5,
        objectifsAtteints: 78.0,
        satisfactionCoachs: 92.0,
      );

      expect(stats.nbAcademiciens, 50);
      expect(stats.nbEncadreurs, 10);
      expect(stats.nbSeancesMois, 12);
      expect(stats.tauxPresenceMoyen, 85.5);
      expect(stats.objectifsAtteints, 78.0);
      expect(stats.satisfactionCoachs, 92.0);
    });

    test('doit creer des stats avec des valeurs par defaut', () {
      const stats = GlobalStats(
        nbAcademiciens: 0,
        nbEncadreurs: 0,
        nbSeancesMois: 0,
        tauxPresenceMoyen: 0.0,
        objectifsAtteints: 0.0,
        satisfactionCoachs: 0.0,
      );

      expect(stats.nbAcademiciens, 0);
      expect(stats.tauxPresenceMoyen, 0.0);
    });

    test('fromJson doit parser le JSON correctement', () {
      final json = {
        'nb_academiciens': 30,
        'nb_encadreurs': 5,
        'nb_seances_mois': 8,
        'taux_presence_moyen': 90.0,
        'objectifs_atteints': 85.0,
        'satisfaction_coachs': 88.0,
      };

      final stats = GlobalStats.fromJson(json);

      expect(stats.nbAcademiciens, 30);
      expect(stats.nbEncadreurs, 5);
      expect(stats.nbSeancesMois, 8);
      expect(stats.tauxPresenceMoyen, 90.0);
      expect(stats.objectifsAtteints, 85.0);
      expect(stats.satisfactionCoachs, 88.0);
    });

    test('fromJson doit gerer les valeurs manquantes avec des defauts', () {
      final json = <String, dynamic>{};

      final stats = GlobalStats.fromJson(json);

      expect(stats.nbAcademiciens, 0);
      expect(stats.nbEncadreurs, 0);
      expect(stats.nbSeancesMois, 0);
      expect(stats.tauxPresenceMoyen, 0.0);
      expect(stats.objectifsAtteints, 0.0);
      expect(stats.satisfactionCoachs, 0.0);
    });

    test('fromJson doit convertir les entiers en double', () {
      final json = {
        'taux_presence_moyen': 90,
        'objectifs_atteints': 85,
        'satisfaction_coachs': 88,
      };

      final stats = GlobalStats.fromJson(json);

      expect(stats.tauxPresenceMoyen, 90.0);
      expect(stats.objectifsAtteints, 85.0);
      expect(stats.satisfactionCoachs, 88.0);
    });

    test('toJson doit serialiser correctement', () {
      const stats = GlobalStats(
        nbAcademiciens: 50,
        nbEncadreurs: 10,
        nbSeancesMois: 12,
        tauxPresenceMoyen: 85.5,
        objectifsAtteints: 78.0,
        satisfactionCoachs: 92.0,
      );

      final json = stats.toJson();

      expect(json['nb_academiciens'], 50);
      expect(json['nb_encadreurs'], 10);
      expect(json['nb_seances_mois'], 12);
      expect(json['taux_presence_moyen'], 85.5);
      expect(json['objectifs_atteints'], 78.0);
      expect(json['satisfaction_coachs'], 92.0);
    });

    test('empty doit retourner des stats vides', () {
      const stats = GlobalStats.empty;

      expect(stats.nbAcademiciens, 0);
      expect(stats.nbEncadreurs, 0);
      expect(stats.nbSeancesMois, 0);
      expect(stats.tauxPresenceMoyen, 0.0);
      expect(stats.objectifsAtteints, 0.0);
      expect(stats.satisfactionCoachs, 0.0);
    });

    test('les valeurs doivent etre coherentes apres fromJson puis toJson', () {
      final originalJson = {
        'nb_academiciens': 100,
        'nb_encadreurs': 15,
        'nb_seances_mois': 20,
        'taux_presence_moyen': 95.5,
        'objectifs_atteints': 88.0,
        'satisfaction_coachs': 91.5,
      };

      final stats = GlobalStats.fromJson(originalJson);
      final newJson = stats.toJson();

      expect(newJson['nb_academiciens'], 100);
      expect(newJson['nb_encadreurs'], 15);
      expect(newJson['nb_seances_mois'], 20);
      expect(newJson['taux_presence_moyen'], 95.5);
      expect(newJson['objectifs_atteints'], 88.0);
      expect(newJson['satisfaction_coachs'], 91.5);
    });
  });
}

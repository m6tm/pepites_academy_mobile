import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/dashboard_stats.dart';
import 'package:pepites_academy_mobile/src/domain/entities/global_stats.dart';

void main() {
  group('SeasonStatus', () {
    test('doit avoir les valeurs attendues', () {
      expect(SeasonStatus.values.length, 4);
      expect(SeasonStatus.values, contains(SeasonStatus.open));
      expect(SeasonStatus.values, contains(SeasonStatus.closed));
      expect(SeasonStatus.values, contains(SeasonStatus.pending));
      expect(SeasonStatus.values, contains(SeasonStatus.none));
    });
  });

  group('Season', () {
    test('doit creer une saison avec tous les champs', () {
      final season = Season(
        id: 'season-1',
        name: 'Saison 2024-2025',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2025, 6, 30),
        status: SeasonStatus.open,
      );

      expect(season.id, 'season-1');
      expect(season.name, 'Saison 2024-2025');
      expect(season.startDate, DateTime(2024, 9, 1));
      expect(season.endDate, DateTime(2025, 6, 30));
      expect(season.status, SeasonStatus.open);
    });

    test('doit creer une saison sans date de fin', () {
      final season = Season(
        id: 'season-2',
        name: 'Saison 2025-2026',
        startDate: DateTime(2025, 9, 1),
        status: SeasonStatus.pending,
      );

      expect(season.endDate, isNull);
    });

    test('fromJson doit parser correctement le JSON', () {
      final json = {
        'id': 'season-3',
        'name': 'Saison Test',
        'start_date': '2024-09-01T00:00:00.000Z',
        'end_date': '2025-06-30T00:00:00.000Z',
        'status': 'open',
      };

      final season = Season.fromJson(json);

      expect(season.id, 'season-3');
      expect(season.name, 'Saison Test');
      expect(season.status, SeasonStatus.open);
    });

    test('fromJson doit gerer les status en francais', () {
      expect(Season.fromJson({'status': 'ouverte'}).status, SeasonStatus.open);
      expect(Season.fromJson({'status': 'fermee'}).status, SeasonStatus.closed);
      expect(
        Season.fromJson({'status': 'en_attente'}).status,
        SeasonStatus.pending,
      );
    });

    test('toJson doit serialiser correctement', () {
      final season = Season(
        id: 'season-4',
        name: 'Saison JSON',
        startDate: DateTime(2024, 9, 1),
        status: SeasonStatus.open,
      );

      final json = season.toJson();

      expect(json['id'], 'season-4');
      expect(json['name'], 'Saison JSON');
      expect(json['status'], 'open');
      expect(json['start_date'], isNotNull);
    });

    test('empty doit retourner une saison vide', () {
      final season = Season.empty();

      expect(season.id, isEmpty);
      expect(season.name, isEmpty);
      expect(season.status, SeasonStatus.none);
    });
  });

  group('DashboardStats', () {
    late GlobalStats globalStats;

    setUp(() {
      globalStats = const GlobalStats(
        nbAcademiciens: 50,
        nbEncadreurs: 10,
        nbSeancesMois: 12,
        tauxPresenceMoyen: 85.5,
        objectifsAtteints: 78.0,
        satisfactionCoachs: 92.0,
      );
    });

    test('doit creer des stats avec tous les champs', () {
      final stats = DashboardStats(
        globalStats: globalStats,
        nbSeancesTotal: 100,
        nbAnnotationsTotal: 500,
        nbPresencesTotal: 1500,
        nbSeancesJour: 2,
        nbPresencesJour: 45,
        usersByRole: {'admin': 2, 'encadreur': 8},
      );

      expect(stats.globalStats, globalStats);
      expect(stats.nbSeancesTotal, 100);
      expect(stats.nbAnnotationsTotal, 500);
      expect(stats.nbPresencesTotal, 1500);
      expect(stats.nbSeancesJour, 2);
      expect(stats.nbPresencesJour, 45);
      expect(stats.usersByRole['admin'], 2);
    });

    test('les getters doivent retourner les valeurs de globalStats', () {
      final stats = DashboardStats(globalStats: globalStats);

      expect(stats.nbAcademiciens, 50);
      expect(stats.nbEncadreurs, 10);
      expect(stats.tauxPresenceMoyen, 85.5);
    });

    test('hasActiveSeason doit retourner true si saison ouverte', () {
      final stats = DashboardStats(
        globalStats: globalStats,
        currentSeason: Season(
          id: '1',
          name: 'Test',
          startDate: DateTime.now(),
          status: SeasonStatus.open,
        ),
      );

      expect(stats.hasActiveSeason, isTrue);
    });

    test('hasActiveSeason doit retourner false si pas de saison', () {
      final stats = DashboardStats(globalStats: globalStats);

      expect(stats.hasActiveSeason, isFalse);
    });

    test('fromJson doit parser le JSON complet', () {
      final json = {
        'global_stats': {
          'nb_academiciens': 30,
          'nb_encadreurs': 5,
          'nb_seances_mois': 8,
          'taux_presence_moyen': 90.0,
          'objectifs_atteints': 85.0,
          'satisfaction_coachs': 88.0,
        },
        'nb_seances_total': 50,
        'nb_annotations_total': 200,
        'nb_presences_total': 600,
        'nb_seances_jour': 1,
        'nb_presences_jour': 25,
        'current_season': {
          'id': 's1',
          'name': 'Saison 2024',
          'start_date': '2024-09-01T00:00:00.000Z',
          'status': 'open',
        },
        'users_by_role': {'admin': 1, 'encadreur': 4},
        'last_updated_at': '2024-10-15T10:00:00.000Z',
      };

      final stats = DashboardStats.fromJson(json);

      expect(stats.nbAcademiciens, 30);
      expect(stats.nbEncadreurs, 5);
      expect(stats.nbSeancesTotal, 50);
      expect(stats.nbAnnotationsTotal, 200);
      expect(stats.nbPresencesTotal, 600);
      expect(stats.nbSeancesJour, 1);
      expect(stats.nbPresencesJour, 25);
      expect(stats.hasActiveSeason, isTrue);
      expect(stats.usersByRole['admin'], 1);
    });

    test('toJson doit serialiser correctement', () {
      final stats = DashboardStats(
        globalStats: globalStats,
        nbSeancesTotal: 100,
        nbAnnotationsTotal: 500,
        nbPresencesTotal: 1500,
        nbSeancesJour: 2,
        nbPresencesJour: 45,
        usersByRole: {'admin': 2},
      );

      final json = stats.toJson();

      expect(json['global_stats'], isNotNull);
      expect(json['nb_seances_total'], 100);
      expect(json['nb_annotations_total'], 500);
      expect(json['nb_presences_total'], 1500);
      expect(json['nb_seances_jour'], 2);
      expect(json['nb_presences_jour'], 45);
      expect(json['users_by_role'], isNotNull);
    });

    test('empty doit retourner des stats vides', () {
      const stats = DashboardStats.empty;

      expect(stats.globalStats, GlobalStats.empty);
      expect(stats.nbSeancesTotal, 0);
      expect(stats.nbAnnotationsTotal, 0);
      expect(stats.nbPresencesTotal, 0);
      expect(stats.currentSeason, isNull);
    });

    test('copyWith doit copier et modifier les champs', () {
      final original = DashboardStats(
        globalStats: globalStats,
        nbSeancesTotal: 100,
      );

      final copied = original.copyWith(nbSeancesTotal: 200);

      expect(copied.nbSeancesTotal, 200);
      expect(copied.globalStats, globalStats);
    });

    test('copyWith avec clearSeason doit effacer la saison', () {
      final original = DashboardStats(
        globalStats: globalStats,
        currentSeason: Season(
          id: '1',
          name: 'Test',
          startDate: DateTime.now(),
          status: SeasonStatus.open,
        ),
      );

      final copied = original.copyWith(clearSeason: true);

      expect(copied.currentSeason, isNull);
    });
  });
}

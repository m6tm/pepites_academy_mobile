import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pepites_academy_mobile/src/infrastructure/network/api_endpoints.dart';

/// Test d'intégration pour vérifier l'inscription d'un académicien/encadreur avec photo.
///
/// Usage:
///   flutter test test/api_sync_test.dart
///
/// Prérequis:
///   - Le serveur backend doit être démarré
///   - Un utilisateur doit être connecté (token en cache)

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  String? accessToken;

  setUpAll(() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');

    debugPrint('=' * 60);
    debugPrint('Test de création académicien/encadreur avec photo');
    debugPrint('=' * 60);
    debugPrint('[INFO] Base URL: ${ApiEndpoints.baseUrl}');
    debugPrint(
      '[INFO] Token présent: ${accessToken != null && accessToken!.isNotEmpty}',
    );

    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  });

  test('Vérification de la connexion au serveur', () async {
    final healthResponse = await dio.get('/health');
    debugPrint('[OK] Serveur accessible: ${healthResponse.data}');
    expect(healthResponse.statusCode, 200);
  });

  test('Création d\'un académicien SANS photo', () async {
    final academicienData = {
      'nom': 'TestNom',
      'prenom': 'TestPrenom',
      'date_naissance': '2015-06-15',
      'telephone_parent': '0612345678',
      'poste_football_id': '1',
      'niveau_scolaire_id': '1',
      'pied_fort': 'Droitier',
    };

    debugPrint('[INFO] Payload: $academicienData');

    try {
      final response = await dio.post(
        ApiEndpoints.academiciens,
        data: academicienData,
      );
      debugPrint('[OK] Académicien créé: ${response.statusCode}');
      debugPrint('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      debugPrint('[ERREUR] ${e.type}: ${e.message}');
      debugPrint('[RESPONSE] ${e.response?.data}');
      fail('Échec de la création: ${e.response?.data}');
    }
  });

  test('Création d\'un académicien AVEC photo base64', () async {
    const photoBase64 =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';

    final academicienDataWithPhoto = {
      'nom': 'TestAvecPhoto',
      'prenom': 'TestPrenom',
      'date_naissance': '2014-03-20',
      'telephone_parent': '0698765432',
      'poste_football_id': '2',
      'niveau_scolaire_id': '2',
      'pied_fort': 'Gaucher',
      'photo_base64': photoBase64,
    };

    debugPrint(
      '[INFO] Payload avec photo_base64 (${photoBase64.length} chars)',
    );

    try {
      final response = await dio.post(
        ApiEndpoints.academiciens,
        data: academicienDataWithPhoto,
      );
      debugPrint('[OK] Académicien avec photo créé: ${response.statusCode}');
      debugPrint('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      debugPrint('[ERREUR] ${e.type}: ${e.message}');
      debugPrint('[RESPONSE] ${e.response?.data}');
      fail('Échec de la création avec photo: ${e.response?.data}');
    }
  });

  test('Création d\'un encadreur SANS photo', () async {
    final encadreurData = {
      'nom': 'EncadreurTest',
      'prenom': 'PrenomTest',
      'email':
          'encadreur.test${DateTime.now().millisecondsSinceEpoch}@test.com',
      'telephone': '0611223344',
      'specialite': 'Technique',
      'role': 'encadreur',
    };

    debugPrint('[INFO] Payload: $encadreurData');

    try {
      final response = await dio.post(
        ApiEndpoints.encadreurs,
        data: encadreurData,
      );
      debugPrint('[OK] Encadreur créé: ${response.statusCode}');
      debugPrint('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      debugPrint('[ERREUR] ${e.type}: ${e.message}');
      debugPrint('[RESPONSE] ${e.response?.data}');
      fail('Échec de la création encadreur: ${e.response?.data}');
    }
  });

  test('Création d\'un encadreur AVEC photo base64', () async {
    const photoBase64 =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';

    final encadreurDataWithPhoto = {
      'nom': 'EncadreurAvecPhoto',
      'prenom': 'PrenomTest',
      'email':
          'encadreur.photo${DateTime.now().millisecondsSinceEpoch}@test.com',
      'telephone': '0655443322',
      'specialite': 'Tactique',
      'role': 'encadreur',
      'photo_base64': photoBase64,
    };

    debugPrint('[INFO] Payload avec photo_base64');

    try {
      final response = await dio.post(
        ApiEndpoints.encadreurs,
        data: encadreurDataWithPhoto,
      );
      debugPrint('[OK] Encadreur avec photo créé: ${response.statusCode}');
      debugPrint('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      debugPrint('[ERREUR] ${e.type}: ${e.message}');
      debugPrint('[RESPONSE] ${e.response?.data}');
      fail('Échec de la création encadreur avec photo: ${e.response?.data}');
    }
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/src/infrastructure/network/api_endpoints.dart';

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

    print('=' * 60);
    print('Test de création académicien/encadreur avec photo');
    print('=' * 60);
    print('[INFO] Base URL: ${ApiEndpoints.baseUrl}');
    print(
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
    print('[OK] Serveur accessible: ${healthResponse.data}');
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

    print('[INFO] Payload: $academicienData');

    try {
      final response = await dio.post(
        ApiEndpoints.academiciens,
        data: academicienData,
      );
      print('[OK] Académicien créé: ${response.statusCode}');
      print('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      print('[ERREUR] ${e.type}: ${e.message}');
      print('[RESPONSE] ${e.response?.data}');
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

    print('[INFO] Payload avec photo_base64 (${photoBase64.length} chars)');

    try {
      final response = await dio.post(
        ApiEndpoints.academiciens,
        data: academicienDataWithPhoto,
      );
      print('[OK] Académicien avec photo créé: ${response.statusCode}');
      print('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      print('[ERREUR] ${e.type}: ${e.message}');
      print('[RESPONSE] ${e.response?.data}');
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

    print('[INFO] Payload: $encadreurData');

    try {
      final response = await dio.post(
        ApiEndpoints.encadreurs,
        data: encadreurData,
      );
      print('[OK] Encadreur créé: ${response.statusCode}');
      print('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      print('[ERREUR] ${e.type}: ${e.message}');
      print('[RESPONSE] ${e.response?.data}');
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

    print('[INFO] Payload avec photo_base64');

    try {
      final response = await dio.post(
        ApiEndpoints.encadreurs,
        data: encadreurDataWithPhoto,
      );
      print('[OK] Encadreur avec photo créé: ${response.statusCode}');
      print('[DATA] ${response.data}');
      expect(response.statusCode, 201);
    } on DioException catch (e) {
      print('[ERREUR] ${e.type}: ${e.message}');
      print('[RESPONSE] ${e.response?.data}');
      fail('Échec de la création encadreur avec photo: ${e.response?.data}');
    }
  });
}

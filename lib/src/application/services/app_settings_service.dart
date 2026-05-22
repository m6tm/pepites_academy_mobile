import '../../infrastructure/network/dio_client.dart';
import 'app_preferences.dart';

/// Service applicatif pour la gestion des parametres globaux de l'application.
class AppSettingsService {
  final DioClient _dioClient;
  final AppPreferences _preferences;

  AppSettingsService({
    required DioClient dioClient,
    required AppPreferences preferences,
  })  : _dioClient = dioClient,
        _preferences = preferences;

  /// Retourne l'etat local de l'autorisation des emails dupliques.
  Future<bool> getAllowDuplicateEmails() {
    return _preferences.getAllowDuplicateEmails();
  }

  /// Active ou desactive l'autorisation des emails dupliques,
  /// synchronise la modification avec le backend si en ligne.
  Future<void> setAllowDuplicateEmails(bool enabled) async {
    await _preferences.setAllowDuplicateEmails(enabled);

    try {
      final result = await _dioClient.put<dynamic>(
        '/settings',
        data: {'allow_duplicate_emails': enabled},
      );
      result.fold(
        (failure) {
          // ignore: avoid_print
          print('[AppSettings] Echec sync backend: ${failure.message}');
        },
        (response) {
          // ignore: avoid_print
          print('[AppSettings] Sync backend reussie: $response');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AppSettings] Exception sync backend: $e');
    }
  }

  /// Charge les parametres depuis le backend et met a jour le cache local.
  Future<void> fetchFromBackend() async {
    try {
      final result = await _dioClient.get<dynamic>('/settings');
      await result.fold(
        (failure) async {
          // ignore: avoid_print
          print('[AppSettings] Echec fetch backend: ${failure.message}');
        },
        (data) async {
          if (data is Map<String, dynamic>) {
            final allow = data['allow_duplicate_emails'] as bool? ?? false;
            await _preferences.setAllowDuplicateEmails(allow);
            // ignore: avoid_print
            print('[AppSettings] Fetch backend reussi: allow_duplicate_emails=$allow');
          }
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AppSettings] Exception fetch backend: $e');
    }
  }
}

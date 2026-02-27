import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/entities/biometric_preferences.dart';

/// Resultat de la verification de la disponibilite biometrique.
enum BiometricAvailability {
  /// La biometrie est disponible et configuree.
  available,

  /// Aucun materiel biometrique sur l'appareil.
  noHardware,

  /// Materiel disponible mais aucune biometrie configuree.
  notEnrolled,

  /// La biometrie est desactivee par l'utilisateur ou l'administrateur.
  disabled,

  /// Erreur inconnue lors de la verification.
  unknown,
}

/// Type de biometrie supportee.
enum BiometricType {
  /// Empreinte digitale.
  fingerprint,

  /// Reconnaissance faciale (Face ID).
  faceId,

  /// Reconnaissance irienne (Iris).
  iris,

  /// Type inconnu ou non supporte.
  unknown,
}

/// Service gerant l'authentification biometrique.
/// Centralise la logique de verification, d'authentification et de synchronisation.
class BiometricService {
  final local_auth.LocalAuthentication _localAuth;
  final SecurityRepository _securityRepository;
  final Future<bool> Function() _getBiometricEnabled;
  final Future<void> Function(bool) _setBiometricEnabled;

  BiometricService({
    required local_auth.LocalAuthentication localAuth,
    required SecurityRepository securityRepository,
    required Future<bool> Function() getBiometricEnabled,
    required Future<void> Function(bool) setBiometricEnabled,
  }) : _localAuth = localAuth,
       _securityRepository = securityRepository,
       _getBiometricEnabled = getBiometricEnabled,
       _setBiometricEnabled = setBiometricEnabled;

  /// Verifie si l'appareil supporte l'authentification biometrique.
  Future<BiometricAvailability> checkAvailability() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        return BiometricAvailability.noHardware;
      }

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        // Verifier si c'est parce qu'aucune biometrie n'est configuree
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        if (availableBiometrics.isEmpty) {
          return BiometricAvailability.notEnrolled;
        }
        return BiometricAvailability.disabled;
      }

      return BiometricAvailability.available;
    } catch (e) {
      return BiometricAvailability.unknown;
    }
  }

  /// Recupere les types de biometrie disponibles sur l'appareil.
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
    try {
      final types = <BiometricType>[];
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      for (final type in availableBiometrics) {
        switch (type) {
          case local_auth.BiometricType.fingerprint:
            types.add(BiometricType.fingerprint);
            break;
          case local_auth.BiometricType.face:
            types.add(BiometricType.faceId);
            break;
          case local_auth.BiometricType.iris:
            types.add(BiometricType.iris);
            break;
          case local_auth.BiometricType.strong:
          case local_auth.BiometricType.weak:
            // Types generiques, on ne les ajoute pas explicitement
            break;
        }
      }

      return types.isEmpty ? [BiometricType.unknown] : types;
    } catch (e) {
      return [BiometricType.unknown];
    }
  }

  /// Recupere le type de biometrie principal pour l'affichage.
  Future<String> getPrimaryBiometricTypeName() async {
    final types = await getAvailableBiometricTypes();
    if (types.isEmpty || types.first == BiometricType.unknown) {
      return 'biometrie';
    }

    switch (types.first) {
      case BiometricType.fingerprint:
        return 'empreinte digitale';
      case BiometricType.faceId:
        return 'reconnaissance faciale';
      case BiometricType.iris:
        return 'reconnaissance irienne';
      case BiometricType.unknown:
        return 'biometrie';
    }
  }

  /// Recupere l'identifiant unique de l'appareil.
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (await _isAndroid()) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      return 'unknown';
    }
  }

  /// Verifie si l'appareil est sous Android.
  Future<bool> _isAndroid() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      await deviceInfo.androidInfo;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Authentifie l'utilisateur avec la biometrie.
  /// Retourne true si l'authentification a reussi.
  Future<(bool, String?)> authenticate({
    String localizedReason = 'Veuillez vous authentifier pour continuer',
  }) async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const local_auth.AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (didAuthenticate) {
        return (true, null);
      }

      return (false, 'Authentification annulee ou echouee');
    } on PlatformException catch (e) {
      final errorMessage = _mapErrorCodeToMessage(e.code);
      return (false, errorMessage);
    } catch (e) {
      return (false, 'Erreur inattendue: ${e.toString()}');
    }
  }

  /// Active l'authentification biometrique pour l'utilisateur.
  /// Effectue une authentification prealable, puis synchronise avec le backend.
  Future<(bool, String?)> enableBiometric() async {
    // Verifier la disponibilite
    final availability = await checkAvailability();
    if (availability != BiometricAvailability.available) {
      return (false, _mapAvailabilityToMessage(availability));
    }

    // Authentifier l'utilisateur pour confirmer son identite
    final (authenticated, authError) = await authenticate(
      localizedReason:
          'Authentifiez-vous pour activer la connexion biometrique',
    );

    if (!authenticated) {
      return (false, authError ?? 'Authentification echouee');
    }

    // Recuperer les informations de l'appareil
    final biometricTypes = await getAvailableBiometricTypes();
    final deviceId = await getDeviceId();
    final biometricType = _mapBiometricTypeToString(
      biometricTypes.isNotEmpty ? biometricTypes.first : BiometricType.unknown,
    );

    // Synchroniser avec le backend
    final failure = await _securityRepository.updateBiometricPreferences(
      biometricEnabled: true,
      biometricType: biometricType,
      deviceId: deviceId,
    );

    if (failure != null) {
      return (false, 'Erreur de synchronisation avec le serveur');
    }

    // Sauvegarder localement
    await _setBiometricEnabled(true);

    return (true, null);
  }

  /// Desactive l'authentification biometrique.
  Future<(bool, String?)> disableBiometric() async {
    // Synchroniser avec le backend
    final failure = await _securityRepository.disableBiometric();

    if (failure != null) {
      return (false, 'Erreur de synchronisation avec le serveur');
    }

    // Sauvegarder localement
    await _setBiometricEnabled(false);

    return (true, null);
  }

  /// Verifie si la biométrie est activée localement.
  Future<bool> isBiometricEnabled() async {
    return _getBiometricEnabled();
  }

  /// Recupere les preferences biometriques depuis le backend.
  Future<(BiometricPreferences?, String?)> getBiometricPreferences() async {
    final (failure, data) = await _securityRepository.getBiometricPreferences();

    if (failure != null) {
      return (null, 'Erreur de recuperation des preferences');
    }

    if (data != null) {
      return (BiometricPreferences.fromJson(data), null);
    }

    return (const BiometricPreferences(), null);
  }

  /// Synchronise l'etat local avec le backend.
  /// Utile au demarrage de l'application.
  Future<void> syncWithBackend() async {
    final (preferences, _) = await getBiometricPreferences();
    if (preferences != null) {
      await _setBiometricEnabled(preferences.biometricEnabled);
    }
  }

  /// Mappe un code d'erreur en message utilisateur.
  String _mapErrorCodeToMessage(String code) {
    switch (code) {
      case 'notAvailable':
        return 'La biometrie n\'est pas disponible sur cet appareil';
      case 'notEnrolled':
        return 'Aucune biometrie configuree. Veuillez enregistrer une empreinte'
            ' ou un visage dans les parametres de l\'appareil';
      case 'lockedOut':
        return 'Trop de tentatives. Veuillez reessayer plus tard';
      case 'permanentlyLockedOut':
        return 'Biometrie desactivee. Veuillez deverrouiller votre appareil'
            ' avec le code PIN/mot de passe';
      case 'passcodeNotSet':
        return 'Veuillez configurer un code PIN sur votre appareil';
      default:
        return 'Erreur d\'authentification: $code';
    }
  }

  /// Mappe une disponibilite en message utilisateur.
  String _mapAvailabilityToMessage(BiometricAvailability availability) {
    switch (availability) {
      case BiometricAvailability.available:
        return 'Disponible';
      case BiometricAvailability.noHardware:
        return 'Cet appareil ne supporte pas l\'authentification biometrique';
      case BiometricAvailability.notEnrolled:
        return 'Aucune biometrie configuree. Veuillez enregistrer une empreinte'
            ' ou un visage dans les parametres de l\'appareil';
      case BiometricAvailability.disabled:
        return 'L\'authentification biometrique est desactivee';
      case BiometricAvailability.unknown:
        return 'Impossible de verifier la disponibilite biometrique';
    }
  }

  /// Mappe un type biometrique en chaine de caracteres.
  String _mapBiometricTypeToString(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'fingerprint';
      case BiometricType.faceId:
        return 'face_id';
      case BiometricType.iris:
        return 'iris';
      case BiometricType.unknown:
        return 'unknown';
    }
  }
}

import 'dart:async' as async;
import 'dart:io';

import '../../domain/exceptions/exceptions.dart';

/// Utilitaire pour mapper les erreurs techniques en exceptions du domaine.
class ExceptionMapper {
  /// Convertit une erreur technique en [DomainException].
  static DomainException map(dynamic error) {
    if (error is DomainException) {
      return error;
    }

    // Gestion des erreurs réseau (Dart standard)
    if (error is SocketException) {
      return const NetworkException(
        "Pas de connexion internet. Vérifiez votre réseau.",
      );
    }

    if (error is async.TimeoutException) {
      return const TimeoutException("Le serveur met trop de temps à répondre.");
    }

    if (error is HttpException) {
      return const ServerException("Erreur de protocole HTTP.");
    }

    if (error is FormatException) {
      return const RequestException(
        "Format de données invalide.",
        details: "JSON malformé ou type incorrect.",
      );
    }

    // TODO: Ajouter la gestion des erreurs Dio/Http ici une fois les dépendances ajoutées.

    // Erreur inconnue par défaut
    return UnknownException(
      "Une erreur inattendue est survenue (technique).",
      error.toString(),
    );
  }

  /// Retourne un message utilisateur convivial à partir d'une exception.
  static String getUserMessage(dynamic error) {
    if (error is DomainException) {
      return error.message;
    }
    // Si l'erreur n'est pas une DomainException, on la mappe d'abord
    return map(error).message;
  }
}

import 'dart:async' as async;
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/exceptions/exceptions.dart';

/// Utilitaire pour mapper les erreurs techniques en exceptions du domaine.
class ExceptionMapper {
  /// Convertit une erreur technique en [DomainException].
  static DomainException map(dynamic error) {
    if (error is DomainException) {
      return error;
    }

    if (error is SocketException) {
      return const NetworkException(
        "Pas de connexion internet. Verifiez votre reseau.",
        'exceptionNetworkCheck',
      );
    }

    if (error is async.TimeoutException) {
      return const TimeoutException(
        "Le serveur met trop de temps a repondre.",
        'exceptionTimeoutServer',
      );
    }

    if (error is HttpException) {
      return const ServerException(
        "Erreur de protocole HTTP.",
        null,
        'exceptionServerHttp',
      );
    }

    if (error is FormatException) {
      return const RequestException(
        "Format de donnees invalide.",
        details: "JSON malforme ou type incorrect.",
        messageKey: 'exceptionRequestBad',
      );
    }

    // TODO: Ajouter la gestion des erreurs Dio/Http ici une fois les dependances ajoutees.

    return UnknownException(
      "Une erreur inattendue est survenue (technique).",
      error.toString(),
      'exceptionUnknownTechnical',
    );
  }

  /// Retourne un message utilisateur traduit a partir d'une exception.
  /// Utilise [AppLocalizations] si un [BuildContext] est fourni.
  static String getUserMessage(dynamic error, [BuildContext? context]) {
    final domainError = error is DomainException ? error : map(error);
    if (context != null) {
      final localized = resolveMessage(domainError, context);
      if (localized != null) return localized;
    }
    return domainError.message;
  }

  /// Resout le message traduit d'une [DomainException] via [AppLocalizations].
  /// Retourne null si la cle n'est pas trouvee.
  static String? resolveMessage(DomainException error, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || error.messageKey == null) return null;

    final resolvers = <String, String>{
      'exceptionNetworkDefault': l10n.exceptionNetworkDefault,
      'exceptionNetworkCheck': l10n.exceptionNetworkCheck,
      'exceptionTimeoutDefault': l10n.exceptionTimeoutDefault,
      'exceptionTimeoutServer': l10n.exceptionTimeoutServer,
      'exceptionServerDefault': l10n.exceptionServerDefault,
      'exceptionServerHttp': l10n.exceptionServerHttp,
      'exceptionRequestBad': l10n.exceptionRequestBad,
      'exceptionNotFoundDefault': l10n.exceptionNotFoundDefault,
      'exceptionAuthDefault': l10n.exceptionAuthDefault,
      'exceptionPermissionDefault': l10n.exceptionPermissionDefault,
      'exceptionCacheDefault': l10n.exceptionCacheDefault,
      'exceptionUnknownDefault': l10n.exceptionUnknownDefault,
      'exceptionUnknownTechnical': l10n.exceptionUnknownTechnical,
    };

    return resolvers[error.messageKey];
  }
}

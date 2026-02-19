/// Classe de base pour toutes les exceptions du domaine.
/// [messageKey] permet de resoudre la traduction cote presentation via AppLocalizations.
/// [message] sert de fallback si la cle n'est pas resolue.
abstract class DomainException implements Exception {
  final String message;
  final String? messageKey;
  final String? code;
  final dynamic details;

  const DomainException(
    this.message, {
    this.messageKey,
    this.code,
    this.details,
  });

  @override
  String toString() => 'DomainException: $message (Code: $code)';
}

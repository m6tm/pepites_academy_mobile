/// Classe de base pour toutes les exceptions du domaine.
abstract class DomainException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const DomainException(this.message, {this.code, this.details});

  @override
  String toString() => 'DomainException: $message (Code: $code)';
}

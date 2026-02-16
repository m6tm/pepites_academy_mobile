/// Represente l'etat de la connexion reseau du peripherique.
enum ConnectivityStatus {
  /// Connexion disponible (Wi-Fi ou donnees mobiles).
  connected,

  /// Aucune connexion reseau detectee.
  disconnected,

  /// Synchronisation des donnees en cours.
  syncing,
}

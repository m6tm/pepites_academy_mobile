/// Résultat d'une tentative de résilience sur une mutation.
sealed class ResilienceResult<T> {
  const ResilienceResult();
}

/// La requête a été exécutée avec succès (éventuellement après reconstruction du payload).
class ResilienceSuccess<T> extends ResilienceResult<T> {
  final T data;
  final bool wasRebuilt;

  const ResilienceSuccess(this.data, {this.wasRebuilt = false});
}

/// La requête n'a pas pu être exécutée immédiatement mais a été remise en file d'attente.
class ResilienceEnqueued<T> extends ResilienceResult<T> {
  const ResilienceEnqueued();
}

/// La résilience a échoué (aucune donnée source, erreur serveur, etc.).
class ResilienceFailure<T> extends ResilienceResult<T> {
  final String message;

  const ResilienceFailure(this.message);
}

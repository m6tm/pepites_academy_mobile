import 'package:flutter/material.dart';

/// Mixin fournissant une interface standard pour la gestion
/// des messages d'erreur et de succès dans les ChangeNotifier.
mixin MessageStateMixin on ChangeNotifier {
  String? get errorMessage;
  String? get successMessage;
  void clearMessages();
}

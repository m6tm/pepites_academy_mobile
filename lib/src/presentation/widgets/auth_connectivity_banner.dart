import 'package:flutter/material.dart';
import '../state/connectivity_state.dart';
import '../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';

/// Un bandeau discret affiché en haut des pages d'authentification 
/// lorsqu'il n'y a pas de connexion internet.
class AuthConnectivityBanner extends StatelessWidget {
  const AuthConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityState = DependencyInjection.connectivityState;
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: connectivityState,
      builder: (context, _) {
        if (connectivityState.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.red.shade800,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.noInternetConnection,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

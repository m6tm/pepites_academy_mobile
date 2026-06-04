# Variables
FLUTTER = flutter
DART = dart
BUILD_RUNNER = $(DART) run build_runner

# Environnement cible (local | staging | production). Utilisation : make run ENV=staging
ENV ?= local
DART_DEFINE_ENV = --dart-define=ENV=$(ENV)

.PHONY: help install clean get upgrade outdated analyze format format-check test test-coverage \
        build-runner build-runner-watch build-runner-clean \
        run run-debug run-release run-profile \
        run-local run-staging run-prod run-prod-release \
        build-apk build-apk-release build-appbundle build-ios build-ipa \
        build-apk-local build-apk-staging build-apk-prod \
        build-appbundle-prod build-ios-prod build-ipa-prod \
        icons splash l10n \
        devices doctor reset pods

help:
	@echo "Commandes disponibles :"
	@echo ""
	@echo "Dependances :"
	@echo "  make install             - Installe les dependances (flutter pub get)"
	@echo "  make get                 - Alias pour install"
	@echo "  make upgrade             - Met a jour les dependances"
	@echo "  make outdated            - Liste les dependances obsoletes"
	@echo ""
	@echo "Qualite du code :"
	@echo "  make analyze             - Analyse statique du code (flutter analyze)"
	@echo "  make format              - Formate le code Dart"
	@echo "  make format-check        - Verifie le formatage sans modifier"
	@echo ""
	@echo "Tests :"
	@echo "  make test                - Execute les tests unitaires"
	@echo "  make test-coverage       - Execute les tests avec rapport de couverture"
	@echo ""
	@echo "Code generation (build_runner) :"
	@echo "  make build-runner        - Genere le code (freezed, json_serializable)"
	@echo "  make build-runner-watch  - Regenere le code en continu"
	@echo "  make build-runner-clean  - Nettoie et regenere le code"
	@echo ""
	@echo "Execution :"
	@echo "  make run                 - Lance l'application (debug, local par defaut)"
	@echo "  make run ENV=staging     - Lance l'application en mode debug sur staging"
	@echo "  make run-debug           - Lance l'application en mode debug"
	@echo "  make run-profile         - Lance l'application en mode profile"
	@echo "  make run-release         - Lance l'application en mode release"
	@echo "  make run-local           - Lance l'application en local (debug)"
	@echo "  make run-staging         - Lance l'application en staging (debug)"
	@echo "  make run-prod            - Lance l'application en production (debug)"
	@echo "  make run-prod-release    - Lance l'application en production (release)"
	@echo ""
	@echo "Build avec environnement :"
	@echo "  make build-apk-local     - APK debug (local)"
	@echo "  make build-apk-staging   - APK debug (staging)"
	@echo "  make build-apk-prod      - APK release (production)"
	@echo "  make build-appbundle-prod- App Bundle production"
	@echo "  make build-ios-prod      - Build iOS production (no codesign)"
	@echo "  make build-ipa-prod      - IPA production (App Store)"
	@echo ""
	@echo "Build :"
	@echo "  make build-apk           - Construit un APK debug"
	@echo "  make build-apk-release   - Construit un APK de release"
	@echo "  make build-appbundle     - Construit un App Bundle pour le Play Store"
	@echo "  make build-ios           - Construit l'app iOS (no codesign)"
	@echo "  make build-ipa           - Construit l'IPA pour l'App Store"
	@echo ""
	@echo "Assets :"
	@echo "  make icons               - Genere les icones de l'application"
	@echo "  make splash              - Genere les splash screens"
	@echo "  make l10n                - Genere les fichiers de localisation"
	@echo ""
	@echo "Utilitaires :"
	@echo "  make clean               - Nettoie les artefacts de build"
	@echo "  make reset               - Nettoie et reinstalle les dependances"
	@echo "  make doctor              - Diagnostique l'environnement Flutter"
	@echo "  make devices             - Liste les appareils connectes"
	@echo "  make pods                - Reinstalle les pods iOS"

# Dependances
install:
	$(FLUTTER) pub get

get: install

upgrade:
	$(FLUTTER) pub upgrade

outdated:
	$(FLUTTER) pub outdated

# Qualite du code
analyze:
	$(FLUTTER) analyze

format:
	$(DART) format lib test

format-check:
	$(DART) format --set-exit-if-changed lib test

# Tests
test:
	$(FLUTTER) test

test-coverage:
	$(FLUTTER) test --coverage

# Code generation
build-runner:
	$(BUILD_RUNNER) build --delete-conflicting-outputs

build-runner-watch:
	$(BUILD_RUNNER) watch --delete-conflicting-outputs

build-runner-clean:
	$(BUILD_RUNNER) clean
	$(BUILD_RUNNER) build --delete-conflicting-outputs

# Execution
run:
	$(FLUTTER) run $(DART_DEFINE_ENV)

run-debug:
	$(FLUTTER) run --debug $(DART_DEFINE_ENV)

run-profile:
	$(FLUTTER) run --profile $(DART_DEFINE_ENV)

run-release:
	$(FLUTTER) run --release $(DART_DEFINE_ENV)

run-local:
	$(FLUTTER) run --debug --dart-define=ENV=local

run-staging:
	$(FLUTTER) run --debug --dart-define=ENV=staging

run-prod:
	$(FLUTTER) run --debug --dart-define=ENV=production

run-prod-release:
	$(FLUTTER) run --release --dart-define=ENV=production

# Build
build-apk:
	$(FLUTTER) build apk --debug $(DART_DEFINE_ENV)

build-apk-release:
	$(FLUTTER) build apk --release $(DART_DEFINE_ENV)

build-appbundle:
	$(FLUTTER) build appbundle --release $(DART_DEFINE_ENV)

build-ios:
	$(FLUTTER) build ios --no-codesign $(DART_DEFINE_ENV)

build-ipa:
	$(FLUTTER) build ipa --release $(DART_DEFINE_ENV)

build-apk-local:
	$(FLUTTER) build apk --debug --dart-define=ENV=local

build-apk-staging:
	$(FLUTTER) build apk --debug --dart-define=ENV=staging

build-apk-prod:
	$(FLUTTER) build apk --release --dart-define=ENV=production

build-appbundle-prod:
	$(FLUTTER) build appbundle --release --dart-define=ENV=production

build-ios-prod:
	$(FLUTTER) build ios --no-codesign --dart-define=ENV=production

build-ipa-prod:
	$(FLUTTER) build ipa --release --dart-define=ENV=production

# Assets
icons:
	$(DART) run flutter_launcher_icons

splash:
	$(DART) run flutter_native_splash:create

l10n:
	$(FLUTTER) gen-l10n

# Utilitaires
clean:
	$(FLUTTER) clean

reset: clean install

doctor:
	$(FLUTTER) doctor -v

devices:
	$(FLUTTER) devices

pods:
	cd ios && pod deintegrate && pod install --repo-update

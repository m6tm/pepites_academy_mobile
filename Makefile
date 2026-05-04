# Variables
FLUTTER = flutter
DART = dart
BUILD_RUNNER = $(DART) run build_runner

.PHONY: help install clean get upgrade outdated analyze format format-check test test-coverage \
        build-runner build-runner-watch build-runner-clean \
        run run-debug run-release run-profile \
        build-apk build-apk-release build-appbundle build-ios build-ipa \
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
	@echo "  make run                 - Lance l'application (debug)"
	@echo "  make run-debug           - Lance l'application en mode debug"
	@echo "  make run-profile         - Lance l'application en mode profile"
	@echo "  make run-release         - Lance l'application en mode release"
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
	$(FLUTTER) run

run-debug:
	$(FLUTTER) run --debug

run-profile:
	$(FLUTTER) run --profile

run-release:
	$(FLUTTER) run --release

# Build
build-apk:
	$(FLUTTER) build apk --debug

build-apk-release:
	$(FLUTTER) build apk --release

build-appbundle:
	$(FLUTTER) build appbundle --release

build-ios:
	$(FLUTTER) build ios --no-codesign

build-ipa:
	$(FLUTTER) build ipa --release

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

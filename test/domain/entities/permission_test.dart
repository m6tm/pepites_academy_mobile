import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/permission.dart';
import 'package:pepites_academy_mobile/src/domain/entities/role.dart';

void main() {
  group('Permission Tests', () {
    test('Permission.exerciceValidate doit exister', () {
      expect(Permission.exerciceValidate, isNotNull);
      expect(Permission.exerciceValidate.id, 'exercice:validate');
    });

    test('Admin doit avoir exerciceValidate', () {
      expect(Role.admin.hasPermission(Permission.exerciceValidate), isTrue);
    });

    test('EncadreurChef doit avoir exerciceValidate', () {
      expect(Role.encadreurChef.hasPermission(Permission.exerciceValidate), isTrue);
    });

    test('Encadreur ne doit PAS avoir exerciceValidate', () {
      expect(Role.encadreur.hasPermission(Permission.exerciceValidate), isFalse);
    });

    test('Visiteur ne doit PAS avoir exerciceValidate', () {
      expect(Role.visiteur.hasPermission(Permission.exerciceValidate), isFalse);
    });

    test('tryFromId doit fonctionner pour exerciceValidate', () {
      expect(Permission.tryFromId('exercice:validate'), Permission.exerciceValidate);
      expect(Permission.tryFromId('EXERCICE:VALIDATE'), Permission.exerciceValidate);
    });
  });
}

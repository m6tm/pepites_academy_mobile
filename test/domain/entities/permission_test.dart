import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/permission.dart';
import 'package:pepites_academy_mobile/src/domain/entities/role.dart';

void main() {
  group('Permission Tests', () {
    test('Permission.exerciceValidate doit exister', () {
      expect(Permission.exerciceValidate, isNotNull);
      expect(Permission.exerciceValidate.id, 'exercice:validate');
    });

    test('Permission.atelierApply doit exister', () {
      expect(Permission.atelierApply, isNotNull);
      expect(Permission.atelierApply.id, 'atelier:apply');
    });

    test('Permission.exerciceApply doit exister', () {
      expect(Permission.exerciceApply, isNotNull);
      expect(Permission.exerciceApply.id, 'exercice:apply');
    });

    test('Admin doit avoir atelierApply et exerciceApply', () {
      expect(Role.admin.hasPermission(Permission.atelierApply), isTrue);
      expect(Role.admin.hasPermission(Permission.exerciceApply), isTrue);
    });

    test('EncadreurChef doit avoir atelierApply et exerciceApply', () {
      expect(Role.encadreurChef.hasPermission(Permission.atelierApply), isTrue);
      expect(Role.encadreurChef.hasPermission(Permission.exerciceApply), isTrue);
    });

    test('Encadreur doit avoir atelierApply et exerciceApply', () {
      expect(Role.encadreur.hasPermission(Permission.atelierApply), isTrue);
      expect(Role.encadreur.hasPermission(Permission.exerciceApply), isTrue);
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

import 'domain_event.dart';

class RoleAssignedEvent extends DomainEvent {
  final String userId;
  final String roleId;

  const RoleAssignedEvent({required this.userId, required this.roleId});
}

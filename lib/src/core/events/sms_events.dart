import 'domain_event.dart';

class SmsMessageSentEvent extends DomainEvent {
  final String smsId;

  const SmsMessageSentEvent(this.smsId);
}

class SmsMessageDeletedEvent extends DomainEvent {
  final String smsId;

  const SmsMessageDeletedEvent(this.smsId);
}

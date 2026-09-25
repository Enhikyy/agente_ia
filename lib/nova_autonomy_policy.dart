/// Supervised research and evidence-based knowledge changes.
/// This policy does not itself provide a language model or web crawler.
enum NovaAutonomyMode { manual, supervised }
enum NovaDeletionMode { review, disposableAutomatic }

class NovaMemoryRecord {
  const NovaMemoryRecord({
    required this.id, required this.content, required this.createdAt,
    this.disposable = false, this.protected = false,
    this.userProvided = false, this.source,
  });
  final String id, content;
  final DateTime createdAt;
  final bool disposable, protected, userProvided;
  final String? source;
}

class NovaAutonomyPolicy {
  const NovaAutonomyPolicy({
    this.mode = NovaAutonomyMode.supervised,
    this.deletion = NovaDeletionMode.disposableAutomatic,
    this.disposableRetention = const Duration(days: 30),
  });
  final NovaAutonomyMode mode;
  final NovaDeletionMode deletion;
  final Duration disposableRetention;

  bool get canResearchScheduled => mode == NovaAutonomyMode.supervised;

  /// Only app-generated, explicitly disposable cache entries may be purged.
  /// Original documents, user memories and ambiguous records stay untouched.
  bool mayDelete(NovaMemoryRecord record, DateTime now) =>
      deletion == NovaDeletionMode.disposableAutomatic &&
      record.disposable && !record.protected && !record.userProvided &&
      !record.createdAt.isAfter(now) &&
      now.difference(record.createdAt) >= disposableRetention;

  /// User-authored and protected records require explicit confirmation.
  bool needsApprovalForChange(NovaMemoryRecord record) =>
      record.userProvided || record.protected || !record.disposable;

  Map<String, dynamic> toJson() => {
    'mode': mode.name, 'deletion': deletion.name,
    'retentionDays': disposableRetention.inDays,
  };

  factory NovaAutonomyPolicy.fromJson(Object? raw) {
    if (raw is! Map) return const NovaAutonomyPolicy();
    final days = raw['retentionDays'];
    return NovaAutonomyPolicy(
      mode: raw['mode'] == 'manual'
          ? NovaAutonomyMode.manual : NovaAutonomyMode.supervised,
      deletion: raw['deletion'] == 'review'
          ? NovaDeletionMode.review : NovaDeletionMode.disposableAutomatic,
      disposableRetention: Duration(
        days: days is int && days >= 7 && days <= 365 ? days : 30),
    );
  }
}

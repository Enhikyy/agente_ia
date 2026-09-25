import 'dart:convert';
import 'dart:io';
import 'nova_generation_archive.dart';
import 'nova_portable_export.dart';

/// Orchestrates a measured promotion. Caller must supply independently
/// measured metrics; it never fabricates RAM or accuracy measurements.
class NovaGenerationCoordinator {
  const NovaGenerationCoordinator();

  Future<File> promote({
    required Directory archiveDirectory,
    required NovaGenerationMetrics baseline,
    required NovaGenerationMetrics candidate,
    required Map<String, dynamic> previousState,
    required Map<String, dynamic> nextState,
    required Future<void> Function(Map<String, dynamic>) persist,
  }) async {
    const archive = NovaGenerationArchive();
    if (!archive.qualifies(baseline, candidate)) {
      throw StateError('Promotion requires verified 20% speed and RAM gains.');
    }
    // Validate portable serialization before any write to the active state.
    const portable = NovaPortableExport();
    final encoded = portable.encode(
      genome: {'format': 'nova-state', 'version': 1},
      learningState: nextState,
      metadata: {'createdAt': DateTime.now().toUtc().toIso8601String()},
    );
    portable.decode(encoded);
    final backup = await archive.backupBeforePromotion(archiveDirectory,
      old: baseline, next: candidate, previousSnapshot: previousState);
    // Read and verify the archived generation before changing active state.
    final wrapper = jsonDecode(await backup.readAsString()) as Map;
    final previous = (jsonDecode(wrapper['payload'] as String) as Map)['previous'];
    if (jsonEncode(previous) != jsonEncode(previousState)) {
      throw const FormatException('Backup round-trip mismatch.');
    }
    try {
      await persist(nextState);
    } catch (originalError, originalStack) {
      // Preserve the original failure if rollback also fails. The immutable
      // archive remains available for manual crash recovery.
      try {
        await persist(previousState);
      } catch (rollbackError) {
        Error.throwWithStackTrace(StateError(
          'Promotion failed: $originalError; rollback also failed: '
          '$rollbackError. Restore archive: ${backup.path}'), originalStack);
      }
      Error.throwWithStackTrace(originalError, originalStack);
    }
    return backup;
  }
}

import 'dart:math';

/// One locally executed assistant. Adapters must load at most one LLM at once.
abstract class NovaPeer {
  String get id;
  Future<String> answer(String prompt);
}

/// Verified exercises are supplied independently of the peer models.
class NovaExercise {
  const NovaExercise(this.prompt, this.expected);
  final String prompt;
  final String expected;
}

class NovaPeerResult {
  const NovaPeerResult(this.id, this.correct, this.total, this.errors);
  final String id;
  final int correct;
  final int total;
  final List<String> errors;
  double get accuracy => total == 0 ? 0 : correct / total;
}

class NovaCooperationReport {
  const NovaCooperationReport(this.results, this.examples, this.approved);
  final List<NovaPeerResult> results;
  final List<String> examples;
  final bool approved;
}

/// Coordinates sequential, bounded peer evaluation. No LLM may promote itself.
class NovaCooperationLab {
  const NovaCooperationLab({this.maxExamples = 12});
  final int maxExamples;

  Future<NovaCooperationReport> evaluate({
    required List<NovaPeer> peers,
    required List<NovaExercise> independentHoldout,
    required Future<bool> Function(String prompt, String answer) verify,
    required Future<bool> Function(List<String> verifiedExamples) validateNova,
  }) async {
    if (independentHoldout.isEmpty) {
      throw ArgumentError('Independent holdout is required');
    }
    if (peers.map((p) => p.id).toSet().length != peers.length) {
      throw ArgumentError('Peer IDs must be unique');
    }
    final results = <NovaPeerResult>[];
    final examples = <String>[];
    for (final peer in peers) {
      var correct = 0;
      final errors = <String>[];
      for (final exercise in independentHoldout) {
        try {
          final response = await peer.answer(exercise.prompt);
          if (response.trim().isEmpty || response.length > 16384) {
            errors.add('Invalid or oversized response');
            continue;
          }
          final valid = await verify(exercise.prompt, response);
          if (!valid) continue;
          correct++;
          if (examples.length < max(0, maxExamples)) {
            examples.add('Pergunta: ${exercise.prompt}\nResposta: $response');
          }
        } catch (error) {
          errors.add('Peer failed: $error');
        }
      }
      results.add(NovaPeerResult(peer.id, correct,
          independentHoldout.length, List.unmodifiable(errors)));
    }
    // A model's agreement with peers is never sufficient for promotion.
    final approved = examples.isNotEmpty &&
        await validateNova(List.unmodifiable(examples));
    return NovaCooperationReport(List.unmodifiable(results),
        List.unmodifiable(examples), approved);
  }
}

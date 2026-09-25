import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_code_dictionary.dart';

void main() {
  test('dicionário NCD recompõe texto exatamente', () {
    final dictionary = NovaCodeDictionary();
    const text = 'A NOVA aprende relações internacionais e aprende ciência.';
    final encoded = dictionary.encode(text);
    expect(dictionary.decode(encoded), text);
    expect(dictionary.entries, greaterThan(3));
  });

  test('estado do dicionário é reversível', () {
    final dictionary = NovaCodeDictionary();
    dictionary.learn('uma palavra nova e outra palavra');
    final restored = NovaCodeDictionary();
    expect(restored.fromJson(dictionary.toJson()), isTrue);
    expect(restored.entries, dictionary.entries);
  });

  test('estatísticas não inventam economia', () {
    final dictionary = NovaCodeDictionary();
    final stats = dictionary.stats('nova nova nova nova nova nova nova nova');
    expect(stats['rawBytes'], greaterThan(0));
    expect(stats['packedBytes'], greaterThan(0));
    expect(stats['reductionPercent'], isA<double>());
  });
}

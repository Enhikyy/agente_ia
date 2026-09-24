import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_developmental_language.dart';

void main() {
  test('Nao inventa resposta sem conhecimento', () {
    final nova = NovaDevelopmentalLanguage();
    expect(nova.answer('Resuma o documento'), contains('Importe'));
    expect(nova.answer('O que e astrofisica?'), contains('nao encontrei'));
  });
  test('Importa texto e fornece resumo extrativo', () {
    final nova = NovaDevelopmentalLanguage();
    nova.learnDocument('A Terra orbita o Sol em aproximadamente 365 dias. O sistema solar inclui oito planetas.');
    expect(nova.answer('Faca um resumo'), contains('A Terra orbita'));
    expect(nova.memoryCount, greaterThan(0));
  });
  test('Memoria persiste entre instancias e evolui em geracoes', () {
    final nova = NovaDevelopmentalLanguage();
    nova.learnDocument('A fotossintese converte energia luminosa em energia quimica nas plantas.');
    for (var i = 0; i < 24; i++) {
      nova.learnConversation('Experiencia de aprendizagem numero $i');
    }
    expect(nova.generation, 1);
    final outra = NovaDevelopmentalLanguage();
    expect(outra.importState(nova.exportState()), isTrue);
    expect(outra.generation, 1);
    expect(outra.answer('fotossintese plantas'), contains('fotossintese'));
  });
}

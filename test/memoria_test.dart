import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/main.dart';

void main() {
  test('restauracao valida preserva memoria', () {
    final origem = HemisferioDireitoQuantico();
    origem.aprenderComOtimizacao('memoria persistente preservada');
    final copia = HemisferioDireitoQuantico();
    expect(copia.restaurarPacoteCriogenico(origem.gerarPacoteCriogenico()), isTrue);
    expect(copia.gerarPacoteCriogenico(), origem.gerarPacoteCriogenico());
  });

  test('backup corrompido nao altera estado existente', () {
    final memoria = HemisferioDireitoQuantico();
    memoria.aprenderComOtimizacao('teste de integridade local');
    final anterior = memoria.gerarPacoteCriogenico();
    expect(memoria.restaurarPacoteCriogenico('''{"versao":"6.0","interacoes":10,"contador":2,"dicionario":{},"inverso":{},"sinapses":{"x":{"y":"invalido"}}}'''), isFalse);
    expect(memoria.gerarPacoteCriogenico(), anterior);
  });

  test('rejeita versao desconhecida', () {
    final memoria = HemisferioDireitoQuantico();
    expect(memoria.restaurarPacoteCriogenico('{"versao":"999"}'), isFalse);
  });
}

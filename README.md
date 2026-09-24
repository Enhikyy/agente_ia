# NOVA-0.1 — Fundação

Aplicativo Flutter para Android, com processamento local de associações de palavras, leitura de PDF/TXT e memória persistente.

## Segurança da memória

A restauração de snapshots v6 valida a estrutura antes de substituir a memória ativa. A gravação usa um arquivo temporário e mantém uma cópia `.bak` do arquivo anterior. Um snapshot inválido não deve apagar a memória em uso.

## Desenvolvimento

```sh
flutter pub get
flutter test
flutter build apk --release --split-per-abi
```

O workflow `.github/workflows/build.yml` executa os testes antes da compilação e publica o APK ARMv7 como artefato quando o build termina com sucesso.

## Limitações atuais

O núcleo é uma rede de associações simbólicas, **não** um LLM. Integração GGUF, RAG avançado, UI NOVA e restauração exportável ainda são etapas futuras. O backup criado pelo aplicativo fica no armazenamento privado; a interface para exportá-lo ainda não foi implementada.

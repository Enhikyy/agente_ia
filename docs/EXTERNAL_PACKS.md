# Pacotes externos da NOVA

O APK inclui somente a interface e o motor simbólico experimental. Conhecimento adicional pode ser instalado **depois**, sem recompilar o aplicativo.

## Instalar um pacote local
1. Baixe um arquivo `.nova.json` de uma fonte confiável (exemplo: [demonstração em português](../examples/nova-demo-portugues.nova.json)).
2. Abra **NOVA → Plugins → Instalar arquivo .nova.json** e escolha o arquivo.
3. O pacote é validado e seus documentos são importados para a memória local.

## Instalar por HTTPS
1. Obtenha a URL HTTPS direta do arquivo e o **SHA-256 oficial**, publicado independentemente pelo fornecedor.
2. Abra **Plugins → Instalar por URL HTTPS**.
3. Informe a URL e o SHA-256. A NOVA recusa redirecionamentos, arquivos acima de 32 MB, hash incorreto e formatos desconhecidos.

O aplicativo não instala nem executa código externo, APKs, modelos LLM ou bibliotecas nativas. O formato atual suporta **pacotes de conhecimento** com até 100 documentos de texto e 32 MB por arquivo. Para bibliotecas grandes, divida o conteúdo em vários pacotes.

## Formato de exemplo
```json
{
  "format": "nova-knowledge-v1",
  "id": "minha-base-001",
  "name": "Minha base",
  "description": "Conhecimento em português",
  "documents": ["Primeiro documento.", "Segundo documento."]
}
```

Use IDs de 3 a 64 caracteres, apenas letras minúsculas ASCII, números, pontos, hífens e sublinhados. O armazenamento fica no diretório privado do aplicativo. Pacotes de fontes desconhecidas podem conter dados incorretos: a validação de hash comprova integridade em relação ao valor informado, não a veracidade do conteúdo.

**GitHub:** o limite de 100 MiB aplica-se a arquivos comuns enviados ao repositório Git. Os pacotes da NOVA podem ser hospedados separadamente (GitHub Releases ou servidor HTTPS próprio). Esta versão impõe seu próprio limite de 32 MB por pacote para proteger a memória do Moto G62.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'nova_module_runtime.dart';

/// Data-only offline add-on. No remote Dart, APK, shell or dynamic code execution.
class NovaPack {
  const NovaPack(this.id, this.name, this.description, this.documents,
      {this.modules = const []});
  final String id, name, description;
  final List<String> documents;
  final List<NovaModule> modules;

  static NovaPack parse(List<int> bytes) {
    if (bytes.length > NovaPackInstaller.maxBytes) {
      throw const FormatException('Pacote acima do limite de 32 MB');
    }
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map || data['format'] != 'nova-knowledge-v1') {
      throw const FormatException('Formato desconhecido: esperado nova-knowledge-v1');
    }
    final id = data['id'], name = data['name'], description = data['description'];
    final raw = data['documents'];
    final rawModules = data['modules'] is List ? data['modules'] as List : const <dynamic>[];
    if (id is! String || !RegExp(r'^[a-z0-9][a-z0-9._-]{2,63}
  }
}

class NovaPackInstaller {
  static const maxBytes = 32 * 1024 * 1024;
  final Directory directory;
  NovaPackInstaller(this.directory);

  Future<List<int>> _readBounded(Stream<List<int>> source) async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in source) {
      if (bytes.length + chunk.length > maxBytes) {
        throw const FormatException('Download excede 32 MB');
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  Future<NovaPack> installLocal(File file) async {
    if (await file.length() > maxBytes) {
      throw const FormatException('Arquivo excede 32 MB');
    }
    return _install(await _readBounded(file.openRead()));
  }

  /// HTTPS + user-supplied SHA-256 prevent silent substitution of downloads.
  Future<NovaPack> installHttps(String url, String expectedSha256) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException('Use um endereço HTTPS válido');
    }
    final digest = expectedSha256.trim().toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
      throw const FormatException('Informe o SHA-256 oficial do pacote');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      client.autoUncompress = false;
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      final response = await request.close().timeout(
        const Duration(seconds: 30));
      if (response.statusCode != 200) {
        await response.drain<void>();
        throw HttpException('Servidor respondeu ${response.statusCode}');
      }
      if (response.contentLength > maxBytes) {
        await response.drain<void>();
        throw const FormatException('Arquivo excede 32 MB');
      }
      final bytes = await _readBounded(response.timeout(
        const Duration(seconds: 30)));
      if (sha256.convert(bytes).toString() != digest) {
        throw const FormatException('SHA-256 não confere: download recusado');
      }
      return _install(bytes);
    } finally {
      client.close(force: true);
    }
  }

  Future<NovaPack> _install(List<int> bytes) async {
    final pack = NovaPack.parse(bytes);
    await directory.create(recursive: true);
    final target = File('${directory.path}/${pack.id}.nova.json');
    final temp = File('${target.path}.tmp');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(target.path);
    return pack;
  }

  Future<List<NovaPack>> installed() async {
    if (!await directory.exists()) return [];
    final packs = <NovaPack>[];
    await for (final item in directory.list(followLinks: false)) {
      if (item is! File || !item.path.endsWith('.nova.json')) continue;
      try {
        if (await item.length() <= maxBytes) {
          packs.add(NovaPack.parse(await item.readAsBytes()));
        }
      } catch (_) { /* Ignore corrupt packages; never execute them. */ }
    }
    return packs;
  }
}
).hasMatch(id) ||
        name is! String || name.trim().isEmpty || name.length > 120 ||
        description is! String || description.length > 1000 ||
        raw is! List || raw.isEmpty || raw.length > 100 ||
        raw.any((x) => x is! String || x.trim().isEmpty || x.length > 300000) ||
        rawModules.length > 20) {
      throw const FormatException('Metadados, documentos ou módulos inválidos');
    }
    final modules = <NovaModule>[];
    for (final item in rawModules) {
      modules.add(NovaModule.parse(item));
    }
    return NovaPack(id, name, description, List<String>.from(raw), modules: modules);
  }
}

class NovaPackInstaller {
  static const maxBytes = 32 * 1024 * 1024;
  final Directory directory;
  NovaPackInstaller(this.directory);

  Future<List<int>> _readBounded(Stream<List<int>> source) async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in source) {
      if (bytes.length + chunk.length > maxBytes) {
        throw const FormatException('Download excede 32 MB');
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  Future<NovaPack> installLocal(File file) async {
    if (await file.length() > maxBytes) {
      throw const FormatException('Arquivo excede 32 MB');
    }
    return _install(await _readBounded(file.openRead()));
  }

  /// HTTPS + user-supplied SHA-256 prevent silent substitution of downloads.
  Future<NovaPack> installHttps(String url, String expectedSha256) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException('Use um endereço HTTPS válido');
    }
    final digest = expectedSha256.trim().toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
      throw const FormatException('Informe o SHA-256 oficial do pacote');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      client.autoUncompress = false;
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      final response = await request.close().timeout(
        const Duration(seconds: 30));
      if (response.statusCode != 200) {
        await response.drain<void>();
        throw HttpException('Servidor respondeu ${response.statusCode}');
      }
      if (response.contentLength > maxBytes) {
        await response.drain<void>();
        throw const FormatException('Arquivo excede 32 MB');
      }
      final bytes = await _readBounded(response.timeout(
        const Duration(seconds: 30)));
      if (sha256.convert(bytes).toString() != digest) {
        throw const FormatException('SHA-256 não confere: download recusado');
      }
      return _install(bytes);
    } finally {
      client.close(force: true);
    }
  }

  Future<NovaPack> _install(List<int> bytes) async {
    final pack = NovaPack.parse(bytes);
    await directory.create(recursive: true);
    final target = File('${directory.path}/${pack.id}.nova.json');
    final temp = File('${target.path}.tmp');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(target.path);
    return pack;
  }

  Future<List<NovaPack>> installed() async {
    if (!await directory.exists()) return [];
    final packs = <NovaPack>[];
    await for (final item in directory.list(followLinks: false)) {
      if (item is! File || !item.path.endsWith('.nova.json')) continue;
      try {
        if (await item.length() <= maxBytes) {
          packs.add(NovaPack.parse(await item.readAsBytes()));
        }
      } catch (_) { /* Ignore corrupt packages; never execute them. */ }
    }
    return packs;
  }
}

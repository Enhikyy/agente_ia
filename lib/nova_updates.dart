import 'dart:convert';
import 'dart:io';

class NovaUpdate {
  const NovaUpdate({required this.build, required this.url,
    required this.notes, required this.publishedAt});
  final int build;
  final Uri url;
  final String notes;
  final DateTime? publishedAt;
}

class NovaUpdates {
  const NovaUpdates();
  static const currentBuild = int.fromEnvironment('NOVA_BUILD_NUMBER',
      defaultValue: 1);
  static const endpoint =
      'https://api.github.com/repos/Enhikyy/agente_ia/releases/tags/nova-preview';

  static NovaUpdate? parseRelease(Map<String, dynamic> json, int installed) {
    if (json['draft'] == true) return null;
    final body = json['body']?.toString() ?? '';
    final match = RegExp(r'NOVA_BUILD_NUMBER=(\d+)').firstMatch(body);
    if (match == null) return null;
    final build = int.tryParse(match.group(1)!);
    if (build == null || build <= installed) return null;
    final assets = json['assets'];
    if (assets is! List) return null;
    for (final item in assets) {
      if (item is! Map || item['name'] != 'NOVA-moto-g62-arm64.apk') continue;
      final url = Uri.tryParse(item['browser_download_url']?.toString() ?? '');
      if (url == null || url.scheme != 'https' ||
          url.host != 'github.com' ||
          url.path != '/Enhikyy/agente_ia/releases/download/'
              'nova-preview/NOVA-moto-g62-arm64.apk') continue;
      return NovaUpdate(build: build, url: url,
        notes: body.replaceAll(RegExp(r'NOVA_BUILD_NUMBER=\d+'), '').trim(),
        publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? ''));
    }
    return null;
  }

  Future<NovaUpdate?> check() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(Uri.parse(endpoint));
      request.headers.set(HttpHeaders.acceptHeader,
          'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'NOVA-Android');
      request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw HttpException('GitHub HTTP ${response.statusCode}');
      }
      final raw = await utf8.decoder.bind(response).join();
      if (raw.length > 200000) throw const FormatException('Release too large');
      return parseRelease(jsonDecode(raw) as Map<String, dynamic>, currentBuild);
    } finally {
      client.close(force: true);
    }
  }
}

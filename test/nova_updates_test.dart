import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_updates.dart';

void main() {
  const url = 'https://github.com/Enhikyy/agente_ia/releases/download/'
      'nova-preview/NOVA-moto-g62-arm64.apk';
  Map<String, dynamic> release(int build, String assetUrl) => {
    'draft': false, 'body': 'NOVA_BUILD_NUMBER=$build',
    'assets': [{'name': 'NOVA-moto-g62-arm64.apk',
      'browser_download_url': assetUrl}],
  };

  test('detects newer version with trusted download', () {
    final result = NovaUpdates.parseRelease(release(12, url), 11);
    expect(result?.build, 12);
    expect(result?.url.toString(), url);
  });

  test('ignores installed or older releases', () {
    expect(NovaUpdates.parseRelease(release(11, url), 11), isNull);
    expect(NovaUpdates.parseRelease(release(10, url), 11), isNull);
  });

  test('rejects unknown hosts and missing metadata', () {
    expect(NovaUpdates.parseRelease(release(12,
      'https://evil.example/NOVA-moto-g62-arm64.apk'), 11), isNull);
    expect(NovaUpdates.parseRelease({'assets': []}, 11), isNull);
  });
}

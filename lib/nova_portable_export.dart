import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Portable JSON data interchange, not a GGUF language model.
class NovaPortableExport {
  const NovaPortableExport();
  String encode({required Map<String, dynamic> genome,
      required Map<String, dynamic> learningState,
      required Map<String, dynamic> metadata}) {
    final data = jsonEncode({'format': 'nova-portable', 'version': 1,
      'genome': genome, 'learningState': learningState,
      'metadata': metadata});
    return jsonEncode({'sha256': sha256.convert(utf8.encode(data)).toString(),
      'payload': data});
  }
  Map<String, dynamic> decode(String raw) {
    final wrapper = jsonDecode(raw);
    if (wrapper is! Map || wrapper['payload'] is! String ||
        wrapper['sha256'] is! String) {
      throw const FormatException('Invalid portable package.');
    }
    final payload = wrapper['payload'] as String;
    if (sha256.convert(utf8.encode(payload)).toString() != wrapper['sha256']) {
      throw const FormatException('Portable package checksum mismatch.');
    }
    final data = jsonDecode(payload);
    if (data is! Map || data['format'] != 'nova-portable' ||
        data['version'] != 1 || data['genome'] is! Map ||
        data['learningState'] is! Map) {
      throw const FormatException('Unsupported portable format.');
    }
    return Map<String, dynamic>.from(data);
  }
  /// PocketPal requires a supported GGUF model; JSON cannot be imported as one.
  bool get directlyCompatibleWithPocketPal => false;
}

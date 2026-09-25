import 'package:flutter/services.dart';

enum NovaResourceState { ready, throttled, paused, unavailable }

class NovaResourceSnapshot {
  const NovaResourceSnapshot({
    required this.batteryPercent,
    required this.temperatureC,
    required this.thermalStatus,
    required this.availableMemoryMb,
    required this.lowMemory,
    required this.charging,
  });
  final int batteryPercent, thermalStatus, availableMemoryMb;
  final double temperatureC;
  final bool lowMemory, charging;

  factory NovaResourceSnapshot.fromMap(Map<dynamic, dynamic> m) =>
      NovaResourceSnapshot(
        batteryPercent: (m['batteryPercent'] as num).toInt(),
        temperatureC: (m['temperatureC'] as num).toDouble(),
        thermalStatus: (m['thermalStatus'] as num).toInt(),
        availableMemoryMb: (m['availableMemoryMb'] as num).toInt(),
        lowMemory: m['lowMemory'] == true,
        charging: m['charging'] == true,
      );
}

class NovaResourceDecision {
  const NovaResourceDecision(this.state, this.reason);
  final NovaResourceState state;
  final String reason;
  bool get mayRunIntensive => state == NovaResourceState.ready;
}

/// Intensive mode is fail-closed: unknown sensors cannot authorize heavy work.
class NovaResourceGuard {
  const NovaResourceGuard();
  static const _channel = MethodChannel('nova/device_resources');

  Future<NovaResourceSnapshot?> read() async {
    try {
      final data = await _channel.invokeMapMethod<dynamic, dynamic>('read');
      if (data == null) return null;
      return NovaResourceSnapshot.fromMap(data);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    } on TypeError {
      return null;
    }
  }

  NovaResourceDecision decide(NovaResourceSnapshot? s) {
    if (s == null || s.batteryPercent < 0 || s.temperatureC <= 0 ||
        s.availableMemoryMb < 0 || s.thermalStatus < 0) {
      return const NovaResourceDecision(NovaResourceState.unavailable,
          'Sensores indisponíveis; trabalho intensivo bloqueado.');
    }
    if (s.thermalStatus >= 3 || s.temperatureC >= 42) {
      return const NovaResourceDecision(NovaResourceState.paused,
          'Temperatura ou estado térmico elevado.');
    }
    if (s.batteryPercent <= 15 && !s.charging) {
      return const NovaResourceDecision(NovaResourceState.paused,
          'Bateria crítica (15% ou menos).');
    }
    if (s.lowMemory || s.availableMemoryMb < 350) {
      return const NovaResourceDecision(NovaResourceState.paused,
          'Memória disponível insuficiente.');
    }
    if (s.batteryPercent <= 30 && !s.charging ||
        s.temperatureC >= 39 || s.thermalStatus >= 2 ||
        s.availableMemoryMb < 650) {
      return const NovaResourceDecision(NovaResourceState.throttled,
          'Recursos moderados; somente tarefas leves.');
    }
    return const NovaResourceDecision(NovaResourceState.ready,
        'Recursos adequados para tarefas intensivas.');
  }

  Future<NovaResourceDecision> check() async => decide(await read());
}

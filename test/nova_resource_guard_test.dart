import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_resource_guard.dart';

void main() {
  const guard = NovaResourceGuard();
  NovaResourceSnapshot snapshot({
    int battery = 85, double temp = 34, int thermal = 0,
    int ram = 1400, bool low = false, bool charging = false,
  }) => NovaResourceSnapshot(
    batteryPercent: battery, temperatureC: temp, thermalStatus: thermal,
    availableMemoryMb: ram, lowMemory: low, charging: charging,
  );

  test('intensive mode allowed when all sensors are healthy', () {
    expect(guard.decide(snapshot()).mayRunIntensive, true);
  });
  test('critical battery suspends unless charging', () {
    expect(guard.decide(snapshot(battery: 15)).state, NovaResourceState.paused);
    expect(guard.decide(snapshot(battery: 15, charging: true)).mayRunIntensive, true);
  });
  test('high temperature or severe thermal status pauses', () {
    expect(guard.decide(snapshot(temp: 42)).state, NovaResourceState.paused);
    expect(guard.decide(snapshot(thermal: 3)).state, NovaResourceState.paused);
  });
  test('low memory pauses; moderate resources throttle', () {
    expect(guard.decide(snapshot(ram: 300)).state, NovaResourceState.paused);
    expect(guard.decide(snapshot(ram: 500)).state, NovaResourceState.throttled);
    expect(guard.decide(snapshot(battery: 25)).state, NovaResourceState.throttled);
  });
  test('unavailable sensors never authorize intensive work', () {
    expect(guard.decide(null).state, NovaResourceState.unavailable);
    expect(guard.decide(snapshot(thermal: -1)).mayRunIntensive, false);
  });
}

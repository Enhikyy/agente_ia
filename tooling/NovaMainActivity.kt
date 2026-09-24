package com.agenteia.app.agente_ia

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nova/device_resources")
            .setMethodCallHandler { call, result ->
                if (call.method != "read") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val battery = registerReceiver(null,
                        IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                    val level = battery?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
                    val scale = battery?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
                    val percent = if (level >= 0 && scale > 0) level * 100 / scale else -1
                    val rawTemp = battery?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1
                    val status = battery?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
                    val charging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                        status == BatteryManager.BATTERY_STATUS_FULL
                    val power = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val thermal = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                        power.currentThermalStatus else -1
                    val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val memory = ActivityManager.MemoryInfo()
                    manager.getMemoryInfo(memory)
                    result.success(mapOf(
                        "batteryPercent" to percent,
                        "temperatureC" to if (rawTemp > 0) rawTemp / 10.0 else -1.0,
                        "thermalStatus" to thermal,
                        "availableMemoryMb" to (memory.availMem / (1024 * 1024)).toInt(),
                        "lowMemory" to memory.lowMemory,
                        "charging" to charging
                    ))
                } catch (e: Exception) {
                    result.error("RESOURCE_READ_FAILED", e.message, null)
                }
            }
    }
}

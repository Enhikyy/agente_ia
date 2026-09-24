package com.agenteia.app.agente_ia

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkerParameters
import androidx.work.WorkManager
import java.io.File
import java.util.concurrent.TimeUnit

/**
 * Periodic, bounded, battery-aware native scan of the app-private inbox.
 * WorkManager owns the short-lived CPU wake lock while the Worker executes.
 * This is not an always-on foreground service or unrestricted file access.
 */
class NovaBackgroundWorker(context: Context, params: WorkerParameters) :
    CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        val context = applicationContext
        val battery = context.registerReceiver(null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = battery?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = battery?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val percent = if (level >= 0 && scale > 0) level * 100 / scale else -1
        val rawTemp = battery?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1
        val status = battery?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val charging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL
        val power = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val thermal = if (Build.VERSION.SDK_INT >= 29) power.currentThermalStatus else -1
        val activity = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memory = ActivityManager.MemoryInfo()
        activity.getMemoryInfo(memory)
        val freeMb = memory.availMem / (1024 * 1024)
        // Fail closed. Worker never runs heavy operations without sensor data.
        if (percent < 0 || rawTemp <= 0 || thermal < 0 ||
            (percent <= 30 && !charging) || rawTemp >= 390 ||
            thermal >= 2 || memory.lowMemory || freeMb < 650) {
            return Result.success()
        }
        val inbox = File(context.filesDir, "nova_inbox")
        if (!inbox.exists()) return Result.success()
        val pending = inbox.listFiles()
            ?.filter { it.isFile && it.length() <= 2 * 1024 * 1024 &&
                (it.extension.lowercase() == "txt" || it.extension.lowercase() == "json") }
            ?.take(20) ?: emptyList()
        val queue = File(context.filesDir, "nova_pending_scan.txt")
        val known = if (queue.exists()) queue.readLines().toSet() else emptySet()
        val fresh = pending.map { it.name }
            .filter { !it.contains('\n') && !it.contains('\r') && it !in known }
        if (fresh.isNotEmpty()) queue.appendText(fresh.joinToString("\n", postfix = "\n"))
        return Result.success()
    }

    companion object {
        fun schedule(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiresBatteryNotLow(true)
                .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                .build()
            val request = PeriodicWorkRequestBuilder<NovaBackgroundWorker>(
                15, TimeUnit.MINUTES
            ).setConstraints(constraints).build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                "nova_intensive_autonomy",
                ExistingPeriodicWorkPolicy.KEEP,
                request
            )
        }
        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork("nova_intensive_autonomy")
        }
    }
}

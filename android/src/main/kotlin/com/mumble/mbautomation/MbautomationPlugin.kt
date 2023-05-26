package com.mumble.mbautomation

import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** MbautomationPlugin */
class MbautomationPlugin : ActivityAware, FlutterPlugin, PluginRegistry.NewIntentListener, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var mainActivity: Activity? = null
    private var launchIntent: Intent? = null

    companion object {
        const val ACTION_CREATED_NOTIFICATION = "mpush_create_notification"
        const val ACTION_CLICKED_NOTIFICATION = "mpush_clicked_notification"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mbautomation")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "showNotification" -> Utils.scheduleNotification(applicationContext!!, call.arguments as Map<String, Any>, result)
            "cancelNotification" -> cancelNotification((call.arguments as Map<String, Any>)["id"] as Int, result)
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.launchIntent = mainActivity?.intent
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.applicationContext = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.mainActivity = binding.activity
        this.applicationContext = binding.activity.applicationContext
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        this.mainActivity = null
        this.applicationContext = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        val res: Boolean = Utils.sendNotificationPayloadMessage(channel, intent)
        if (res && mainActivity != null) {
            mainActivity!!.intent = intent
        }
        return res
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        channel.setMethodCallHandler(null)
    }

    fun cancelNotification(id: Int, @NonNull result: Result) {
        val nm: NotificationManager? = applicationContext!!.getSystemService(NOTIFICATION_SERVICE) as NotificationManager?
        nm?.cancel(id)
        result.success(true)
    }
}

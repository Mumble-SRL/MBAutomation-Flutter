package com.mumble.mbautomation

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit
import kotlin.random.Random

class Utils {
    companion object {

        fun getLauncherActivity(context: Context): Intent? {
            val packageManager = context.packageManager
            return packageManager.getLaunchIntentForPackage(context.packageName)
        }

        fun getDrawableResourceId(context: Context, name: String): Int {
            return context.resources.getIdentifier(name, "drawable", context.packageName)
        }

        fun getBitmapFromPath(filePath: String): Bitmap? {
            return BitmapFactory.decodeFile(filePath)
        }

        fun sendNotificationPayloadMessage(channel: MethodChannel, intent: Intent?): Boolean {
            if (intent != null) {
                if (intent.action == MbautomationPlugin.ACTION_CLICKED_NOTIFICATION) {
                    val payload = intent.getStringExtra("map")
                    channel.invokeMethod("pushTapped", payload)
                    return true
                }
            }
            return false
        }

        fun scheduleNotification(applicationContext: Context, map: Map<String, Any>) {
            val id = map["id"] as Int

            val date: Long = if (map["date"] is Long) {
                map["date"] as Long
            } else {
                (map["date"] as Int).toLong()
            }

            val new_millis = TimeUnit.SECONDS.toMillis(date)
            val gson = Gson()

            val intent = Intent(applicationContext, AlarmReceiverScheduledNotifications::class.java)
            intent.putExtra("map", gson.toJson(map).toString())

            val pendingIntent = PendingIntent.getBroadcast(applicationContext, id, intent, PendingIntent.FLAG_UPDATE_CURRENT)
            val alarmManager = applicationContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.cancel(pendingIntent)
            if (Build.VERSION.SDK_INT >= 19) {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, new_millis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, new_millis, pendingIntent)
            }
        }

        fun showNotification(applicationContext: Context, map: Map<String, Any>) {
            val gson = Gson()
            val title = map["title"] as String?
            val body = map["body"] as String?
            val launchImage = map["launchImage"] as String?
            val sound = map["sound"] as String?
            val media = map["media"] as String?
            val mediaType = map["mediaType"] as String?
            val channelId = map["channelId"] as String
            val icon = map["icon"] as String

            var iconResource = getDrawableResourceId(applicationContext, icon)

            val notificationID = Random.nextInt()
            val mNotificationManager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val intent = getLauncherActivity(applicationContext)
            intent?.action = MbautomationPlugin.ACTION_CLICKED_NOTIFICATION
            intent?.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent?.putExtra("map", gson.toJson(map))

            val contentIntent = PendingIntent.getActivity(applicationContext, notificationID, intent, PendingIntent.FLAG_UPDATE_CURRENT)
            val notificationBuilder = NotificationCompat.Builder(applicationContext, channelId)

            notificationBuilder.setContentTitle(title)
                    .setAutoCancel(true)
                    .setContentText(body)
                    .setContentIntent(contentIntent)

            notificationBuilder.setSmallIcon(iconResource)

            if (media != null) {
                val bitmap = getBitmapFromPath(media)
                if (bitmap != null) {
                    notificationBuilder.setStyle(NotificationCompat.BigPictureStyle()
                            .setSummaryText(body)
                            .bigPicture(bitmap))
                } else {
                    notificationBuilder.setStyle(NotificationCompat.BigTextStyle().bigText(body))
                }
            } else {
                notificationBuilder.setStyle(NotificationCompat.BigTextStyle().bigText(body))
            }

            val createIntent = Intent(MbautomationPlugin.ACTION_CREATED_NOTIFICATION)
            createIntent.putExtra("map", gson.toJson(map))
            LocalBroadcastManager.getInstance(applicationContext).sendBroadcast(createIntent)
            mNotificationManager.notify(notificationID, notificationBuilder.build())
        }
    }
}
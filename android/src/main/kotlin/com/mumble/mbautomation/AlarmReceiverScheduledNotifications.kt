package com.mumble.mbautomation

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.google.gson.Gson
import com.google.gson.JsonElement

class AlarmReceiverScheduledNotifications : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent != null) {
            val gson = Gson()
            val map = gson.fromJson(intent.getStringExtra("map")!!, Map::class.java)
            Utils.showNotification(context!!, map as Map<String, Any>)
        }
    }
}
package com.example.mobile

import android.appwidget.AppWidgetManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class MyWidgetProvider : HomeWidgetProvider() {
    companion object {
        private const val ACTION_TOGGLE_TASK = "com.example.mobile.ACTION_TOGGLE_TASK"
        private const val EXTRA_TASK_INDEX = "task_index"
        private const val PREFS_NAME = "HomeWidgetPreferences"
        private const val EMAILS_KEY = "emails_json"
    }

    private fun toggleCompletionAtIndex(context: Context, index: Int): Boolean {
        if (index < 0) return false

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(EMAILS_KEY, "[]") ?: "[]"
        val items = try {
            JSONArray(raw)
        } catch (_: Exception) {
            JSONArray("[]")
        }

        if (index >= items.length()) return false

        val item = items.getJSONObject(index)
        val current = item.optBoolean("isCompleted", false)
        item.put("isCompleted", !current)
        prefs.edit().putString(EMAILS_KEY, items.toString()).apply()
        return true
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action != ACTION_TOGGLE_TASK) return

        val index = intent.getIntExtra(EXTRA_TASK_INDEX, -1)
        if (!toggleCompletionAtIndex(context, index)) return

        val manager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, MyWidgetProvider::class.java)
        val ids = manager.getAppWidgetIds(component)
        if (ids.isEmpty()) return

        ids.forEach { widgetId ->
            manager.notifyAppWidgetViewDataChanged(widgetId, R.id.mail_list)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_deadlines)

            // Wire the ListView to use RemoteViewsService
            val intent = Intent(context, WidgetListService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                // Must be unique per widget instance for RemoteViews collection binding.
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.mail_list, intent)

            // Set up the click intent template for list items
            val clickIntent = Intent(context, MyWidgetProvider::class.java).apply {
                action = ACTION_TOGGLE_TASK
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                widgetId,
                clickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setPendingIntentTemplate(R.id.mail_list, pendingIntent)

            val raw = widgetData.getString(EMAILS_KEY, "[]") ?: "[]"
            val items = try {
                JSONArray(raw)
            } catch (_: Exception) {
                JSONArray("[]")
            }

            val count = items.length()
            views.setTextViewText(
                R.id.footer,
                if (count == 0) "Open app to sync" else "$count mails synced"
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

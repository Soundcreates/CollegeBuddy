package com.example.mobile

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class MyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_deadlines)

            val raw = widgetData.getString("emails_json", "[]") ?: "[]"

            val items = try {
                JSONArray(raw)
            } catch (_: Exception) {
                JSONArray("[]")
            }

            val count = items.length()
            if (count == 0) {
                views.setTextViewText(R.id.header, "Today")
                views.setTextViewText(R.id.task1, "No deadlines yet")
                views.setTextViewText(R.id.time1, "")
                views.setTextViewText(R.id.task2, "")
                views.setTextViewText(R.id.time2, "")
                views.setTextViewText(R.id.footer, "Open app to sync mails")
            } else {
                views.setTextViewText(R.id.header, "Deadlines")

                val first = items.getJSONObject(0)
                val firstDone = first.optBoolean("isCompleted", false)
                val firstPrefix = if (firstDone) "[x] " else "[ ] "
                views.setTextViewText(R.id.task1, firstPrefix + first.optString("subject", "Untitled"))
                views.setTextViewText(R.id.time1, first.optString("date", ""))

                if (count > 1) {
                    val second = items.getJSONObject(1)
                    val secondDone = second.optBoolean("isCompleted", false)
                    val secondPrefix = if (secondDone) "[x] " else "[ ] "
                    views.setTextViewText(R.id.task2, secondPrefix + second.optString("subject", "Untitled"))
                    views.setTextViewText(R.id.time2, second.optString("date", ""))
                } else {
                    views.setTextViewText(R.id.task2, "")
                    views.setTextViewText(R.id.time2, "")
                }

                views.setTextViewText(R.id.footer, "$count mails synced")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

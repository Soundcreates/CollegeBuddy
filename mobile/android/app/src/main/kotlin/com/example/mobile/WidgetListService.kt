package com.example.mobile

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Paint
import android.graphics.Color
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject

class WidgetListService : RemoteViewsService() {
    override fun onGetViewFactory(intent: android.content.Intent): RemoteViewsFactory {
        return WidgetListFactory(applicationContext)
    }
}

class WidgetListFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var mails = mutableListOf<JSONObject>()
    private val completedOrange = Color.parseColor("#FF8C00")
    private val pendingPrimary = Color.parseColor("#FFFFFF")
    private val urgentRed = Color.parseColor("#FF5252")
    private val soonAmber = Color.parseColor("#FFAA00")
    private val neutralDate = Color.parseColor("#8FA3AD")

    override fun onCreate() {
        loadMails()
    }

    override fun onDataSetChanged() {
        loadMails()
    }

    override fun onDestroy() {
        mails.clear()
    }

    private fun loadMails() {
        mails.clear()
        try {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val raw = prefs.getString("emails_json", "[]") ?: "[]"
            val items = JSONArray(raw)
            for (i in 0 until items.length()) {
                mails.add(items.getJSONObject(i))
            }
        } catch (e: Exception) {
            mails.clear()
        }
    }

    override fun getCount(): Int = mails.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_item)
        if (position < 0 || position >= mails.size) return views

        val mail = mails[position]
        val isCompleted = mail.optBoolean("isCompleted", false)
        val subject = mail.optString("subject", "Untitled")

        // Compact subject
        val compactSubject = subject.replace("\n", " ").replace(Regex("\\s+"), " ").trim().take(48)
        views.setTextViewText(R.id.item_subject, compactSubject)

        // Apply styling based on completion state
        if (isCompleted) {
            views.setTextColor(R.id.item_subject, completedOrange)
            views.setTextViewText(R.id.item_check, "✓")
            views.setTextColor(R.id.item_check, Color.parseColor("#121212"))
            views.setInt(R.id.item_check, "setBackgroundResource", R.drawable.widget_checkbox_checked)
            views.setInt(R.id.item_subject, "setPaintFlags", Paint.ANTI_ALIAS_FLAG or Paint.STRIKE_THRU_TEXT_FLAG)
        } else {
            views.setTextColor(R.id.item_subject, pendingPrimary)
            views.setTextViewText(R.id.item_check, "")
            views.setTextColor(R.id.item_check, Color.parseColor("#121212"))
            views.setInt(R.id.item_check, "setBackgroundResource", R.drawable.widget_checkbox_unchecked)
            views.setInt(R.id.item_subject, "setPaintFlags", Paint.ANTI_ALIAS_FLAG)
        }

        // Set click intent for toggle
        val intent = android.content.Intent().apply {
            putExtra("mail_id", mail.optString("id", ""))
            putExtra("task_index", position)
        }
        views.setOnClickFillInIntent(R.id.item_check, intent)
        views.setOnClickFillInIntent(R.id.item_subject, intent)
        views.setOnClickFillInIntent(R.id.item_row, intent)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = false
}

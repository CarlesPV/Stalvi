package com.peirov.stalvi

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StalviWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val incomeTitle = widgetData.getString("widget_income_title", "Income")
                setTextViewText(R.id.widget_income_title, incomeTitle)

                val incomeText = widgetData.getString("widget_income_text", "-")
                setTextViewText(R.id.widget_income_text, incomeText)

                val expenseTitle = widgetData.getString("widget_expense_title", "Expenses")
                setTextViewText(R.id.widget_expense_title, expenseTitle)

                val expenseText = widgetData.getString("widget_expense_text", "-")
                setTextViewText(R.id.widget_expense_text, expenseText)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

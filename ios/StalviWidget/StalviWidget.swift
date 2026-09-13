import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), incomeText: "0.00", expenseText: "0.00", incomeTitle: "Income", expenseTitle: "Expenses")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), incomeText: "0.00", expenseText: "0.00", incomeTitle: "Income", expenseTitle: "Expenses")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Read from UserDefaults (ensure App Group is configured if on real device)
        let userDefaults = UserDefaults(suiteName: "group.com.peirov.stalvi")
        let incomeText = userDefaults?.string(forKey: "widget_income_text") ?? "-"
        let expenseText = userDefaults?.string(forKey: "widget_expense_text") ?? "-"
        let incomeTitle = userDefaults?.string(forKey: "widget_income_title") ?? "Income"
        let expenseTitle = userDefaults?.string(forKey: "widget_expense_title") ?? "Expenses"

        let entry = SimpleEntry(date: Date(), incomeText: incomeText, expenseText: expenseText, incomeTitle: incomeTitle, expenseTitle: expenseTitle)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let incomeText: String
    let expenseText: String
    let incomeTitle: String
    let expenseTitle: String
}

struct StalviWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack {
            VStack {
                Text(entry.incomeTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.incomeText)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            
            VStack {
                Text(entry.expenseTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.expenseText)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

@main
struct StalviWidget: Widget {
    let kind: String = "StalviWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StalviWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Stalvi Widget")
        .description("Shows Income and Expenses.")
        .supportedFamilies([.systemMedium])
    }
}

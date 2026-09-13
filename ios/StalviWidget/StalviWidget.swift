import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), incomeText: "2,450.50 €", expenseText: "1,120.00 €", incomeTitle: "Monthly Income", expenseTitle: "Monthly Expenses")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), incomeText: "2,450.50 €", expenseText: "1,120.00 €", incomeTitle: "Monthly Income", expenseTitle: "Monthly Expenses")
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {
                Image("SplashIcon")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .cornerRadius(4)
                
                HStack {
                    VStack {
                        Text(entry.incomeTitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(entry.incomeText)
                            .font(.footnote)
                            .bold()
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text(entry.expenseTitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(entry.expenseText)
                            .font(.footnote)
                            .bold()
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "stalvi://home"))
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

struct StalviWidget_Previews: PreviewProvider {
    static var previews: some View {
        StalviWidgetEntryView(entry: SimpleEntry(date: Date(), incomeText: "2,450.50 €", expenseText: "1,120.00 €", incomeTitle: "Monthly Income", expenseTitle: "Monthly Expenses"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

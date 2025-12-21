import WidgetKit
import SwiftUI



struct ZealWidget: Widget {
    let kind: String = "ZealWidget"

    var body: some WidgetConfiguration {

        AppIntentConfiguration(kind: kind, intent: SelectProjectIntent.self, provider: Provider()) { entry in
            ZealWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color("WidgetBackground")
                }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Zeabur Projects")
        .description("View your recent Zeabur projects status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

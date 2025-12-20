import WidgetKit
import SwiftUI



struct ZealWidget: Widget {
    let kind: String = "ZealWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ZealWidgetEntryView(entry: entry)
                .containerBackground(Color(red: 0.1, green: 0.1, blue: 0.12), for: .widget)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Zeabur Projects")
        .description("View your recent Zeabur projects status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

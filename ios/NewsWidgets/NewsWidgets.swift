//
//  NewsWidgets.swift
//  NewsWidgets
//
//  Created by Gao on 2023/10/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NewsArticleEntry {
        NewsArticleEntry(date: Date(), title: "---", filename: "No screenshot available",  displaySize: context.displaySize)
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsArticleEntry) -> ()) {
        let entry: NewsArticleEntry
              if context.isPreview{
                entry = placeholder(in: context)
              }
              else{
                //      Get the data from the user defaults to display
                let userDefaults = UserDefaults(suiteName: "group.gsmlg.app")
                let title = userDefaults?.string(forKey: "title") ?? "No Title Set"
                let filename = userDefaults?.string(forKey: "filename") ?? "No screenshot available"
                  entry = NewsArticleEntry(date: Date(), title: title, filename: filename,  displaySize: context.displaySize)
              }
                completion(entry)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
// atEnd policy tells widgetkit to request a new entry after the date has passed
        let timeline = Timeline(entries: [entry], policy: .atEnd)
                          completion(timeline)
        }
    }
}

struct NewsArticleEntry: TimelineEntry {
    let date: Date
    let title: String
    let filename: String
    let displaySize: CGSize
}

struct NewsWidgetsEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family //<- here

    var body: some View {
        switch family {
            case .systemSmall:
                Link(destination: URL(string: "https://gsmlg.app/toolbox/whois")!, label: {
                    Text(entry.title).font(Font.custom("GSMLG", size: 18))
                })
            case .systemLarge:
                VStack{
                    Link(destination: URL(string: "https://gsmlg.app/toolbox/whois")!, label: {
                        Text(entry.title).font(Font.custom("GSMLG", size: 18))
                    })
                    Spacer()
                    Link(destination: URL(string: "https://gsmlg.org")!, label: {
                        Text("GSMLG.ORG").font(Font.custom("GSMLG", size: 18))
                    })
                    Spacer()
                    ChartImage
                }.padding()
            default:
                HStack{
                    Link(destination: URL(string: "https://gsmlg.app/service")!, label: {
                        Text(entry.title).font(Font.custom("GSMLG", size: 18))
                    })
                }
                .padding()
        }
    }

    // New: create the ChartImage view
    var ChartImage: some View {
        if let uiImage = UIImage(contentsOfFile: entry.filename) {
            let image = Image(uiImage: uiImage)
                .resizable()
                .frame(width: entry.displaySize.height*0.5, height: entry.displaySize.height*0.5, alignment: .center)
            return AnyView(image)
        }
        print("The image file could not be loaded")
        return AnyView(EmptyView())
    }

    // New: Add the helper function.
    var bundle: URL {
           let bundle = Bundle.main
           if bundle.bundleURL.pathExtension == "appex" {
               // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
               var url = bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
               url.append(component: "Frameworks/App.framework/flutter_assets")
               return url
           }
           return bundle.bundleURL
       }

    // New: Register the font.
    init(entry: Provider.Entry){
        self.entry = entry
        CTFontManagerRegisterFontsForURL(bundle.appending(path: "/fonts/GSMLG.ttf") as CFURL, CTFontManagerScope.process, nil)
    }
}

struct NewsWidgets: Widget {
    let kind: String = "NewsWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NewsWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NewsWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("GSMLG Widget")
        .description("This is GSMLG widget.")
    }
}

#Preview(as: .systemMedium) {
    NewsWidgets()
} timeline: {
    NewsArticleEntry(date: .now, title: "Loading...", filename: "No screenshot available",  displaySize: CGSize.zero)
    NewsArticleEntry(date: .now, title: "Best in the World", filename: "No screenshot available",  displaySize: CGSize.zero)
}

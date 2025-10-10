//
//  HomeScreenWidget.swift
//  HomeScreenWidget
//
//  Created by bilal çavuş on 10.10.2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(
            date: Date(),
            timerRunning: false,
            secondsRemaining: 1500,
            totalSeconds: 1500,
            isOnBreak: false,
            taskTitle: "Farmodo Timer"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
        let entry = TimerEntry(
            date: Date(),
            timerRunning: getUserData(key: "timer_running", defaultValue: false),
            secondsRemaining: getUserData(key: "seconds_remaining", defaultValue: 1500),
            totalSeconds: getUserData(key: "total_seconds", defaultValue: 1500),
            isOnBreak: getUserData(key: "is_on_break", defaultValue: false),
            taskTitle: getUserData(key: "task_title", defaultValue: "No active task")
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TimerEntry] = []
        let currentDate = Date()
        
        // Her 5 dakikada bir güncelleme için 12 entry oluştur (1 saat boyunca)
        for minuteOffset in 0 ..< 12 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 5, to: currentDate)!
            let entry = TimerEntry(
                date: entryDate,
                timerRunning: getUserData(key: "timer_running", defaultValue: false),
                secondsRemaining: getUserData(key: "seconds_remaining", defaultValue: 1500),
                totalSeconds: getUserData(key: "total_seconds", defaultValue: 1500),
                isOnBreak: getUserData(key: "is_on_break", defaultValue: false),
                taskTitle: getUserData(key: "task_title", defaultValue: "No active task")
            )
            entries.append(entry)
        }
        
        // Timeline bittiğinde tekrar güncelle
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getUserData<T>(key: String, defaultValue: T) -> T {
        let userDefaults = UserDefaults(suiteName: "group.com.bilalcavus.farmodo")
        
        if T.self == Bool.self {
            return (userDefaults?.bool(forKey: key) ?? defaultValue as! Bool) as! T
        } else if T.self == Int.self {
            return (userDefaults?.integer(forKey: key) ?? defaultValue as! Int) as! T
        } else if T.self == String.self {
            return (userDefaults?.string(forKey: key) ?? defaultValue as! String) as! T
        }
        
        return defaultValue
    }
}

struct TimerEntry: TimelineEntry {
    let date: Date
    let timerRunning: Bool
    let secondsRemaining: Int
    let totalSeconds: Int
    let isOnBreak: Bool
    let taskTitle: String
}

struct HomeScreenWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: TimerEntry
    
    var progress: Double {
        guard entry.totalSeconds > 0 else { return 0 }
        return Double(entry.totalSeconds - entry.secondsRemaining) / Double(entry.totalSeconds)
    }
    
    var timeText: String {
        let minutes = entry.secondsRemaining / 60
        let seconds = entry.secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var statusText: String {
        entry.isOnBreak ? "🌿 Break" : "🍅 Focus"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.8, blue: 0.4),
                    Color(red: 0.3, green: 0.6, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                // Status
                Text(statusText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                // Timer
                Text(timeText)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Progress Bar
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(height: 6)
                    .padding(.horizontal, 8)
                
                // Task Title
                Text(entry.taskTitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
            .padding()
        }
    }
}

struct MediumWidgetView: View {
    let entry: TimerEntry
    
    var progress: Double {
        guard entry.totalSeconds > 0 else { return 0 }
        return Double(entry.totalSeconds - entry.secondsRemaining) / Double(entry.totalSeconds)
    }
    
    var timeText: String {
        let minutes = entry.secondsRemaining / 60
        let seconds = entry.secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var statusText: String {
        entry.isOnBreak ? "🌿 Break Time" : "🍅 Focus Time"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.8, blue: 0.4),
                    Color(red: 0.3, green: 0.6, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // Left side - Timer
                VStack(spacing: 8) {
                    Text(statusText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(timeText)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .frame(height: 6)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1)
                
                // Right side - Task Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Task")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(entry.taskTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: entry.timerRunning ? "play.circle.fill" : "pause.circle.fill")
                            .foregroundColor(.white)
                        Text(entry.timerRunning ? "Running" : "Paused")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}

struct HomeScreenWidget: Widget {
    let kind: String = "HomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HomeScreenWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
            } else {
                HomeScreenWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Farmodo Timer")
        .description("Track your pomodoro sessions and tasks.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    HomeScreenWidget()
} timeline: {
    TimerEntry(date: .now, timerRunning: true, secondsRemaining: 900, totalSeconds: 1500, isOnBreak: false, taskTitle: "Study Math")
    TimerEntry(date: .now, timerRunning: false, secondsRemaining: 300, totalSeconds: 300, isOnBreak: true, taskTitle: "Study Math")
}

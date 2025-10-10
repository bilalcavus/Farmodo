//
//  HomeScreenWidgetLiveActivity.swift
//  HomeScreenWidget
//
//  Created by bilal çavuş on 10.10.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes
struct LiveActivitiesAppAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state
        var remainingSeconds: Int
        var totalSeconds: Int
        var isOnBreak: Bool
        var isPaused: Bool
    }
    
    // Fixed attributes
    var taskTitle: String
    var startTime: Int
}

// MARK: - Live Activity Widget
struct HomeScreenWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Region
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Text(context.state.isOnBreak ? "🌿" : "🍅")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.isOnBreak ? "Break" : "Focus")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(context.attributes.taskTitle)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 4) {
                        Text(context.state.timerEndDate, style: .timer)
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundColor(context.state.isOnBreak ? .green : .orange)
                        
                        if context.state.isPaused {
                            HStack(spacing: 4) {
                                Image(systemName: "pause.circle.fill")
                                    .font(.caption2)
                                Text("Paused")
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Progress Bar
                        ProgressView(value: context.state.progress) {
                            HStack {
                                Text("Progress")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(context.state.progress * 100))%")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(context.state.isOnBreak ? .green : .orange)
                        .progressViewStyle(.linear)
                    }
                }
            } compactLeading: {
                // Compact Leading (왼쪽 작은 뷰)
                Text(context.state.isOnBreak ? "🌿" : "🍅")
                    .font(.title3)
            } compactTrailing: {
                // Compact Trailing (오른쪽 작은 뷰 - Timer)
                Text(context.state.timerEndDate, style: .timer)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundColor(context.state.isOnBreak ? .green : .orange)
            } minimal: {
                // Minimal View (가장 작은 상태)
                Text(context.state.isOnBreak ? "🌿" : "🍅")
            }
            .keylineTint(context.state.isOnBreak ? .green : .orange)
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: context.state.isOnBreak ? "leaf.fill" : "timer")
                    .foregroundColor(context.state.isOnBreak ? .green : .orange)
                    .font(.title3)
                
                Text(context.state.isOnBreak ? "Break Time" : "Focus Time")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if context.state.isPaused {
                    HStack(spacing: 4) {
                        Image(systemName: "pause.circle.fill")
                        Text("Paused")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            // Timer
            HStack {
                Spacer()
                Text(context.state.timerEndDate, style: .timer)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(context.state.isOnBreak ? .green : .orange)
                Spacer()
            }
            
            // Progress Bar
            VStack(spacing: 4) {
                ProgressView(value: context.state.progress)
                    .tint(context.state.isOnBreak ? .green : .orange)
                    .frame(height: 8)
                
                HStack {
                    Text(context.attributes.taskTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .activityBackgroundTint(Color(white: 0.1).opacity(0.8))
        .activitySystemActionForegroundColor(.white)
    }
}

// MARK: - Extensions
extension LiveActivitiesAppAttributes.ContentState {
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        let elapsed = totalSeconds - remainingSeconds
        return Double(elapsed) / Double(totalSeconds)
    }
    
    var timerEndDate: Date {
        // Paused ise şu anki zamanı döndür (timer durur)
        if isPaused {
            return Date()
        }
        // Değilse kalan süre kadar gelecekteki zamanı hesapla
        return Date().addingTimeInterval(TimeInterval(remainingSeconds))
    }
}

// MARK: - Previews
#if DEBUG
@available(iOS 16.2, *)
struct LiveActivityPreviews: PreviewProvider {
    static var previews: some View {
        LiveActivitiesAppAttributes(taskTitle: "Study Math", startTime: Int(Date().timeIntervalSince1970))
            .previewContext(
                LiveActivitiesAppAttributes.ContentState(
                    remainingSeconds: 1500,
                    totalSeconds: 1500,
                    isOnBreak: false,
                    isPaused: false
                ),
                viewKind: .dynamicIsland(.compact)
            )
        
        LiveActivitiesAppAttributes(taskTitle: "Study Math", startTime: Int(Date().timeIntervalSince1970))
            .previewContext(
                LiveActivitiesAppAttributes.ContentState(
                    remainingSeconds: 900,
                    totalSeconds: 1500,
                    isOnBreak: false,
                    isPaused: false
                ),
                viewKind: .dynamicIsland(.expanded)
            )
        
        LiveActivitiesAppAttributes(taskTitle: "Take a Rest", startTime: Int(Date().timeIntervalSince1970))
            .previewContext(
                LiveActivitiesAppAttributes.ContentState(
                    remainingSeconds: 300,
                    totalSeconds: 300,
                    isOnBreak: true,
                    isPaused: false
                ),
                viewKind: .content
            )
    }
}
#endif


import ActivityKit
import WidgetKit
import SwiftUI

struct MugicLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MusicActivityAttributes.self) { context in
            // Lock Screen / StandBy banner
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - Expanded
                DynamicIslandExpandedRegion(.leading) {
                    circularMusicProgress(context: context, size: 52)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.songTitle)
                            .font(.system(size: 14, weight: .bold))
                            .lineLimit(1)
                        Text(context.state.artist)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        ProgressView(value: progress(context))
                            .tint(.purple)
                        HStack {
                            Text(formatTime(context.state.currentTime))
                                .font(.system(size: 10, weight: .medium))
                                .monospacedDigit()
                            Spacer()
                            Text("-\(formatTime(max(0, context.state.duration - context.state.currentTime)))")
                                .font(.system(size: 10, weight: .medium))
                                .monospacedDigit()
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                // Compact leading: circular music icon with progress ring
                circularMusicProgress(context: context, size: 24)
            } compactTrailing: {
                // Compact trailing: time remaining
                Text(formatTime(max(0, context.state.duration - context.state.currentTime)))
                    .font(.system(size: 12, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.8))
            } minimal: {
                // Minimal: just the circle with progress ring
                circularMusicProgress(context: context, size: 22)
            }
        }
    }

    // MARK: - Lock Screen Banner
    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<MusicActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            circularMusicProgress(context: context, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.songTitle)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                Text(context.state.artist)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }

    // MARK: - Circular Music Progress
    /// Circle with a music note inside; the outer ring shows elapsed progress
    private func circularMusicProgress(context: ActivityViewContext<MusicActivityAttributes>, size: CGFloat) -> some View {
        let lineWidth: CGFloat = size > 30 ? 3 : 2

        return ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: lineWidth)

            // Progress ring (time elapsed / duration)
            Circle()
                .trim(from: 0, to: progress(context))
                .stroke(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Music note icon
            Image(systemName: context.state.isPlaying ? "music.note" : "pause.fill")
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }

    // MARK: - Helpers
    private func progress(_ context: ActivityViewContext<MusicActivityAttributes>) -> Double {
        guard context.state.duration > 0 else { return 0 }
        return min(1.0, max(0, context.state.currentTime / context.state.duration))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let t = max(0, time)
        let minutes = Int(t) / 60
        let seconds = Int(t) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

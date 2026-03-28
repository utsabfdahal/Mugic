#if os(iOS)
import ActivityKit
import Foundation

struct MusicActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var songTitle: String
        var artist: String
        var currentTime: TimeInterval
        var duration: TimeInterval
        var isPlaying: Bool
    }

    var songId: String
}
#endif
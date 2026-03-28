import SwiftUI
import Combine

// MARK: - Player ViewModel
// Shared observable state for playback across the app
@Observable
final class PlayerViewModel {
    // Current song
    var currentSong: Song? = SampleData.songs[11] // "Neon Horizons"
    var isPlaying: Bool = false

    // Progress
    var currentTime: TimeInterval = 164 // 2:44
    var duration: TimeInterval = 252 // 4:12

    // Queue
    var queue: [Song] = SampleData.queueSongs
    var playbackHistory: [Song] = []

    // Playback modes
    var isShuffleOn: Bool = false
    var repeatMode: RepeatMode = .off

    // Mini player visibility
    var showMiniPlayer: Bool = true
    var showNowPlaying: Bool = false

    enum RepeatMode {
        case off, all, one
    }

    // MARK: - Progress
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var currentTimeString: String {
        formatTime(currentTime)
    }

    var durationString: String {
        formatTime(duration)
    }

    // MARK: - Actions
    func togglePlayPause() {
        isPlaying.toggle()
    }

    func skipNext() {
        guard !queue.isEmpty else { return }
        if let current = currentSong {
            playbackHistory.append(current)
        }
        currentSong = queue.removeFirst()
        currentTime = 0
        duration = currentSong?.duration ?? 0
    }

    func skipPrevious() {
        guard !playbackHistory.isEmpty else {
            currentTime = 0
            return
        }
        if let current = currentSong {
            queue.insert(current, at: 0)
        }
        currentSong = playbackHistory.removeLast()
        currentTime = 0
        duration = currentSong?.duration ?? 0
    }

    func playSong(_ song: Song) {
        if let current = currentSong {
            playbackHistory.append(current)
        }
        currentSong = song
        currentTime = 0
        duration = song.duration
        isPlaying = true
    }

    func addToQueue(_ song: Song) {
        queue.append(song)
    }

    func removeFromQueue(at index: Int) {
        guard queue.indices.contains(index) else { return }
        queue.remove(at: index)
    }

    func clearQueue() {
        queue.removeAll()
    }

    func toggleShuffle() {
        isShuffleOn.toggle()
        if isShuffleOn {
            queue.shuffle()
        }
    }

    func cycleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    // MARK: - Helpers
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

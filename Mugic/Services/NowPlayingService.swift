#if os(iOS)
import Foundation
import MediaPlayer
import UIKit
import AVFoundation

final class NowPlayingService {
    static let shared = NowPlayingService()

    nonisolated(unsafe) var onPlay: (() -> Void)?
    nonisolated(unsafe) var onPause: (() -> Void)?
    nonisolated(unsafe) var onTogglePlayPause: (() -> Void)?
    nonisolated(unsafe) var onSkipNext: (() -> Void)?
    nonisolated(unsafe) var onSkipPrevious: (() -> Void)?
    nonisolated(unsafe) var onSeek: ((TimeInterval) -> Void)?

    private init() {
        setupRemoteCommands()
    }

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.playCommand.addTarget { [weak self] _ in
            self?.onPlay?()
            return .success
        }

        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { [weak self] _ in
            self?.onPause?()
            return .success
        }

        center.togglePlayPauseCommand.isEnabled = true
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.onTogglePlayPause?()
            return .success
        }

        center.nextTrackCommand.isEnabled = true
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.onSkipNext?()
            return .success
        }

        center.previousTrackCommand.isEnabled = true
        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.onSkipPrevious?()
            return .success
        }

        center.changePlaybackPositionCommand.isEnabled = true
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.onSeek?(event.positionTime)
            return .success
        }
    }

    func update(title: String, artist: String, album: String, duration: TimeInterval, currentTime: TimeInterval, isPlaying: Bool, artwork: UIImage? = nil) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyAlbumTitle: album,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let image = artwork {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func clear() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    static func loadArtwork(from url: URL) async -> UIImage? {
        let asset = AVURLAsset(url: url)
        guard let metadata = try? await asset.load(.metadata) else { return nil }
        for item in metadata {
            if item.commonKey == .commonKeyArtwork,
               let data = try? await item.load(.dataValue),
               let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }
}
#endif

import Foundation
import AVFoundation

@Observable
final class AudioPlayerService: NSObject {
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?

    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var isPlaying: Bool = false
    var volume: Float = 0.7

    var onSongFinished: (() -> Void)?

    override init() {
        super.init()
        #if os(iOS)
        configureAudioSession()
        #endif
    }

    #if os(iOS)
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .ended {
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resume()
                }
            }
        }
    }
    #endif

    func play(url: URL) {
        stop()
        do {
            let ext = url.pathExtension.lowercased()
            let typeHint: AVFileType? = switch ext {
            case "mp3": .mp3
            case "m4a", "aac": .m4a
            case "wav": .wav
            case "aiff", "aif": .aiff
            case "caf": .caf
            default: nil
            }
            if let typeHint {
                audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: typeHint.rawValue)
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            audioPlayer?.delegate = self
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            duration = audioPlayer?.duration ?? 0
            isPlaying = true
            startProgressTimer()
        } catch {
            print("Playback error: \(error)")
            isPlaying = false
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startProgressTimer()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        stopProgressTimer()
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    func setVolume(_ newVolume: Float) {
        volume = newVolume
        audioPlayer?.volume = newVolume
    }

    var hasAudioLoaded: Bool {
        audioPlayer != nil
    }

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopProgressTimer()
        onSongFinished?()
    }
}

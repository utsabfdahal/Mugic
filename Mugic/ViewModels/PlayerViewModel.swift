import SwiftUI
import Combine
#if os(iOS)
import ActivityKit
#endif

@Observable
final class PlayerViewModel {
    // Audio service
    private let audioService = AudioPlayerService()

    // Current song
    var currentSong: Song? = SampleData.songs[11] // "Neon Horizons"
    var isPlaying: Bool = false

    // Progress
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 252

    // Seeking
    var isSeeking: Bool = false
    var seekTime: TimeInterval = 0

    // Volume (0…1)
    var volume: Double = 0.7

    // Queue
    var queue: [Song] = SampleData.queueSongs
    var playbackHistory: [Song] = []

    // Playback modes
    var isShuffleOn: Bool = false
    var repeatMode: RepeatMode = .off

    // Mini player visibility
    var showMiniPlayer: Bool = true
    var showNowPlaying: Bool = false

    // Simulation timer (sample songs without file)
    private var simulationTimer: Timer?

    // Media integration
    #if os(iOS)
    private var artworkImage: UIImage?
    private var liveActivityUpdateCounter: Int = 0
    #endif
    #if os(iOS)
    private var liveActivity: Activity<MusicActivityAttributes>?
    #endif

    enum RepeatMode {
        case off, all, one
    }

    init() {
        audioService.onSongFinished = { [weak self] in
            self?.handleSongFinished()
        }
        duration = currentSong?.duration ?? 0
        #if os(iOS)
        setupNowPlayingService()
        #endif
    }

    // MARK: - Progress
    var progress: Double {
        guard duration > 0 else { return 0 }
        return (isSeeking ? seekTime : currentTime) / duration
    }

    var displayTime: TimeInterval {
        isSeeking ? seekTime : currentTime
    }

    var currentTimeString: String {
        formatTime(displayTime)
    }

    var durationString: String {
        formatTime(duration)
    }

    // MARK: - Play / Pause
    func togglePlayPause() {
        if isPlaying { pause() } else { play() }
        HapticService.light()
    }

    private func play() {
        guard let song = currentSong else { return }
        if let url = song.fileURL {
            if audioService.hasAudioLoaded {
                audioService.resume()
            } else {
                audioService.play(url: url)
                duration = audioService.duration > 0 ? audioService.duration : song.duration
            }
        }
        // Always start simulation timer for progress (works for both real & sample)
        startSimulationTimer()
        isPlaying = true
        updateMediaIntegration()
    }

    private func pause() {
        if audioService.hasAudioLoaded {
            audioService.pause()
        }
        stopSimulationTimer()
        isPlaying = false
        updateMediaIntegration()
    }

    // MARK: - Skip
    func skipNext() {
        HapticService.medium()
        if repeatMode == .one, currentSong != nil {
            seek(to: 0)
            if !isPlaying { play() }
            return
        }
        guard !queue.isEmpty else {
            if repeatMode == .all, !playbackHistory.isEmpty {
                queue = playbackHistory
                playbackHistory = []
                skipNext()
            }
            return
        }
        if let current = currentSong {
            playbackHistory.append(current)
        }
        currentSong = queue.removeFirst()
        startPlayback()
    }

    func skipPrevious() {
        HapticService.medium()
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        guard !playbackHistory.isEmpty else {
            seek(to: 0)
            return
        }
        if let current = currentSong {
            queue.insert(current, at: 0)
        }
        currentSong = playbackHistory.removeLast()
        startPlayback()
    }

    // MARK: - Play Song / Playlist
    func playSong(_ song: Song) {
        if let current = currentSong {
            playbackHistory.append(current)
        }
        currentSong = song
        startPlayback()
        HapticService.light()
    }

    func playPlaylist(_ songs: [Song], startAt index: Int = 0) {
        guard !songs.isEmpty else { return }
        let song = songs[index]
        var remaining = Array(songs)
        remaining.remove(at: index)
        if isShuffleOn { remaining.shuffle() }
        queue = remaining
        if let current = currentSong {
            playbackHistory.append(current)
        }
        currentSong = song
        startPlayback()
    }

    func shufflePlay(_ songs: [Song]) {
        var shuffled = songs
        shuffled.shuffle()
        isShuffleOn = true
        playPlaylist(shuffled)
    }

    private func startPlayback() {
        audioService.stop()
        stopSimulationTimer()
        guard let song = currentSong else { return }
        currentTime = 0
        duration = song.duration

        if let url = song.fileURL {
            audioService.play(url: url)
            if audioService.duration > 0 { duration = audioService.duration }
        }
        audioService.setVolume(Float(volume))
        startSimulationTimer()
        isPlaying = true
        showMiniPlayer = true
        startMediaIntegration()
    }

    // MARK: - Seek
    func beginSeeking() {
        isSeeking = true
        seekTime = currentTime
    }

    func updateSeek(to progress: Double) {
        seekTime = duration * max(0, min(1, progress))
    }

    func endSeeking() {
        seek(to: seekTime)
        isSeeking = false
    }

    func seek(to time: TimeInterval) {
        currentTime = time
        if audioService.hasAudioLoaded {
            audioService.seek(to: time)
        }
        updateMediaIntegration()
    }

    // MARK: - Volume
    func setVolume(_ newVolume: Double) {
        volume = newVolume
        audioService.setVolume(Float(newVolume))
    }

    // MARK: - Queue
    func addToQueue(_ song: Song) {
        queue.append(song)
        HapticService.light()
    }

    func removeFromQueue(at index: Int) {
        guard queue.indices.contains(index) else { return }
        _ = withAnimation(.easeOut(duration: 0.2)) {
            queue.remove(at: index)
        }
        HapticService.light()
    }

    func moveQueueItem(from source: IndexSet, to destination: Int) {
        queue.move(fromOffsets: source, toOffset: destination)
        HapticService.selection()
    }

    func clearQueue() {
        withAnimation(.easeOut(duration: 0.25)) {
            queue.removeAll()
        }
        HapticService.medium()
    }

    func toggleShuffle() {
        isShuffleOn.toggle()
        if isShuffleOn { queue.shuffle() }
        HapticService.light()
    }

    func cycleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
        HapticService.light()
    }

    // MARK: - Song Finished
    private func handleSongFinished() {
        switch repeatMode {
        case .one:
            seek(to: 0)
            play()
        case .all:
            if queue.isEmpty, !playbackHistory.isEmpty {
                queue = playbackHistory
                playbackHistory = []
            }
            if !queue.isEmpty { skipNext() } else { isPlaying = false; stopSimulationTimer(); stopMediaIntegration() }
        case .off:
            if !queue.isEmpty { skipNext() } else { isPlaying = false; stopSimulationTimer(); stopMediaIntegration() }
        }
    }

    // MARK: - Simulation Timer
    private func startSimulationTimer() {
        stopSimulationTimer()
        #if os(iOS)
        liveActivityUpdateCounter = 0
        #endif
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, self.isPlaying, !self.isSeeking else { return }
            if self.audioService.hasAudioLoaded {
                self.currentTime = self.audioService.currentTime
            } else {
                self.currentTime += 0.25
                if self.currentTime >= self.duration {
                    self.stopSimulationTimer()
                    self.handleSongFinished()
                }
            }
            #if os(iOS)
            self.liveActivityUpdateCounter += 1
            if self.liveActivityUpdateCounter % 40 == 0 { // every 10 seconds
                self.updateMediaIntegration()
            }
            #endif
        }
    }

    private func stopSimulationTimer() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    // MARK: - Helpers
    private func formatTime(_ time: TimeInterval) -> String {
        let t = max(0, time)
        let minutes = Int(t) / 60
        let seconds = Int(t) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Media Integration (Lock Screen + Live Activity)
    private func startMediaIntegration() {
        #if os(iOS)
        loadAndCacheArtwork()
        updateNowPlaying()
        #endif
        #if os(iOS)
        startLiveActivity()
        #endif
    }

    private func updateMediaIntegration() {
        #if os(iOS)
        updateNowPlaying()
        #endif
        #if os(iOS)
        updateLiveActivity()
        #endif
    }

    private func stopMediaIntegration() {
        #if os(iOS)
        NowPlayingService.shared.clear()
        #endif
        #if os(iOS)
        endLiveActivity()
        #endif
    }

    // MARK: - Now Playing (Lock Screen / Control Center)
    #if os(iOS)
    private func setupNowPlayingService() {
        let service = NowPlayingService.shared
        service.onPlay = { [weak self] in
            Task { @MainActor in self?.play() }
        }
        service.onPause = { [weak self] in
            Task { @MainActor in self?.pause() }
        }
        service.onTogglePlayPause = { [weak self] in
            Task { @MainActor in self?.togglePlayPause() }
        }
        service.onSkipNext = { [weak self] in
            Task { @MainActor in self?.skipNext() }
        }
        service.onSkipPrevious = { [weak self] in
            Task { @MainActor in self?.skipPrevious() }
        }
        service.onSeek = { [weak self] time in
            Task { @MainActor in self?.seek(to: time) }
        }
    }

    private func updateNowPlaying() {
        guard let song = currentSong else { return }
        NowPlayingService.shared.update(
            title: song.title,
            artist: song.artist,
            album: song.album,
            duration: duration,
            currentTime: currentTime,
            isPlaying: isPlaying,
            artwork: artworkImage
        )
    }

    private func loadAndCacheArtwork() {
        guard let url = currentSong?.fileURL else {
            artworkImage = nil
            return
        }
        Task {
            let image = await NowPlayingService.loadArtwork(from: url)
            artworkImage = image
            updateNowPlaying()
        }
    }
    #endif

    // MARK: - Live Activity (Dynamic Island)
    #if os(iOS)
    private var currentActivityState: MusicActivityAttributes.ContentState {
        MusicActivityAttributes.ContentState(
            songTitle: currentSong?.title ?? "",
            artist: currentSong?.artist ?? "",
            currentTime: currentTime,
            duration: duration,
            isPlaying: isPlaying
        )
    }

    private func startLiveActivity() {
        // End any existing activity first
        if liveActivity != nil { endLiveActivity() }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = MusicActivityAttributes(songId: currentSong?.id ?? "")
        let content = ActivityContent(state: currentActivityState, staleDate: Date().addingTimeInterval(15))

        do {
            liveActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            // Silently ignore – Live Activities may not be supported on all devices
        }
    }

    private func updateLiveActivity() {
        guard let activity = liveActivity else { return }
        let state = currentActivityState
        Task {
            await activity.update(
                ActivityContent(state: state, staleDate: Date().addingTimeInterval(15))
            )
        }
    }

    private func endLiveActivity() {
        guard let activity = liveActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        liveActivity = nil
    }
    #endif
}

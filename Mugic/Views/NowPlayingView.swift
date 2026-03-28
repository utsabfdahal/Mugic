import SwiftUI

// MARK: - Now Playing View
struct NowPlayingView: View {
    @Environment(PlayerViewModel.self) private var player
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Blurred background
            backgroundLayer

            // Content
            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()

                // Hero album art
                albumArtSection
                    .padding(.horizontal, 24)

                Spacer()

                // Song metadata
                metadataSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                // Progress bar
                progressSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                // Playback controls
                controlsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                // Lyrics sheet trigger
                lyricsButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.sonicBackground)
    }

    // MARK: - Background
    private var backgroundLayer: some View {
        ZStack {
            if let song = player.currentSong {
                SongArtwork(artworkName: song.artworkName, size: 500)
                    .opacity(0.3)
                    .blur(radius: 100)
                    .scaleEffect(1.1)
            }
            LinearGradient(
                colors: [
                    Color.sonicBackground.opacity(0.4),
                    Color.sonicBackground.opacity(0.8),
                    Color.sonicBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("PLAYING FROM PLAYLIST")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color.sonicOnSurfaceVariant)

                Text("Midnight City Vibes")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.sonicIndigo500)
            }

            Spacer()

            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
            }
        }
    }

    // MARK: - Album Art
    private var albumArtSection: some View {
        Group {
            if let song = player.currentSong {
                SongArtwork(artworkName: song.artworkName, size: 320)
                    .shadow(color: .black.opacity(0.5), radius: 30, y: 15)
            }
        }
    }

    // MARK: - Metadata
    private var metadataSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text(player.currentSong?.title ?? "")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(-0.5)

                Text(player.currentSong?.artist ?? "")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.sonicPrimary)

                if let song = player.currentSong {
                    Text("Album: \(song.album)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                }
            }

            Spacer()

            HStack(spacing: 16) {
                Button { } label: {
                    Image(systemName: "heart")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                }

                Button { } label: {
                    Image(systemName: "text.badge.plus")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                }
            }
        }
    }

    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 8) {
            // Seek bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.sonicSurfaceContainerHighest)
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.sonicPrimary, Color.sonicPrimaryDim],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * player.progress, height: 4)
                        .shadow(color: Color.sonicPrimary.opacity(0.4), radius: 8)
                }
            }
            .frame(height: 4)

            // Time labels
            HStack {
                Text(player.currentTimeString)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .monospacedDigit()

                Spacer()

                Text(player.durationString)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Controls
    private var controlsSection: some View {
        HStack {
            // Shuffle
            Button { player.toggleShuffle() } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 20))
                    .foregroundStyle(player.isShuffleOn ? Color.sonicPrimary : Color.sonicOnSurfaceVariant)
            }

            Spacer()

            HStack(spacing: 32) {
                // Previous
                Button { player.skipPrevious() } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }

                // Play/Pause
                Button { player.togglePlayPause() } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.black)
                        .frame(width: 72, height: 72)
                        .background(Color.sonicPrimary)
                        .clipShape(Circle())
                        .shadow(color: Color.sonicPrimary.opacity(0.3), radius: 20, y: 10)
                }

                // Next
                Button { player.skipNext() } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            // Repeat
            Button { player.cycleRepeatMode() } label: {
                Image(systemName: repeatIcon)
                    .font(.system(size: 20))
                    .foregroundStyle(player.repeatMode != .off ? Color.sonicPrimary : Color.sonicOnSurfaceVariant)
            }
        }
    }

    private var repeatIcon: String {
        switch player.repeatMode {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    // MARK: - Lyrics Button
    private var lyricsButton: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.sonicSurfaceContainerHighest)
                .frame(width: 48, height: 4)

            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.sonicPrimary)

                    Text("LYRICS")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "chevron.up")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
            }
            .padding(20)
            .background(Color.sonicSurfaceContainer.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

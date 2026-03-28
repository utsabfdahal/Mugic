import SwiftUI

// MARK: - Song Row
// Reusable track list item used in Home, Playlist, Search, Queue views
struct SongRow: View {
    let song: Song
    let showDuration: Bool
    var onTap: (() -> Void)? = nil

    init(song: Song, showDuration: Bool = true, onTap: (() -> Void)? = nil) {
        self.song = song
        self.showDuration = showDuration
        self.onTap = onTap
    }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 12) {
                // Album art thumbnail
                artworkView
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Song info
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(song.artist)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if showDuration {
                    Text(song.durationString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                        .monospacedDigit()
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var artworkView: some View {
        // Placeholder gradient artwork
        SongArtwork(artworkName: song.artworkName, size: 56)
    }
}

// MARK: - Song Artwork
// Generates a deterministic gradient from the artwork name as placeholder
struct SongArtwork: View {
    let artworkName: String
    let size: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors(for: artworkName),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "music.note")
                .font(.system(size: size * 0.3))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size > 100 ? 16 : 8))
    }

    private func gradientColors(for name: String) -> [Color] {
        let hash = abs(name.hashValue)
        let palettes: [[Color]] = [
            [Color(hex: "8a4cfc"), Color(hex: "49339d")],
            [Color(hex: "bd9dff"), Color(hex: "8a4cfc")],
            [Color(hex: "ff8ed2"), Color(hex: "8a4cfc")],
            [Color(hex: "6366f1"), Color(hex: "8a4cfc")],
            [Color(hex: "a28efc"), Color(hex: "49339d")],
            [Color(hex: "ef81c4"), Color(hex: "701455")],
            [Color(hex: "ffa5d9"), Color(hex: "a28efc")],
            [Color(hex: "b28cff"), Color(hex: "3c0089")],
        ]
        return palettes[hash % palettes.count]
    }
}

// MARK: - Album Card
// Horizontal scrolling album card used in Recently Played
struct AlbumCard: View {
    let album: Album
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                SongArtwork(artworkName: album.artworkName, size: 160)

                Text(album.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(album.artist)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .lineLimit(1)
            }
            .frame(width: 160)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mini Player Bar
// Floating glassmorphism now-playing bar
struct MiniPlayerBar: View {
    @Environment(PlayerViewModel.self) private var player

    var body: some View {
        if let song = player.currentSong, player.showMiniPlayer {
            Button {
                player.showNowPlaying = true
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        SongArtwork(artworkName: song.artworkName, size: 48)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(song.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(song.artist)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.sonicOnSurfaceVariant)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 16) {
                            Button { player.skipPrevious() } label: {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            Button { player.togglePlayPause() } label: {
                                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.black)
                                    .frame(width: 40, height: 40)
                                    .background(Color.sonicPrimary)
                                    .clipShape(Circle())
                                    .shadow(color: Color.sonicPrimary.opacity(0.4), radius: 8)
                            }

                            Button { player.skipNext() } label: {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(12)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.white.opacity(0.1))
                            Rectangle()
                                .fill(Color.sonicPrimary)
                                .frame(width: geo.size.width * player.progress)
                                .shadow(color: Color.sonicPrimary.opacity(0.6), radius: 4)
                        }
                    }
                    .frame(height: 2)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.sonicSurfaceVariant.opacity(0.6))
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Quick Access Tile
struct QuickAccessTile: View {
    let item: QuickAccessItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)

            Spacer()

            Text(item.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.sonicSurfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var iconColor: Color {
        switch item.color {
        case "primary": return .sonicPrimary
        case "secondary": return .sonicSecondary
        case "tertiary": return .sonicTertiary
        default: return .sonicOnSurfaceVariant
        }
    }
}

// MARK: - Queue Item Row
struct QueueItemRow: View {
    let song: Song
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            SongArtwork(artworkName: song.artworkName, size: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
            }

            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
        }
        .padding(12)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}

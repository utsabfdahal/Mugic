import SwiftUI
import AVFoundation

// MARK: - Song Row
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
                SongArtwork(artworkName: song.artworkName, size: 56, fileURL: song.fileURL)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.sonicOnSurface)
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
}

// MARK: - Song Artwork
struct SongArtwork: View {
    let artworkName: String
    let size: CGFloat
    var fileURL: URL? = nil

    @State private var loadedImage: Image?

    var body: some View {
        ZStack {
            if let loadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
            } else {
                LinearGradient(
                    colors: gradientColors(for: artworkName),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size > 100 ? 16 : 8))
        .task(id: fileURL) {
            if let fileURL {
                loadedImage = await Self.loadArtwork(from: fileURL)
            }
        }
    }

    private func gradientColors(for name: String) -> [Color] {
        let hash = abs(name.hashValue)
        let palettes: [[Color]] = [
            [Color(hex: "e05549"), Color(hex: "7a4220")],
            [Color(hex: "ff8a80"), Color(hex: "c43e3e")],
            [Color(hex: "ffb74d"), Color(hex: "c43e3e")],
            [Color(hex: "d65a5a"), Color(hex: "8b3a3a")],
            [Color(hex: "e8a97a"), Color(hex: "7a4220")],
            [Color(hex: "cf6655"), Color(hex: "5c1a1a")],
            [Color(hex: "ffab91"), Color(hex: "d65a5a")],
            [Color(hex: "ff6e6e"), Color(hex: "3b0000")],
        ]
        return palettes[hash % palettes.count]
    }

    static func loadArtwork(from url: URL) async -> Image? {
        let asset = AVURLAsset(url: url)
        guard let metadata = try? await asset.load(.metadata) else { return nil }
        for item in metadata {
            if item.commonKey == .commonKeyArtwork,
               let data = try? await item.load(.dataValue) {
                #if canImport(UIKit)
                if let uiImage = UIImage(data: data) {
                    return Image(uiImage: uiImage)
                }
                #elseif canImport(AppKit)
                if let nsImage = NSImage(data: data) {
                    return Image(nsImage: nsImage)
                }
                #endif
            }
        }
        return nil
    }
}

// MARK: - Album Card
struct AlbumCard: View {
    let album: Album
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                SongArtwork(artworkName: album.artworkName, size: 160)

                Text(album.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.sonicOnSurface)
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
struct MiniPlayerBar: View {
    @Environment(PlayerViewModel.self) private var player

    var body: some View {
        if let song = player.currentSong, player.showMiniPlayer {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    player.showNowPlaying = true
                }
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        SongArtwork(artworkName: song.artworkName, size: 48, fileURL: song.fileURL)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(song.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.sonicOnSurface)
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
                                    .foregroundStyle(.sonicOnSurface.opacity(0.6))
                            }

                            Button { player.togglePlayPause() } label: {
                                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.sonicOnPrimary)
                                    .frame(width: 40, height: 40)
                                    .background(Color.sonicPrimary)
                                    .clipShape(Circle())
                                    .shadow(color: Color.sonicPrimary.opacity(0.4), radius: 8)
                                    .contentTransition(.symbolEffect(.replace))
                            }

                            Button { player.skipNext() } label: {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.sonicOnSurface.opacity(0.6))
                            }
                        }
                    }
                    .padding(12)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.sonicOnSurface.opacity(0.1))
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
                                .fill(Color.sonicGlassTint.opacity(0.6))
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
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
                .foregroundStyle(.sonicOnSurface)
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
            SongArtwork(artworkName: song.artworkName, size: 48, fileURL: song.fileURL)

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.sonicOnSurface)
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

// MARK: - Add to Playlist Sheet
struct AddToPlaylistSheet: View {
    @Environment(LibraryViewModel.self) private var library
    @Environment(\.dismiss) private var dismiss
    let song: Song

    var body: some View {
        NavigationStack {
            List {
                if library.playlists.isEmpty {
                    Text("No playlists yet")
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                } else {
                    ForEach(library.playlists) { playlist in
                        Button {
                            library.addSongToPlaylist(song, playlist: playlist)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                SongArtwork(artworkName: playlist.artworkName, size: 44)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(playlist.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.sonicOnSurface)
                                    Text("\(playlist.trackCount) tracks")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                                }

                                Spacer()

                                if playlist.songs.contains(where: { $0.id == song.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.sonicPrimary)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Add to Playlist")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .background(Color.sonicBackground)
        }
    }
}

// MARK: - Create Playlist Sheet
struct CreatePlaylistSheet: View {
    @Environment(LibraryViewModel.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Playlist Name") {
                    TextField("Enter name", text: $name)
                }
                Section("Description") {
                    TextField("Enter description", text: $description)
                }
            }
            .navigationTitle("New Playlist")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        library.createPlaylist(name: name, description: description)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

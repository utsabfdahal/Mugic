import SwiftUI

// MARK: - Playlist View
struct PlaylistView: View {
    @Environment(PlayerViewModel.self) private var player
    let playlist: Playlist

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Hero Header
                heroHeader
                    .padding(.bottom, 32)

                // Action buttons
                actionButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                // Track count
                trackHeader
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Track list
                trackList
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
            }
        }
        .background(Color.sonicBackground)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(spacing: 24) {
            // Artwork
            ZStack {
                // Glow
                SongArtwork(artworkName: playlist.artworkName, size: 240)
                    .blur(radius: 40)
                    .opacity(0.3)
                    .scaleEffect(1.2)

                SongArtwork(artworkName: playlist.artworkName, size: 260)
                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    .rotationEffect(.degrees(1))
            }

            // Playlist info
            VStack(spacing: 8) {
                Text(playlist.name)
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(-1)
                    .multilineTextAlignment(.center)

                Text(playlist.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                if let first = playlist.songs.first {
                    player.playSong(first)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                    Text("Play")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.sonicPrimaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.sonicPrimary.opacity(0.2), radius: 12)
            }

            Button {
                // Shuffle play
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 16))
                    Text("Shuffle")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.sonicSurfaceBright)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.sonicOutlineVariant.opacity(0.15), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Track Header
    private var trackHeader: some View {
        HStack {
            Text("\(playlist.trackCount) Tracks")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                // Add song
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 12))
                    Text("Add Song")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(Color.sonicPrimary)
            }
        }
    }

    // MARK: - Track List
    private var trackList: some View {
        LazyVStack(spacing: 2) {
            ForEach(playlist.songs) { song in
                PlaylistTrackRow(song: song) {
                    player.playSong(song)
                }
            }
        }
    }
}

// MARK: - Playlist Track Row
struct PlaylistTrackRow: View {
    let song: Song
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 16) {
                SongArtwork(artworkName: song.artworkName, size: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(song.artist)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(song.durationString)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .monospacedDigit()
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

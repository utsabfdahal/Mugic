import SwiftUI

// MARK: - Playlist View
struct PlaylistView: View {
    @Environment(PlayerViewModel.self) private var player
    @Environment(LibraryViewModel.self) private var library
    let playlistID: String

    private var playlist: Playlist {
        library.playlistForID(playlistID) ?? Playlist(id: playlistID, name: "Unknown", description: "", artworkName: "placeholder", songs: [])
    }

    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroHeader
                    .padding(.bottom, 32)

                actionButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                trackHeader
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                trackList
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
            }
        }
        .background(Color.sonicBackground)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        renameText = playlist.name
                        showRenameAlert = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Playlist", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                }
            }
        }
        .alert("Rename Playlist", isPresented: $showRenameAlert) {
            TextField("Playlist name", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                library.renamePlaylist(playlist, to: renameText)
            }
        }
        .alert("Delete Playlist?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                library.deletePlaylist(playlist)
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(spacing: 24) {
            ZStack {
                SongArtwork(artworkName: playlist.artworkName, size: 240)
                    .blur(radius: 40)
                    .opacity(0.3)
                    .scaleEffect(1.2)

                SongArtwork(artworkName: playlist.artworkName, size: 260)
                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                    .rotationEffect(.degrees(1))
            }

            VStack(spacing: 8) {
                Text(playlist.name)
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.sonicOnSurface)
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
                if !playlist.songs.isEmpty {
                    player.playPlaylist(playlist.songs)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                    Text("Play")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.sonicOnPrimary)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.sonicPrimaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.sonicPrimary.opacity(0.2), radius: 12)
            }

            Button {
                player.shufflePlay(playlist.songs)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 16))
                    Text("Shuffle")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.sonicOnSurface)
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
                .foregroundStyle(.sonicOnSurface)

            Spacer()

            Button {
                // Show all songs to pick from
                library.songToAddToPlaylist = nil // reset
                showSongPicker = true
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

    @State private var showSongPicker = false

    // MARK: - Track List
    private var trackList: some View {
        VStack(spacing: 0) {
            LazyVStack(spacing: 2) {
                ForEach(playlist.songs) { song in
                    PlaylistTrackRow(song: song) {
                        player.playSong(song)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                library.removeSongFromPlaylist(song, playlist: playlist)
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button {
                            player.addToQueue(song)
                        } label: {
                            Label("Add to Queue", systemImage: "text.badge.plus")
                        }
                        Button {
                            library.toggleFavorite(song)
                        } label: {
                            Label(
                                library.isFavorite(song) ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: library.isFavorite(song) ? "heart.slash" : "heart"
                            )
                        }
                        Button(role: .destructive) {
                            library.removeSongFromPlaylist(song, playlist: playlist)
                        } label: {
                            Label("Remove from Playlist", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSongPicker) {
            SongPickerSheet(playlistID: playlistID)
        }
    }
}

// MARK: - Song Picker Sheet
struct SongPickerSheet: View {
    @Environment(LibraryViewModel.self) private var library
    @Environment(\.dismiss) private var dismiss
    let playlistID: String
    @State private var searchText = ""

    private var playlist: Playlist? {
        library.playlistForID(playlistID)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredSongs) { song in
                    Button {
                        if let pl = playlist {
                            library.addSongToPlaylist(song, playlist: pl)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            SongArtwork(artworkName: song.artworkName, size: 44, fileURL: song.fileURL)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.sonicOnSurface)
                                Text(song.artist)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                            }

                            Spacer()

                            if playlist?.songs.contains(where: { $0.id == song.id }) == true {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.sonicPrimary)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search songs")
            .navigationTitle("Add Songs")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var filteredSongs: [Song] {
        library.searchSongs(query: searchText)
    }
}

// MARK: - Playlist Track Row
struct PlaylistTrackRow: View {
    let song: Song
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 16) {
                SongArtwork(artworkName: song.artworkName, size: 48, fileURL: song.fileURL)

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.sonicOnSurface)
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

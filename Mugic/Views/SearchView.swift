import SwiftUI

// MARK: - Search View
struct SearchView: View {
    @Environment(PlayerViewModel.self) private var player
    @Environment(LibraryViewModel.self) private var library
    @State private var searchText = ""
    @State private var selectedFilter = "Recent"
    @State private var selectedTab = "Songs"

    private let filters = SampleData.searchFilters
    private let tabs = ["Songs", "Artists", "Albums", "Playlists"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                searchSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                filterChips
                    .padding(.bottom, 16)

                tabBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                resultsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
            }
        }
        .background(Color.sonicBackground)
    }

    // MARK: - Search Section
    private var searchSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundStyle(Color.sonicPrimary)

            TextField("Artists, songs, or podcasts", text: $searchText)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.sonicOnSurface)
        }
        .padding(20)
        .background(Color.sonicSurfaceContainer)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }

    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                        HapticService.selection()
                    } label: {
                        Text(filter)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(
                                selectedFilter == filter
                                    ? Color.sonicOnPrimary
                                    : Color.sonicOnSurfaceVariant
                            )
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                selectedFilter == filter
                                    ? Color.sonicPrimaryContainer
                                    : Color.sonicSurfaceBright
                            )
                            .clipShape(Capsule())
                            .overlay(
                                selectedFilter != filter
                                    ? Capsule().stroke(Color.sonicOutlineVariant.opacity(0.1), lineWidth: 1)
                                    : nil
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 24) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                    HapticService.selection()
                } label: {
                    VStack(spacing: 12) {
                        Text(tab)
                            .font(.system(size: 14, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundStyle(
                                selectedTab == tab
                                    ? Color.sonicPrimary
                                    : Color.sonicOnSurfaceVariant
                            )
                            .tracking(0.5)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.sonicPrimary : .clear)
                            .frame(height: 2)
                    }
                }
            }

            Spacer()
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.sonicOutlineVariant.opacity(0.1))
                .frame(height: 1)
        }
    }

    // MARK: - Results
    private var resultsSection: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case "Songs":
                songResults
            case "Artists":
                artistResults
            case "Albums":
                albumResults
            case "Playlists":
                playlistResults
            default:
                songResults
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }

    // MARK: - Song Results
    private var songResults: some View {
        VStack(spacing: 4) {
            ForEach(library.searchSongs(query: searchText)) { song in
                searchResultRow(song: song)
            }

            if !searchText.isEmpty || selectedFilter != "Recent" {
                artistHighlight
            }
        }
    }

    private func searchResultRow(song: Song) -> some View {
        HStack(spacing: 16) {
            SongArtwork(artworkName: song.artworkName, size: 56, fileURL: song.fileURL)

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.sonicOnSurface)
                    .lineLimit(1)

                Text("\(song.artist) • \(song.durationString)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                Button {
                    library.toggleFavorite(song)
                } label: {
                    Image(systemName: library.isFavorite(song) ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(library.isFavorite(song) ? Color.sonicTertiary : Color.sonicOnSurfaceVariant)
                        .contentTransition(.symbolEffect(.replace))
                }

                Button {
                    library.songToAddToPlaylist = song
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                }
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            player.playSong(song)
        }
    }

    // MARK: - Artist Results
    private var artistResults: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
            ForEach(library.searchArtists(query: searchText)) { artist in
                artistCard(artist)
            }
        }
    }

    // MARK: - Album Results
    private var albumResults: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
            ForEach(library.searchAlbums(query: searchText)) { album in
                AlbumCard(album: album) {
                    player.playPlaylist(album.songs)
                }
            }
        }
    }

    // MARK: - Playlist Results
    private var playlistResults: some View {
        LazyVStack(spacing: 8) {
            ForEach(library.searchPlaylists(query: searchText)) { playlist in
                HStack(spacing: 16) {
                    SongArtwork(artworkName: playlist.artworkName, size: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(playlist.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.sonicOnSurface)
                            .lineLimit(1)

                        Text("\(playlist.trackCount) tracks • \(playlist.description)")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.sonicOnSurfaceVariant)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button {
                        if !playlist.songs.isEmpty {
                            player.playPlaylist(playlist.songs)
                        }
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.sonicPrimary)
                    }
                }
                .padding(12)
                .contentShape(Rectangle())
            }
        }
    }

    private var artistHighlight: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Top Artists")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.sonicOnSurface)
                .padding(.top, 24)

            HStack(spacing: 24) {
                ForEach(SampleData.artists.prefix(2)) { artist in
                    artistCard(artist)
                }
            }
        }
    }

    private func artistCard(_ artist: Artist) -> some View {
        VStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.sonicSurfaceContainerHigh, Color.sonicSurfaceVariant],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.sonicOnSurfaceVariant.opacity(0.5))
                )
                .overlay(
                    Circle().stroke(Color.sonicSurfaceContainerHigh, lineWidth: 4)
                )

            Text(artist.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.sonicOnSurface)
                .lineLimit(1)

            Text(artist.genre)
                .font(.system(size: 12))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
        }
    }
}

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Main Tab View
struct MainTabView: View {
    @Environment(PlayerViewModel.self) private var player
    @Environment(LibraryViewModel.self) private var library
    @Environment(SettingsViewModel.self) private var settings
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home, search, library, settings

        var title: String { rawValue.capitalized }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .library: return "music.note.list"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .search:
                        SearchView()
                    case .library:
                        libraryView
                    case .settings:
                        SettingsView()
                    }
                }
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarLeading) {
                        topBarLeading
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        topBarTrailing
                    }
                    #else
                    ToolbarItem(placement: .automatic) {
                        topBarLeading
                    }
                    #endif
                }
                #if os(iOS)
                .toolbarBackground(Color.sonicBackground.opacity(0.8), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                #endif
                .navigationDestination(for: Playlist.self) { playlist in
                    PlaylistView(playlistID: playlist.id)
                }
            }

            VStack(spacing: 0) {
                MiniPlayerBar()
                    .padding(.bottom, 8)
                tabBar
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: Binding(
            get: { player.showNowPlaying },
            set: { player.showNowPlaying = $0 }
        )) {
            NowPlayingView()
                .environment(player)
                .environment(library)
                .environment(settings)
        }
        #else
        .sheet(isPresented: Binding(
            get: { player.showNowPlaying },
            set: { player.showNowPlaying = $0 }
        )) {
            NowPlayingView()
                .environment(player)
                .environment(library)
                .environment(settings)
        }
        #endif
        .sheet(isPresented: Binding(
            get: { library.showCreatePlaylist },
            set: { library.showCreatePlaylist = $0 }
        )) {
            CreatePlaylistSheet()
        }
        .sheet(item: Binding(
            get: { library.songToAddToPlaylist },
            set: { library.songToAddToPlaylist = $0 }
        )) { song in
            AddToPlaylistSheet(song: song)
        }
        .fileImporter(
            isPresented: Binding(
                get: { library.showImportMusic },
                set: { library.showImportMusic = $0 }
            ),
            allowedContentTypes: [.audio, .mp3, .wav, .aiff],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    library.importAudioFile(from: url)
                }
            case .failure(let error):
                print("Import error: \(error)")
            }
        }
    }

    // MARK: - Top Bar Logo
    private var topBarLeading: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.sonicSurfaceVariant)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.sonicOnSurfaceVariant)
                )

            Text("Sonic")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .italic()
                .foregroundStyle(Color.sonicIndigo400)
        }
    }

    private var topBarTrailing: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = .settings
            }
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 18))
                .foregroundStyle(Color.sonicIndigo400)
        }
    }

    // MARK: - Library View
    private var libraryView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                QueueView()

                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Your Playlists")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.sonicOnSurface)

                        Spacer()

                        Button {
                            library.showCreatePlaylist = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14))
                                Text("New")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(Color.sonicPrimary)
                        }
                    }
                    .padding(.horizontal, 24)

                    LazyVStack(spacing: 8) {
                        ForEach(library.playlists) { playlist in
                            NavigationLink(value: playlist) {
                                playlistRow(playlist)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Import music button
                    Button {
                        library.showImportMusic = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 16))
                            Text("Import Music")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.sonicOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.sonicPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)

                    // Imported songs
                    if !library.importedSongs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Imported Songs")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.sonicOnSurface)
                                .padding(.horizontal, 24)

                            LazyVStack(spacing: 4) {
                                ForEach(library.importedSongs) { song in
                                    SongRow(song: song) {
                                        player.playSong(song)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .background(Color.sonicBackground)
    }

    private func playlistRow(_ playlist: Playlist) -> some View {
        HStack(spacing: 16) {
            SongArtwork(artworkName: playlist.artworkName, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.sonicOnSurface)
                    .lineLimit(1)

                Text("\(playlist.trackCount) tracks")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
        }
        .padding(12)
        .contentShape(Rectangle())
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                    HapticService.selection()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                            .symbolVariant(selectedTab == tab ? .fill : .none)

                        Text(tab.title.uppercased())
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundStyle(
                        selectedTab == tab
                            ? Color.sonicIndigo400
                            : Color(hex: "737373")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, selectedTab == tab ? 8 : 0)
                    .background(
                        selectedTab == tab
                            ? Color.sonicIndigo500.opacity(0.1)
                                .clipShape(Capsule())
                            : nil
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 32)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 32,
                topTrailingRadius: 32
            )
            .fill(.ultraThinMaterial)
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 32,
                    topTrailingRadius: 32
                )
                .fill(Color.sonicGlassTint.opacity(0.6))
            )
            .shadow(color: .sonicOnSurface.opacity(0.05), radius: 0, y: -1)
            .ignoresSafeArea()
        )
    }
}

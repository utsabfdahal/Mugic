import SwiftUI

// MARK: - Main Tab View
// Root navigation container with bottom tab bar, mini player, and now playing sheet
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var player = PlayerViewModel()

    enum Tab: String, CaseIterable {
        case home, search, library, settings

        var title: String {
            rawValue.capitalized
        }

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
            // Main content
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
                    PlaylistView(playlist: playlist)
                }
            }

            // Mini player floating bar
            VStack(spacing: 0) {
                MiniPlayerBar()
                    .padding(.bottom, 8)

                // Tab bar
                tabBar
            }
        }
        .environment(player)
        #if os(iOS)
        .fullScreenCover(isPresented: Binding(
            get: { player.showNowPlaying },
            set: { player.showNowPlaying = $0 }
        )) {
            NowPlayingView()
                .environment(player)
        }
        #else
        .sheet(isPresented: Binding(
            get: { player.showNowPlaying },
            set: { player.showNowPlaying = $0 }
        )) {
            NowPlayingView()
                .environment(player)
        }
        #endif
        .preferredColorScheme(.dark)
    }

    // MARK: - Top Bar Logo
    private var topBarLeading: some View {
        HStack(spacing: 10) {
            // Profile avatar placeholder
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
            selectedTab = .settings
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 18))
                .foregroundStyle(Color.sonicIndigo400)
        }
    }

    // MARK: - Library View (Queue + Playlists)
    private var libraryView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Queue section
                QueueView()

                // Playlists section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Playlists")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)

                    LazyVStack(spacing: 8) {
                        ForEach(SampleData.playlists) { playlist in
                            NavigationLink(value: playlist) {
                                playlistRow(playlist)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
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
                    .foregroundStyle(.white)
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
                    selectedTab = tab
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
                .fill(Color(hex: "171717").opacity(0.6))
            )
            .shadow(color: .white.opacity(0.05), radius: 0, y: -1)
            .ignoresSafeArea()
        )
    }
}

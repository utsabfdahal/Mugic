import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @Environment(PlayerViewModel.self) private var player
    @Environment(LibraryViewModel.self) private var library
    @State private var searchText = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                welcomeSection
                    .padding(.bottom, 32)

                searchBar
                    .padding(.bottom, 40)

                quickAccessSection
                    .padding(.bottom, 48)

                recentlyPlayedSection
                    .padding(.bottom, 48)

                recommendedMixesSection
                    .padding(.bottom, 48)

                favoriteTracksSection
                    .padding(.bottom, 120)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.sonicBackground)
    }

    // MARK: - Welcome
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greetingText)
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(.sonicOnSurface)
                .tracking(-0.5)

            Text("Ready for your nightly rhythm?")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundStyle(Color.sonicOnSurfaceVariant)

            TextField("Artists, songs, or podcasts", text: $searchText)
                .font(.system(size: 16))
                .foregroundStyle(.sonicOnSurface)
        }
        .padding(18)
        .background(Color.sonicSurfaceContainer)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Access Bento Grid
    private var quickAccessSection: some View {
        VStack(spacing: 12) {
            heroCard
                .frame(height: 200)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(SampleData.quickAccessItems) { item in
                    QuickAccessTile(item: item)
                        .frame(height: 100)
                }
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.sonicPrimaryDim, Color.sonicSecondaryContainer],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: 120, y: -60)

            VStack(alignment: .leading, spacing: 6) {
                Text("CURATED FOR YOU")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.7))

                Text("Your Daily Mix 1")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(28)

            Button {
                player.shufflePlay(SampleData.songs.prefix(10).map { $0 })
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Recently Played
    private var recentlyPlayedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Recently Played")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.sonicOnSurface)

                Spacer()

                Button("View All") { }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.sonicPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(SampleData.recentAlbums) { album in
                        AlbumCard(album: album) {
                            if !album.songs.isEmpty {
                                player.playPlaylist(album.songs)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recommended Mixes
    private var recommendedMixesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recommended Mixes")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.sonicOnSurface)

            VStack(spacing: 16) {
                ForEach(library.playlists.prefix(2)) { playlist in
                    mixCard(
                        title: playlist.name,
                        subtitle: playlist.description,
                        artwork: playlist.artworkName
                    )
                    .onTapGesture {
                        if !playlist.songs.isEmpty {
                            player.playPlaylist(playlist.songs)
                        }
                    }
                }
            }
        }
    }

    private func mixCard(title: String, subtitle: String, artwork: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: gradientColors(for: artwork),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            LinearGradient(
                colors: [.clear, .black.opacity(0.4), .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(24)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Favorite Tracks
    private var favoriteTracksSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Favorite Tracks")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.sonicOnSurface)

            if library.favoriteSongs.isEmpty {
                Text("No favorites yet — tap the heart on any song")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 4) {
                    ForEach(library.favoriteSongs.prefix(8)) { song in
                        HStack(spacing: 0) {
                            SongRow(song: song) {
                                player.playSong(song)
                            }

                            Button {
                                library.toggleFavorite(song)
                            } label: {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.sonicTertiary)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                }
            }
        }
    }

    private func gradientColors(for name: String) -> [Color] {
        let hash = abs(name.hashValue)
        let palettes: [[Color]] = [
            [Color(hex: "8a4cfc"), Color(hex: "2c2c2d")],
            [Color(hex: "49339d"), Color(hex: "0e0e0f")],
            [Color(hex: "701455"), Color(hex: "1a191b")],
            [Color(hex: "3c0089"), Color(hex: "131314")],
        ]
        return palettes[hash % palettes.count]
    }
}

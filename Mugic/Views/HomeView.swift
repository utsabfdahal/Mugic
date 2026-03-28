import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @Environment(PlayerViewModel.self) private var player
    @State private var searchText = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Welcome Section
                welcomeSection
                    .padding(.bottom, 32)

                // Search Bar
                searchBar
                    .padding(.bottom, 40)

                // Quick Access Bento Grid
                quickAccessSection
                    .padding(.bottom, 48)

                // Recently Played
                recentlyPlayedSection
                    .padding(.bottom, 48)

                // Recommended Mixes
                recommendedMixesSection
                    .padding(.bottom, 48)

                // Favorite Tracks
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
            Text("Good Evening, Julian")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(.white)
                .tracking(-0.5)

            Text("Ready for your nightly rhythm?")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
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
                .foregroundStyle(.white)
        }
        .padding(18)
        .background(Color.sonicSurfaceContainer)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Access Bento Grid
    private var quickAccessSection: some View {
        VStack(spacing: 12) {
            // Hero card
            heroCard
                .frame(height: 200)

            // 2x2 grid of quick items
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

            // Decorative blur circle
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

            // Play button
            Button { } label: {
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
                    .foregroundStyle(.white)

                Spacer()

                Button("View All") { }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.sonicPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(SampleData.recentAlbums) { album in
                        AlbumCard(album: album)
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
                .foregroundStyle(.white)

            VStack(spacing: 16) {
                ForEach(SampleData.playlists.prefix(2)) { playlist in
                    mixCard(
                        title: playlist.name,
                        subtitle: playlist.description,
                        artwork: playlist.artworkName
                    )
                }
            }
        }
    }

    private func mixCard(title: String, subtitle: String, artwork: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            LinearGradient(
                colors: gradientColors(for: artwork),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            // Overlay gradient
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
                .foregroundStyle(.white)

            LazyVStack(spacing: 4) {
                ForEach(SampleData.favoriteTracks) { song in
                    SongRow(song: song) {
                        player.playSong(song)
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

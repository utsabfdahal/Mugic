import Foundation

// MARK: - Sample Data
// Provides mock data matching the Stitch HTML designs
struct SampleData {

    // MARK: - Songs
    static let songs: [Song] = [
        Song(id: "0", title: "Pasoori", artist: "Ali Sethi & Shae Gill", album: "Coke Studio", duration: 260, artworkName: "album_pasoori", fileURL: Bundle.main.url(forResource: "Pasoori", withExtension: "mp3")),
        Song(id: "1", title: "Starboy", artist: "The Weeknd", album: "Starboy", duration: 230, artworkName: "album_starboy"),
        Song(id: "2", title: "Levitating", artist: "Dua Lipa", album: "Future Nostalgia", duration: 203, artworkName: "album_levitating"),
        Song(id: "3", title: "Heat Waves", artist: "Glass Animals", album: "Dreamland", duration: 238, artworkName: "album_heatwaves"),
        Song(id: "4", title: "Blinding Lights", artist: "The Weeknd", album: "After Hours", duration: 200, artworkName: "album_blindinglights"),
        Song(id: "5", title: "Bad Habit", artist: "Steve Lacy", album: "Gemini Rights", duration: 232, artworkName: "album_badhabit"),
        Song(id: "6", title: "Green Tea", artist: "Lo-Fi Girl", album: "Chill Beats", duration: 165, artworkName: "album_greentea"),
        Song(id: "7", title: "Midnight City", artist: "M83", album: "Hurry Up, We're Dreaming", duration: 243, artworkName: "album_midnightcity"),
        Song(id: "8", title: "After Hours", artist: "The Weeknd", album: "After Hours", duration: 362, artworkName: "album_afterhours"),
        Song(id: "9", title: "Instant Crush", artist: "Daft Punk ft. Julian Casablancas", album: "Random Access Memories", duration: 337, artworkName: "album_instantcrush"),
        Song(id: "10", title: "Lost in Yesterday", artist: "Tame Impala", album: "The Slow Rush", duration: 250, artworkName: "album_lostinyesterday"),
        Song(id: "11", title: "Self Control", artist: "Frank Ocean", album: "Blonde", duration: 249, artworkName: "album_selfcontrol"),
        Song(id: "12", title: "Neon Horizons", artist: "Synthetic Dreams", album: "The Last Transmission", duration: 252, artworkName: "album_neonhorizons"),
        Song(id: "13", title: "Neon Cathedral", artist: "Synthetic Dreams", album: "Neon Cathedral", duration: 280, artworkName: "album_neoncathedral"),
        Song(id: "14", title: "Midnight Protocol", artist: "Ethereal Echoes", album: "Digital Horizons", duration: 215, artworkName: "album_midnightprotocol"),
        Song(id: "15", title: "Vapor Trail", artist: "The Glitch Collective", album: "Data Streams", duration: 198, artworkName: "album_vaportrail"),
        Song(id: "16", title: "Silicon Valley Blues", artist: "Algorithm", album: "Binary Code", duration: 225, artworkName: "album_siliconvalley"),
        Song(id: "17", title: "Hyperdrive", artist: "Sonic Architect", album: "Warp Speed", duration: 210, artworkName: "album_hyperdrive"),
        Song(id: "18", title: "Lunar Tide", artist: "Cosmic Wave", album: "Celestial", duration: 240, artworkName: "album_lunartide"),
        Song(id: "19", title: "Midnight Cityscape", artist: "Neon Echoes", album: "Urban Glow", duration: 222, artworkName: "album_cityscape"),
        Song(id: "20", title: "Electric Dreams", artist: "Synthetic Solitude", album: "Voltage", duration: 255, artworkName: "album_electricdreams"),
        Song(id: "21", title: "Afterglow", artist: "Lunar Cycles", album: "Moonlight", duration: 178, artworkName: "album_afterglow"),
        Song(id: "22", title: "Subliminal Message", artist: "The Searchers", album: "Deep Cuts", duration: 302, artworkName: "album_subliminal"),
    ]

    // MARK: - Recently Played Albums
    static let recentAlbums: [Album] = [
        Album(id: "a1", title: "Midnight City", artist: "The Echo Project", artworkName: "recent_midnightcity", year: 2023, songs: Array(songs[0...2])),
        Album(id: "a2", title: "Golden Hour", artist: "Kacey Musgraves", artworkName: "recent_goldenhour", year: 2018, songs: Array(songs[1...3])),
        Album(id: "a3", title: "Structures", artist: "Odesza", artworkName: "recent_structures", year: 2022, songs: Array(songs[2...4])),
        Album(id: "a4", title: "Analog Dreams", artist: "Retro Wave", artworkName: "recent_analogdreams", year: 2021, songs: Array(songs[3...5])),
        Album(id: "a5", title: "Euphoria", artist: "Labrinth", artworkName: "recent_euphoria", year: 2019, songs: Array(songs[4...6])),
    ]

    // MARK: - Playlists
    static let playlists: [Playlist] = [
        Playlist(id: "p1", name: "My Favorites", description: "All my favorite chill tracks", artworkName: "playlist_favorites", songs: Array(songs[6...10])),
        Playlist(id: "p2", name: "Night Tempo", description: "Electronic, Synthwave, Lo-fi Beats", artworkName: "playlist_nighttempo", songs: Array(songs[0...5])),
        Playlist(id: "p3", name: "Live Energy", description: "Rock, Alternative, Live Anthems", artworkName: "playlist_liveenergy", songs: Array(songs[3...8])),
        Playlist(id: "p4", name: "Midnight City Vibes", description: "Late night chill vibes", artworkName: "playlist_midnightvibes", songs: Array(songs[5...10])),
    ]

    // MARK: - Quick Access Items
    static let quickAccessItems: [QuickAccessItem] = [
        QuickAccessItem(title: "Liked Songs", icon: "heart.fill", color: "tertiary"),
        QuickAccessItem(title: "On Repeat", icon: "clock.arrow.circlepath", color: "secondary"),
        QuickAccessItem(title: "New Release", icon: "sparkles", color: "primary"),
        QuickAccessItem(title: "Top Podcasts", icon: "antenna.radiowaves.left.and.right", color: "neutral"),
    ]

    // MARK: - Artists
    static let artists: [Artist] = [
        Artist(id: "ar1", name: "The Searchers", genre: "Alternative", imageName: "artist_searchers"),
        Artist(id: "ar2", name: "Aura Quest", genre: "Synth-Pop", imageName: "artist_auraquest"),
        Artist(id: "ar3", name: "The Weeknd", genre: "R&B", imageName: "artist_weeknd"),
        Artist(id: "ar4", name: "Dua Lipa", genre: "Pop", imageName: "artist_dualipa"),
    ]

    // MARK: - Queue Songs
    static let queueSongs: [Song] = Array(songs[13...17])

    // MARK: - Favorite Tracks (for home page)
    static let favoriteTracks: [Song] = Array(songs[0...5])

    // MARK: - Search Filter Categories
    static let searchFilters = ["Recent", "Lo-Fi Beats", "Deep House", "Ambient Study", "Jazz Essentials"]
}

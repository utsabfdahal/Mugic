import Foundation

// MARK: - Song Model
struct Song: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval // seconds
    let artworkName: String

    var durationString: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Album Model
struct Album: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artist: String
    let artworkName: String
    let year: Int
    let songs: [Song]
}

// MARK: - Playlist Model
struct Playlist: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let artworkName: String
    let songs: [Song]

    var trackCount: Int { songs.count }
}

// MARK: - Artist Model
struct Artist: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let genre: String
    let imageName: String
}

// MARK: - Quick Access Item
struct QuickAccessItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let color: String // "primary", "secondary", "tertiary", "neutral"
}

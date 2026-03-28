import Foundation

// MARK: - Song Model
struct Song: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var artist: String
    var album: String
    var duration: TimeInterval // seconds
    var artworkName: String
    var fileURL: URL? // nil for sample songs, set for imported audio

    init(id: String, title: String, artist: String, album: String, duration: TimeInterval, artworkName: String, fileURL: URL? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.artworkName = artworkName
        self.fileURL = fileURL
    }

    var durationString: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
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
    var name: String
    var description: String
    var artworkName: String
    var songs: [Song]

    var trackCount: Int { songs.count }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
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

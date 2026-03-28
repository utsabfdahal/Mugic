import SwiftUI
import AVFoundation

@Observable
final class LibraryViewModel {
    var playlists: [Playlist] = []
    var favoriteSongIDs: Set<String> = []
    var importedSongs: [Song] = []

    // Sheet states
    var showCreatePlaylist = false
    var showImportMusic = false
    var songToAddToPlaylist: Song? = nil

    init() {
        playlists = PersistenceService.loadPlaylists() ?? SampleData.playlists
        favoriteSongIDs = PersistenceService.loadFavorites()
        importedSongs = PersistenceService.loadImportedSongs()
        if favoriteSongIDs.isEmpty {
            favoriteSongIDs = Set(SampleData.favoriteTracks.map { $0.id })
            saveFavorites()
        }
    }

    // MARK: - All Songs
    var allSongs: [Song] {
        SampleData.songs + importedSongs
    }

    // MARK: - Favorites
    func isFavorite(_ song: Song) -> Bool {
        favoriteSongIDs.contains(song.id)
    }

    func toggleFavorite(_ song: Song) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if favoriteSongIDs.contains(song.id) {
                favoriteSongIDs.remove(song.id)
            } else {
                favoriteSongIDs.insert(song.id)
            }
        }
        saveFavorites()
        HapticService.medium()
    }

    var favoriteSongs: [Song] {
        allSongs.filter { favoriteSongIDs.contains($0.id) }
    }

    // MARK: - Playlist CRUD
    func createPlaylist(name: String, description: String) {
        let playlist = Playlist(
            id: UUID().uuidString,
            name: name,
            description: description,
            artworkName: "playlist_\(name.lowercased().replacingOccurrences(of: " ", with: ""))",
            songs: []
        )
        withAnimation(.spring(duration: 0.3)) {
            playlists.append(playlist)
        }
        savePlaylists()
        HapticService.success()
    }

    func deletePlaylist(at offsets: IndexSet) {
        withAnimation(.easeOut(duration: 0.25)) {
            playlists.remove(atOffsets: offsets)
        }
        savePlaylists()
        HapticService.medium()
    }

    func deletePlaylist(_ playlist: Playlist) {
        withAnimation(.easeOut(duration: 0.25)) {
            playlists.removeAll { $0.id == playlist.id }
        }
        savePlaylists()
        HapticService.medium()
    }

    func renamePlaylist(_ playlist: Playlist, to newName: String) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        playlists[index].name = newName
        savePlaylists()
    }

    func addSongToPlaylist(_ song: Song, playlist: Playlist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        guard !playlists[index].songs.contains(where: { $0.id == song.id }) else { return }
        playlists[index].songs.append(song)
        savePlaylists()
        HapticService.success()
    }

    func removeSongFromPlaylist(_ song: Song, playlist: Playlist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        playlists[index].songs.removeAll { $0.id == song.id }
        savePlaylists()
    }

    func playlistForID(_ id: String) -> Playlist? {
        playlists.first { $0.id == id }
    }

    // MARK: - Import Music
    func importAudioFile(from url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        let destURL = PersistenceService.importedMusicDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: url, to: destURL)

            let asset = AVURLAsset(url: destURL)
            Task {
                let metadata = try? await asset.load(.metadata)
                let cmDuration = try? await asset.load(.duration)

                var title = url.deletingPathExtension().lastPathComponent
                var artist = "Unknown Artist"
                var album = "Unknown Album"

                if let metadata {
                    for item in metadata {
                        if let key = item.commonKey {
                            let value = try? await item.load(.stringValue)
                            switch key {
                            case .commonKeyTitle: title = value ?? title
                            case .commonKeyArtist: artist = value ?? artist
                            case .commonKeyAlbumName: album = value ?? album
                            default: break
                            }
                        }
                    }
                }

                let durationSec = cmDuration.map { CMTimeGetSeconds($0) } ?? 0

                let song = Song(
                    id: UUID().uuidString,
                    title: title,
                    artist: artist,
                    album: album,
                    duration: durationSec > 0 ? durationSec : 180,
                    artworkName: "imported_\(title.lowercased())",
                    fileURL: destURL
                )

                await MainActor.run {
                    self.importedSongs.append(song)
                    self.saveImportedSongs()
                    HapticService.success()
                }
            }
        } catch {
            print("Import failed: \(error)")
            HapticService.error()
        }
    }

    // MARK: - Search
    func searchSongs(query: String) -> [Song] {
        guard !query.isEmpty else { return Array(allSongs.prefix(6)) }
        return allSongs.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.localizedCaseInsensitiveContains(query) ||
            $0.album.localizedCaseInsensitiveContains(query)
        }
    }

    func searchArtists(query: String) -> [Artist] {
        guard !query.isEmpty else { return SampleData.artists }
        return SampleData.artists.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.genre.localizedCaseInsensitiveContains(query)
        }
    }

    func searchAlbums(query: String) -> [Album] {
        guard !query.isEmpty else { return SampleData.recentAlbums }
        return SampleData.recentAlbums.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.localizedCaseInsensitiveContains(query)
        }
    }

    func searchPlaylists(query: String) -> [Playlist] {
        guard !query.isEmpty else { return playlists }
        return playlists.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.description.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - Persistence
    private func savePlaylists() {
        PersistenceService.savePlaylists(playlists)
    }

    private func saveFavorites() {
        PersistenceService.saveFavorites(favoriteSongIDs)
    }

    private func saveImportedSongs() {
        PersistenceService.saveImportedSongs(importedSongs)
    }
}

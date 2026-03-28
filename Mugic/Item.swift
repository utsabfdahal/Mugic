import Foundation

// Placeholder - no longer used. SwiftData removed in favor of in-memory sample data.
struct Item: Identifiable {
    let id = UUID()
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

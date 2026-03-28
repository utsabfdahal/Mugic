import SwiftUI

// MARK: - Queue View
struct QueueView: View {
    @Environment(PlayerViewModel.self) private var player

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                nowPlayingCard
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                queueList
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
            }
        }
        .background(Color.sonicBackground)
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text("QUEUE")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(Color.sonicPrimary)

                Text("Up Next")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.sonicOnSurface)
                    .tracking(-1)
            }

            Spacer()

            Button {
                player.clearQueue()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                    Text("Clear Queue")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.sonicOnSurfaceVariant)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.sonicSurfaceContainerHigh)
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Now Playing Card
    private var nowPlayingCard: some View {
        Group {
            if let song = player.currentSong {
                HStack(spacing: 16) {
                    ZStack {
                        SongArtwork(artworkName: song.artworkName, size: 72, fileURL: song.fileURL)
                            .shadow(color: .black.opacity(0.5), radius: 12)

                        Image(systemName: "waveform")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.sonicPrimary)
                            .frame(width: 72, height: 72)
                            .background(.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(player.isPlaying ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: player.isPlaying)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("NOW PLAYING")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(Color.sonicPrimary)

                        Text(song.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.sonicOnSurface)
                            .lineLimit(1)

                        Text("\(song.artist) • \(song.album)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.sonicOnSurfaceVariant)
                            .lineLimit(1)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.sonicPrimary.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.sonicOutlineVariant.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Queue List (Reorderable)
    private var queueList: some View {
        VStack(spacing: 4) {
            if player.queue.isEmpty {
                emptyState
            } else {
                ForEach(Array(player.queue.enumerated()), id: \.element.id) { index, song in
                    QueueItemRow(song: song) {
                        player.removeFromQueue(at: index)
                    }
                    .onTapGesture {
                        let idx = index
                        player.playSong(song)
                        player.removeFromQueue(at: idx)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .slide),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                    .contextMenu {
                        Button {
                            player.playSong(song)
                            player.removeFromQueue(at: index)
                        } label: {
                            Label("Play Now", systemImage: "play.fill")
                        }
                        Button(role: .destructive) {
                            player.removeFromQueue(at: index)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: player.queue.count)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundStyle(Color.sonicOnSurfaceVariant.opacity(0.3))

            Text("Your queue is empty")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.sonicOnSurfaceVariant)

            Text("Add songs to play next")
                .font(.system(size: 14))
                .foregroundStyle(Color.sonicOnSurfaceVariant.opacity(0.6))
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
}

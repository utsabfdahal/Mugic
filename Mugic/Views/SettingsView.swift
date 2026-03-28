import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @State private var crossfadeEnabled = true
    @State private var audioQuality = "Lossless"
    @State private var theme = "Dark"

    private let qualityOptions = ["Low", "Normal", "High", "Lossless"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                // Header
                headerSection

                // Account
                accountSection

                // Playback
                playbackSection

                // Library
                librarySection

                // Display
                displaySection

                // About
                aboutSection

                // Footer
                Text("MADE WITH SOUL IN THE VOID")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(3)
                    .foregroundStyle(Color.sonicOnSurfaceVariant.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 120)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.sonicBackground)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(.white)
                .tracking(-0.5)

            Text("Personalize your kinetic gallery experience.")
                .font(.system(size: 16))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
        }
    }

    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(icon: "person.fill", title: "ACCOUNT")

            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    // Profile pic placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.sonicPrimaryDim, Color.sonicSecondaryContainer],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Alex Rivera")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)

                        Text("alex.sonic@kinetic.audio")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.sonicOnSurfaceVariant)

                        HStack(spacing: 8) {
                            Text("PREMIUM PLUS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.sonicPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.sonicPrimary.opacity(0.1))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.sonicPrimary.opacity(0.2), lineWidth: 1))

                            Text("SINCE 2022")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.sonicOnSurfaceVariant)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.sonicSurfaceBright)
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()
                }

                Button {
                    // Edit profile
                } label: {
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.sonicPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(24)
            .background(Color.sonicSurfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Playback Section
    private var playbackSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(icon: "play.circle.fill", title: "PLAYBACK")

            VStack(spacing: 0) {
                // Crossfade toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Crossfade")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Seamlessly transition between tracks")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.sonicOnSurfaceVariant)
                    }

                    Spacer()

                    Toggle("", isOn: $crossfadeEnabled)
                        .tint(Color.sonicPrimary)
                        .labelsHidden()
                }
                .padding(24)

                Divider()
                    .background(.white.opacity(0.05))

                // Audio quality
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Audio Quality")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)

                        Spacer()

                        Text("Lossless (Hi-Fi)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.sonicPrimary)
                    }

                    HStack(spacing: 8) {
                        ForEach(qualityOptions, id: \.self) { quality in
                            Button {
                                audioQuality = quality
                            } label: {
                                Text(quality)
                                    .font(.system(size: 14, weight: audioQuality == quality ? .bold : .medium))
                                    .foregroundStyle(
                                        audioQuality == quality
                                            ? Color.sonicOnPrimaryFixed
                                            : Color.sonicOnSurfaceVariant
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        audioQuality == quality
                                            ? Color.sonicPrimary
                                            : Color.sonicSurfaceBright
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(Color.sonicSurfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Library Section
    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(icon: "music.note.house.fill", title: "LIBRARY")

            VStack(spacing: 24) {
                // Storage info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Storage Info")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)

                        Spacer()

                        HStack(spacing: 4) {
                            Text("42.5 GB")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Text("used of 128 GB")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.sonicOnSurfaceVariant)
                        }
                    }

                    // Progress bar
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.sonicPrimary)
                                .frame(width: geo.size.width * 0.30)
                            Rectangle()
                                .fill(Color.sonicTertiary)
                                .frame(width: geo.size.width * 0.15)
                            Rectangle()
                                .fill(Color.sonicSurfaceVariant)
                                .frame(width: geo.size.width * 0.55)
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 8)

                    // Legend
                    HStack(spacing: 20) {
                        legendItem(color: .sonicPrimary, label: "Downloads")
                        legendItem(color: .sonicTertiary, label: "Cache")
                        legendItem(color: .sonicSurfaceVariant, label: "Free Space")
                    }
                }

                // Action buttons
                HStack(spacing: 12) {
                    settingsActionButton(icon: "trash", title: "Clear Cache")
                    settingsActionButton(icon: "arrow.down.circle", title: "Downloads")
                }
            }
            .padding(24)
            .background(Color.sonicSurfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Display Section
    private var displaySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(icon: "paintpalette.fill", title: "DISPLAY")

            VStack(spacing: 16) {
                Text("Theme Preference")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 16) {
                    // Light theme
                    themeOption(
                        title: "Light Mode",
                        isSelected: theme == "Light",
                        backgroundColor: Color(hex: "f5f5f5"),
                        action: { theme = "Light" }
                    )

                    // Dark theme
                    themeOption(
                        title: "Dark Mode",
                        isSelected: theme == "Dark",
                        backgroundColor: Color.sonicBackground,
                        action: { theme = "Dark" }
                    )
                }
            }
            .padding(24)
            .background(Color.sonicSurfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(icon: "info.circle.fill", title: "ABOUT")

            VStack(spacing: 0) {
                aboutRow(title: "Version", value: "Sonic v4.2.0-beta")
                aboutChevronRow(title: "Terms of Service")
                aboutChevronRow(title: "Privacy Policy")
                aboutChevronRow(title: "Open Source Licenses")
            }
            .background(Color.sonicSurfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Shared Subviews
    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.sonicPrimary)

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .tracking(3)
                .foregroundStyle(Color.sonicPrimary)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
        }
    }

    private func settingsActionButton(icon: String, title: String) -> some View {
        Button { } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.sonicSurfaceBright)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.sonicOutlineVariant.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private func themeOption(title: String, isSelected: Bool, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.sonicPrimary : .clear,
                                lineWidth: 3
                            )
                    )
                    .overlay(
                        isSelected
                            ? Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.sonicPrimary)
                            : nil
                    )
                    .shadow(color: isSelected ? Color.sonicPrimary.opacity(0.2) : .clear, radius: 12)

                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.sonicPrimary : Color.sonicOnSurfaceVariant)
            }
        }
    }

    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundStyle(Color.sonicOnSurfaceVariant)
        }
        .padding(24)
    }

    private func aboutChevronRow(title: String) -> some View {
        VStack(spacing: 0) {
            Divider().background(.white.opacity(0.05))
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.sonicOnSurfaceVariant)
            }
            .padding(24)
        }
    }
}

//
//  ContentView.swift
//  myCard
//
//  Created by Islom Shamsiev on 2025/9/9.
//

import SwiftUI

enum Tab {
    case profile
    case contacts
}

struct ContentView: View {
    @State private var selected: Tab = .profile

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 15/255, green: 18/255, blue: 35/255),  // deep navy
                    Color(red: 30/255, green: 20/255, blue: 60/255),  // indigo/purple
                    Color(red: 10/255, green: 10/255, blue: 20/255)   // dark base
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                switch selected {
                case .profile:
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Header
                            HStack {
                                Text("@username")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .hAlign(.center)
                                    .padding(.leading, 50)
                                Spacer()
                                Image(systemName: "qrcode")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                                    .padding(.trailing, 20)
                            }

                            // Big profile card (can stay glassy)
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .frame(width: 250, height: 250)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("19")
                                            .foregroundColor(.white)
                                            .font(.title2.bold())
                                        Text("Islombek Shamsiev")
                                            .foregroundColor(.white.opacity(0.9))
                                            .font(.caption)
                                    }
                                    .padding(),
                                    alignment: .bottomLeading
                                )

                            // Socials header
                            HStack {
                                Text("Socials")
                                    .foregroundColor(.white)
                                    .font(.title.bold())
                                    .hAlign(.leading)
                                    .padding(.leading, 30)
                                Spacer()
                                Text("Edit")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                                    .padding(.trailing, 30)
                                    .fontWeight(.light)
                            }

                            // SOCIAL ROWS — vibrant brand color + gloss
                            VStack(spacing: 20) {
                                HStack(spacing: 20) {
                                    // Snapchat — #FFFC00
                                    SocialCard(
                                        title: "Snapchat",
                                        systemImage: "bolt.fill",
                                        fill: AnyShapeStyle(Color(red: 1.0, green: 252/255, blue: 0.0)),
                                        iconTint: .black
                                    )

                                    // Instagram gradient — FEDA75 → FA7E1E → D62976 → 962FBF
                                    SocialCard(
                                        title: "Instagram",
                                        systemImage: "camera.fill",
                                        fill: AnyShapeStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 254/255, green: 218/255, blue: 117/255),
                                                    Color(red: 250/255, green: 126/255, blue: 30/255),
                                                    Color(red: 214/255, green: 41/255,  blue: 118/255),
                                                    Color(red: 150/255, green: 47/255,  blue: 191/255)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    )
                                }

                                HStack(spacing: 20) {
                                    // X/Twitter — #1DA1F2
                                    SocialCard(
                                        title: "X / Twitter",
                                        systemImage: "bird.fill", // use custom if you have; SF "xmark" also possible
                                        fill: AnyShapeStyle(Color(red: 29/255, green: 161/255, blue: 242/255))
                                    )

                                    // TikTok — cyan/pink accent over dark
                                    SocialCard(
                                        title: "TikTok",
                                        systemImage: "music.note",
                                        fill: AnyShapeStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color.black,
                                                    Color(red: 37/255, green: 244/255, blue: 238/255),
                                                    Color(red: 254/255, green: 44/255,  blue: 85/255)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    )
                                }

                                HStack(spacing: 20) {
                                    // YouTube — #FF0000
                                    SocialCard(
                                        title: "YouTube",
                                        systemImage: "play.rectangle.fill",
                                        fill: AnyShapeStyle(Color(red: 1.0, green: 0.0, blue: 0.0))
                                    )

                                    // LinkedIn — #0A66C2
                                    SocialCard(
                                        title: "LinkedIn",
                                        systemImage: "briefcase.fill",
                                        fill: AnyShapeStyle(Color(red: 10/255, green: 102/255, blue: 194/255))
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 140)
                    }

                case .contacts:
                    VStack(spacing: 20) {
                        Text("Contacts")
                            .foregroundColor(.white)
                            .font(.title.bold())

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 300, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)

                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 140)
                }
            }

            // Floating glossy tab bar
            GlassTabBar(selected: $selected)
                .padding(.horizontal, 24)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
        }
    }
}

// MARK: - Social Card (VIBRANT base + glossy overlay)
struct SocialCard: View {
    var title: String
    var systemImage: String
    var fill: AnyShapeStyle                 // Color or Gradient
    var iconTint: Color = .white

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .glossyBrand(
                width: 150, height: 80,
                fill: fill,
                glossOpacity: 0.40,
                glassOpacity: 0.20,
                borderOpacity: 0.30
            )
            .overlay(
                HStack(spacing: 10) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconTint.opacity(0.95))
                        .frame(width: 26, height: 26)
                        .background {
                            Circle().fill(Color.white.opacity(0.12))
                        }
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                    Spacer()
                }
                .padding(.horizontal, 14)
            )
    }
}

// MARK: - Glossy Brand Effect
extension Shape {
    /// Vibrant glossy card: brand color/gradient as BASE, subtle glass + gloss on top.
    func glossyBrand(
        cornerRadius: CGFloat = 20,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        fill: AnyShapeStyle,            // pass Color(...) or LinearGradient(...)
        glossOpacity: Double = 0.35,    // white sheen strength
        glassOpacity: Double = 0.22,    // material veil strength
        borderOpacity: Double = 0.25
    ) -> some View {
        self
            // BRAND COLOR (full vibrancy)
            .fill(fill)
            .frame(width: width, height: height)
            // Very subtle glass layer to keep depth without washing out color
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(glassOpacity))
            }
            // Gloss highlight
            .overlay {
                LinearGradient(
                    colors: [
                        .white.opacity(glossOpacity),
                        .white.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .blendMode(.screen)
            }
            // Border and shadow
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 1.2)
            }
            .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Tab Bar
struct GlassTabBar: View {
    @Binding var selected: Tab
    @Namespace private var anim

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 12)

                HStack(spacing: 12) {
                    TabButton(
                        title: "Profile",
                        systemImage: "person.fill",
                        isSelected: selected == .profile,
                        namespace: anim
                    ) { selected = .profile }

                    TabButton(
                        title: "Contacts",
                        systemImage: "person.2.fill",
                        isSelected: selected == .contacts,
                        namespace: anim
                    ) { selected = .contacts }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(height: 66)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white.opacity(isSelected ? 0.95 : 0.7))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                            .matchedGeometryEffect(id: "selectedPill", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helpers
extension View {
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
    }

    func hAlign(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }

    func vAlign(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }

    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }

    func fillView(_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}

#Preview {
    ContentView()
}

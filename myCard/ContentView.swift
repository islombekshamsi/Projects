//
//  ContentView.swift
//  myCard
//
//  Created by Islom Shamsiev on 2025/9/9.
//

import SwiftUI
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation
import AudioToolbox

// MARK: - Brand Colors
extension Color {
    static let snapchatYellow = Color(red: 1.00, green: 0.988, blue: 0.00)   // #FFFC00
    static let instagramMagenta = Color(red: 0.88, green: 0.19, blue: 0.42)  // #E1306C solid alt
    static let twitterBlue    = Color(red: 0.114, green: 0.631, blue: 0.949) // #1DA1F2
    static let tiktokCyan     = Color(red: 0.145, green: 0.957, blue: 0.933) // #25F4EE
    static let youtubeRed     = Color(red: 1.00, green: 0.00,  blue: 0.00)   // #FF0000 (used for Telegram card here)
    static let linkedinBlue   = Color(red: 0.039, green: 0.400, blue: 0.761) // #0A66C2
}

enum Tab {
    case profile
    case contacts
}

struct ContentView: View {
    @State private var selected: Tab = .profile
    @State private var isDark: Bool = true

    // QR sheet states
    @State private var showQRSheet = false
    @State private var lastScanned: String? = nil

    // FlipCard usernames + edit states
    @State private var instaName   = "@insta_name"
    @State private var snapName    = "@snap_name"
    @State private var twitterName = "@twitter_name"
    @State private var tiktokName  = "@tiktok_name"
    @State private var telegramName = "@telegram_name"
    @State private var linkedinName = "@linkedin_name"

    @State private var editingInsta   = false
    @State private var editingSnap    = false
    @State private var editingTwitter = false
    @State private var editingTiktok  = false
    @State private var editingTelegram = false
    @State private var editingLinkedin = false

    // Which socials are shown
    @State private var showSnapchat  = true
    @State private var showInstagram = true
    @State private var showTwitter   = true
    @State private var showTiktok    = true
    @State private var showTelegram  = true
    @State private var showLinkedin  = true

    // Manage Socials sheet
    @State private var showManageSheet = false

    @FocusState private var focusedField: Field?
    enum Field { case insta, snap, twitter, tiktok, telegram, linkedin }

    // Backgrounds
    private var darkBG: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 15/255, green: 18/255, blue: 35/255),
                Color(red: 30/255, green: 20/255, blue: 60/255),
                Color(red: 10/255, green: 10/255, blue: 20/255)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var lightBG: some View {
        LinearGradient(
            colors: [
                Color(red: 248/255, green: 249/255, blue: 251/255),
                Color(red: 236/255, green: 238/255, blue: 243/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var onBG: Color { isDark ? .white : .black.opacity(0.85) }
    private var onBGSecondary: Color { isDark ? .white.opacity(0.9) : .black.opacity(0.6) }
    private var qrColor: Color { isDark ? .white : .black }

    var body: some View {
        ZStack {
            if isDark { darkBG } else { lightBG }

            Group {
                switch selected {
                case .profile:
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {

                            // MARK: Header
                            ZStack {
                                // Centered username
                                Text("@username")
                                    .fontWeight(.medium)
                                    .foregroundColor(onBG)

                                // Left: switch, Right: QR (as a Button to open sheet)
                                HStack {
                                    ModeSwitch(isOn: $isDark)
                                    Spacer(minLength: 8)
                                    Button { showQRSheet = true } label: {
                                        Image(systemName: "qrcode")
                                            .foregroundColor(qrColor)
                                            .font(.system(size: 22, weight: .semibold))
                                    }
                                    .accessibilityLabel("Show QR")
                                }
                            }
                            .padding(.horizontal, 20)

                            // MARK: Image placeholder (no glass)
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(isDark ? Color.white.opacity(0.18) : Color.black.opacity(0.12), lineWidth: 1.2)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                                )
                                .frame(width: 250, height: 250)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 28, weight: .semibold))
                                        Text("Add image")
                                            .font(.caption)
                                    }
                                    .foregroundColor(onBGSecondary),
                                    alignment: .center
                                )
                                .shadow(color: (isDark ? .black.opacity(0.35) : .black.opacity(0.08)),
                                        radius: 12, x: 0, y: 6)

                            // Socials header
                            HStack {
                                Text("Socials")
                                    .foregroundColor(onBG)
                                    .font(.title.bold())
                                Spacer()
                                Button {
                                    showManageSheet = true
                                } label: {
                                    Text("Edit")
                                        .foregroundColor(onBGSecondary)
                                        .font(.system(size: 20, weight: .regular))
                                }
                            }
                            .padding(.horizontal, 30)

                            // MARK: SOCIAL ROWS — ALL FlipCard now (wrapped in visibility toggles)
                            VStack(spacing: 20) {

                                // Row 1
                                HStack(spacing: 20) {
                                    if showSnapchat {
                                        // SNAPCHAT
                                        FlipCard(width: 150, height: 80, cornerRadius: 16) {
                                            ZStack {
                                                Color.white
                                                HStack(spacing: 8) {
                                                    Text("👻").font(.system(size: 18))
                                                    Text("Snapchat")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.yellow)
                                                }
                                            }
                                        } back: {
                                            ZStack {
                                                Color.snapchatYellow
                                                VStack(spacing: 6) {
                                                    Text("Username")
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.85))
                                                    if editingSnap {
                                                        TextField("@username", text: bindingWithAtPrefix($snapName))
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .textInputAutocapitalization(.never)
                                                            .autocorrectionDisabled(true)
                                                            .submitLabel(.done)
                                                            .focused($focusedField, equals: .snap)
                                                            .onSubmit { editingSnap = false }
                                                            .padding(.horizontal, 10)
                                                    } else {
                                                        Text(snapName)
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.white)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.8)
                                                            .padding(.horizontal, 10)
                                                    }
                                                }
                                                // Pencil -> manage sheet
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Button {
                                                            showManageSheet = true
                                                        } label: {
                                                            Image(systemName: "square.and.pencil")
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(.white)
                                                                .padding(6)
                                                                .background(Circle().fill(Color.white.opacity(0.15)))
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }

                                    if showInstagram {
                                        // INSTAGRAM
                                        FlipCard(width: 150, height: 80, cornerRadius: 16) {
                                            ZStack {
                                                Color.red
                                                HStack(spacing: 8) {
                                                    Image(systemName: "camera.fill")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(.white)
                                                    Text("Instagram")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        } back: {
                                            ZStack {
                                                Color.white
                                                VStack(spacing: 6) {
                                                    Text("Username")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                    if editingInsta {
                                                        TextField("@username", text: bindingWithAtPrefix($instaName))
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.red)
                                                            .multilineTextAlignment(.center)
                                                            .textInputAutocapitalization(.never)
                                                            .autocorrectionDisabled(true)
                                                            .submitLabel(.done)
                                                            .focused($focusedField, equals: .insta)
                                                            .onSubmit { editingInsta = false }
                                                            .padding(.horizontal, 10)
                                                    } else {
                                                        Text(instaName)
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.red)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.8)
                                                            .padding(.horizontal, 10)
                                                    }
                                                }
                                                // Pencil -> manage sheet
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Button {
                                                            showManageSheet = true
                                                        } label: {
                                                            Image(systemName: "square.and.pencil")
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(.red)
                                                                .padding(6)
                                                                .background(Circle().fill(Color.red.opacity(0.10)))
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }
                                }

                                // Row 2
                                HStack(spacing: 20) {
                                    if showTwitter {
                                        // TWITTER
                                        FlipCard(width: 150, height: 80, cornerRadius: 16) {
                                            ZStack {
                                                Color.twitterBlue
                                                HStack(spacing: 8) {
                                                    Image(systemName: "bird.fill")
                                                        .font(.system(size: 18, weight: .semibold))
                                                    Text("Twitter")
                                                        .font(.system(size: 16, weight: .semibold))
                                                }
                                                .foregroundColor(.white)
                                            }
                                        } back: {
                                            ZStack {
                                                Color.white
                                                VStack(spacing: 6) {
                                                    Text("Username")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                    if editingTwitter {
                                                        TextField("@username", text: bindingWithAtPrefix($twitterName))
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.blue)
                                                            .multilineTextAlignment(.center)
                                                            .textInputAutocapitalization(.never)
                                                            .autocorrectionDisabled(true)
                                                            .submitLabel(.done)
                                                            .focused($focusedField, equals: .twitter)
                                                            .onSubmit { editingTwitter = false }
                                                            .padding(.horizontal, 10)
                                                    } else {
                                                        Text(twitterName)
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.blue)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.8)
                                                            .padding(.horizontal, 10)
                                                    }
                                                }
                                                // Pencil -> manage sheet
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Button {
                                                            showManageSheet = true
                                                        } label: {
                                                            Image(systemName: "square.and.pencil")
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(.blue)
                                                                .padding(6)
                                                                .background(Circle().fill(Color.blue.opacity(0.10)))
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }

                                    if showTiktok {
                                        // TIKTOK
                                        FlipCard(width: 150, height: 80, cornerRadius: 16) {
                                            ZStack {
                                                Color.tiktokCyan
                                                HStack(spacing: 8) {
                                                    Image(systemName: "music.note")
                                                        .font(.system(size: 18, weight: .semibold))
                                                    Text("TikTok")
                                                        .font(.system(size: 16, weight: .semibold))
                                                }
                                                .foregroundColor(.black)
                                            }
                                        } back: {
                                            ZStack {
                                                Color.black
                                                VStack(spacing: 6) {
                                                    Text("Username")
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.8))
                                                    if editingTiktok {
                                                        TextField("@username", text: bindingWithAtPrefix($tiktokName))
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .textInputAutocapitalization(.never)
                                                            .autocorrectionDisabled(true)
                                                            .submitLabel(.done)
                                                            .focused($focusedField, equals: .tiktok)
                                                            .onSubmit { editingTiktok = false }
                                                            .padding(.horizontal, 10)
                                                    } else {
                                                        Text(tiktokName)
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.white)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.8)
                                                            .padding(.horizontal, 10)
                                                    }
                                                }
                                                // Pencil -> manage sheet
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Button {
                                                            showManageSheet = true
                                                        } label: {
                                                            Image(systemName: "square.and.pencil")
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(.white)
                                                                .padding(6)
                                                                .background(Circle().fill(Color.white.opacity(0.12)))
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }
                                }

                                // Row 3
                                HStack(spacing: 20) {
                                    if showTelegram {
                                        // TELEGRAM (using red as placeholder brand)
                                        FlipCard(width: 150, height: 80, cornerRadius: 16) {
                                            ZStack {
                                                Color.youtubeRed
                                                HStack(spacing: 8) {
                                                    Image(systemName: "paperplane.fill")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(.white)
                                                    Text("Telegram")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        } back: {
                                            ZStack {
                                                Color.white
                                                VStack(spacing: 6) {
                                                    Text("Username")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                    if editingTelegram {
                                                        TextField("@username", text: bindingWithAtPrefix($telegramName))
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.red)
                                                            .multilineTextAlignment(.center)
                                                            .textInputAutocapitalization(.never)
                                                            .autocorrectionDisabled(true)
                                                            .submitLabel(.done)
                                                            .focused($focusedField, equals: .telegram)
                                                            .onSubmit { editingTelegram = false }
                                                            .padding(.horizontal, 10)
                                                    } else {
                                                        Text(telegramName)
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.red)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.8)
                                                            .padding(.horizontal, 10)
                                                    }
                                                }
                                                // Pencil -> manage sheet
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Button {
                                                            showManageSheet = true
                                                        } label: {
                                                            Image(systemName: "square.and.pencil")
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(.red)
                                                                .padding(6)
                                                                .background(Circle().fill(Color.red.opacity(0.10)))
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }

                                    if showLinkedin {
                                        // LINKEDIN
                                        FlipCard(width: 150, height: 80, cornerRadius: 16) {
                                            ZStack {
                                                Color.linkedinBlue
                                                HStack(spacing: 8) {
                                                    Image(systemName: "briefcase.fill")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(.white)
                                                    Text("LinkedIn")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        } back: {
                                            ZStack {
                                                Color.white
                                                VStack(spacing: 6) {
                                                    Text("Username")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                    if editingLinkedin {
                                                        TextField("@username", text: bindingWithAtPrefix($linkedinName))
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(Color.linkedinBlue)
                                                            .multilineTextAlignment(.center)
                                                            .textInputAutocapitalization(.never)
                                                            .autocorrectionDisabled(true)
                                                            .submitLabel(.done)
                                                            .focused($focusedField, equals: .linkedin)
                                                            .onSubmit { editingLinkedin = false }
                                                            .padding(.horizontal, 10)
                                                    } else {
                                                        Text(linkedinName)
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(Color.linkedinBlue)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.8)
                                                            .padding(.horizontal, 10)
                                                    }
                                                }
                                                // Pencil -> manage sheet
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Button {
                                                            showManageSheet = true
                                                        } label: {
                                                            Image(systemName: "square.and.pencil")
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(Color.linkedinBlue)
                                                                .padding(6)
                                                                .background(Circle().fill(Color.linkedinBlue.opacity(0.10)))
                                                        }
                                                    }
                                                    Spacer()
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 140)
                        .animation(.easeInOut(duration: 0.25), value: isDark)
                    }

                case .contacts:
                    VStack(spacing: 20) {
                        Text("Contacts")
                            .foregroundColor(onBG)
                            .font(.title.bold())

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 300, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(isDark ? 0.20 : 0.35), lineWidth: 1)
                            )
                            .shadow(color: (isDark ? .black.opacity(0.45) : .black.opacity(0.10)),
                                    radius: 20, x: 0, y: 10)

                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 140)
                }
            }

            // Floating glossy tab bar — adaptive
            GlassTabBar(selected: $selected, isDark: isDark)
                .padding(.horizontal, 24)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
        }
        .preferredColorScheme(isDark ? .dark : .light)

        // QR sheet
        .sheet(isPresented: $showQRSheet) {
            QRSheet(
                myQRText: "https://www.linkedin.com/in/islom-shamsiev/",
                lastScanned: $lastScanned
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }

        // Manage Socials (90%) sheet
        .sheet(isPresented: $showManageSheet) {
            ManageSocialsSheet(
                showSnapchat: $showSnapchat,
                showInstagram: $showInstagram,
                showTwitter: $showTwitter,
                showTiktok: $showTiktok,
                showTelegram: $showTelegram,
                showLinkedin: $showLinkedin,
                instaName: $instaName,
                snapName: $snapName,
                twitterName: $twitterName,
                tiktokName: $tiktokName,
                telegramName: $telegramName,
                linkedinName: $linkedinName
            ) {
                // Save
                showManageSheet = false
            } onCancel: {
                // If you want to revert in the future, capture snapshots and restore here.
                showManageSheet = false
            }
            .presentationDetents([.fraction(0.9)])   // 90% height
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - FlipCard (reusable)
struct FlipCard<Front: View, Back: View>: View {
    var width: CGFloat = 150
    var height: CGFloat = 80
    var cornerRadius: CGFloat = 16
    @ViewBuilder var front: () -> Front
    @ViewBuilder var back: () -> Back

    @State private var rotation: Double = 0
    private var isFlipped: Bool { rotation >= 90 }

    var body: some View {
        ZStack {
            // FRONT
            front()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .opacity(isFlipped ? 0 : 1)

            // BACK (pre-rotated so text is readable)
            back()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
        .animation(.spring(response: 0.45, dampingFraction: 0.84), value: rotation)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            rotation = (rotation < 180 ? 180 : 0)
        }
    }
}

// MARK: - Keep leading "@" in username fields
func bindingWithAtPrefix(_ text: Binding<String>) -> Binding<String> {
    Binding(
        get: { text.wrappedValue.hasPrefix("@") ? text.wrappedValue : "@" + text.wrappedValue },
        set: { newValue in
            if newValue.isEmpty {
                text.wrappedValue = "@"
            } else if !newValue.hasPrefix("@") {
                text.wrappedValue = "@" + newValue
            } else {
                text.wrappedValue = newValue
            }
        }
    )
}

// MARK: - Mode Switch (glassy capsule with sun/moon)
struct ModeSwitch: View {
    @Binding var isOn: Bool   // true = Dark (moon), false = Light (sun)

    private let h: CGFloat = 36
    private let w: CGFloat = 86
    private let pad: CGFloat = 4

    private var innerW: CGFloat { w - 2*pad }
    private var thumb: CGFloat { h - 2*pad }

    private var activeSunColor: Color  { .yellow }
    private var inactiveSunColor: Color { .secondary.opacity(0.35) }
    private var activeMoonColor: Color { .purple }
    private var inactiveMoonColor: Color { .secondary.opacity(0.35) }

    private var leftCenterX: CGFloat  { pad + innerW * 0.25 }
    private var rightCenterX: CGFloat { pad + innerW * 0.75 }

    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .background(Capsule(style: .continuous).fill(Color.black.opacity(0.06)))
                .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.25), lineWidth: 1))

            HStack(spacing: 0) {
                ZStack {
                    if !isOn { Circle().fill(Color.yellow.opacity(0.18)).frame(width: 22, height: 22) }
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isOn ? inactiveSunColor : activeSunColor)
                }
                .frame(width: innerW/2, height: h)

                ZStack {
                    if isOn { Circle().fill(Color.purple.opacity(0.18)).frame(width: 22, height: 22) }
                    Image(systemName: "moon.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isOn ? activeMoonColor : inactiveMoonColor)
                }
                .frame(width: innerW/2, height: h)
            }
            .padding(.horizontal, pad)

            Circle()
                .fill(LinearGradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.70)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: thumb, height: thumb)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                .overlay(
                    Group {
                        if isOn {
                            Image(systemName: "moon.fill").font(.system(size: 14, weight: .bold)).foregroundColor(activeMoonColor)
                        } else {
                            Image(systemName: "sun.max.fill").font(.system(size: 14, weight: .bold)).foregroundColor(activeSunColor)
                        }
                    }
                )
                .position(x: isOn ? rightCenterX : leftCenterX, y: h/2)
                .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isOn)
        }
        .frame(width: w, height: h)
        .contentShape(Rectangle())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                isOn.toggle()
            }
        }
        .accessibilityLabel("Appearance")
        .accessibilityValue(isOn ? "Dark" : "Light")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Manage Socials Sheet (90%)
struct ManageSocialsSheet: View {
    @Binding var showSnapchat: Bool
    @Binding var showInstagram: Bool
    @Binding var showTwitter: Bool
    @Binding var showTiktok: Bool
    @Binding var showTelegram: Bool
    @Binding var showLinkedin: Bool

    @Binding var instaName: String
    @Binding var snapName: String
    @Binding var twitterName: String
    @Binding var tiktokName: String
    @Binding var telegramName: String
    @Binding var linkedinName: String

    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Sheet header
            HStack {
                Button("Cancel") { onCancel() }
                    .foregroundColor(.secondary)
                Spacer()
                Text("Manage Socials")
                    .font(.headline)
                Spacer()
                Button("Save") { onSave() }
                    .font(.headline)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    SectionHeader("Visible")

                    ToggleRow(title: "Snapchat", color: .snapchatYellow, isOn: $showSnapchat)
                    if showSnapchat { UsernameRow(prefix: "@", text: $snapName, tint: .snapchatYellow) }

                    Divider().opacity(0.08)

                    ToggleRow(title: "Instagram", color: .red, isOn: $showInstagram)
                    if showInstagram { UsernameRow(prefix: "@", text: $instaName, tint: .red) }

                    Divider().opacity(0.08)

                    ToggleRow(title: "Twitter", color: .twitterBlue, isOn: $showTwitter)
                    if showTwitter { UsernameRow(prefix: "@", text: $twitterName, tint: .twitterBlue) }

                    Divider().opacity(0.08)

                    ToggleRow(title: "TikTok", color: .tiktokCyan, isOn: $showTiktok)
                    if showTiktok { UsernameRow(prefix: "@", text: $tiktokName, tint: .tiktokCyan) }

                    Divider().opacity(0.08)

                    ToggleRow(title: "Telegram", color: .youtubeRed, isOn: $showTelegram)
                    if showTelegram { UsernameRow(prefix: "@", text: $telegramName, tint: .youtubeRed) }

                    Divider().opacity(0.08)

                    ToggleRow(title: "LinkedIn", color: .linkedinBlue, isOn: $showLinkedin)
                    if showLinkedin { UsernameRow(prefix: "@", text: $linkedinName, tint: .linkedinBlue) }

                    // Add more platforms here later if needed…
                }
                .padding(.horizontal)
                .padding(.top, 6)
            }
        }
        .padding(.top, 10)
        .background(
            // subtle material vibe
            LinearGradient(
                colors: [
                    Color.black.opacity(0.06),
                    Color.black.opacity(0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

private struct SectionHeader: View {
    let title: String
    init(_ t: String) { self.title = t }
    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 4)
    }
}

private struct ToggleRow: View {
    let title: String
    let color: Color
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

private struct UsernameRow: View {
    let prefix: String
    @Binding var text: String
    let tint: Color
    var body: some View {
        HStack(spacing: 8) {
            Text(prefix)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(tint)
            TextField("username", text: Binding(
                get: {
                    // show without the '@' because we render it ourselves
                    text.hasPrefix(prefix) ? String(text.dropFirst(prefix.count)) : text
                },
                set: { newValue in
                    let clean = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    var val = clean.replacingOccurrences(of: " ", with: "")
                    if val.isEmpty { val = "" }
                    text = prefix + val
                    if !text.hasPrefix(prefix) { text = prefix + text }
                }
            ))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .foregroundColor(tint)
            .font(.system(size: 16, weight: .semibold))
            .submitLabel(.done)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - QR SHEET (My QR ↔ Scan)
private enum QRMode: String, CaseIterable, Identifiable {
    case myQR = "My QR"
    case scan = "Scan"
    var id: String { rawValue }
}

struct QRSheet: View {
    let myQRText: String
    @Binding var lastScanned: String?
    @State private var mode: QRMode = .myQR
    @State private var cameraDenied: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text(mode == .myQR ? "Share your profile" : "Scan a QR")
                .font(.title3.bold())

            Group {
                if mode == .myQR {
                    QRCodeView(text: myQRText, size: 240, quietZone: 20)
                        .padding(.top, 6)
                    Text("Let others scan this to open your LinkedIn.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                } else {
                    QRScannerView(
                        onResult: { value in
                            lastScanned = value
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            if let url = URL(string: value) {
                                UIApplication.shared.open(url)
                            }
                        },
                        onPermissionDenied: { cameraDenied = true }
                    )
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.2), lineWidth: 1))
                    .shadow(radius: 8, y: 4)

                    if let last = lastScanned {
                        Text("Last scanned: \(last)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }

                    if cameraDenied {
                        Text("Camera access is required to scan QR codes. Enable it in Settings > Privacy > Camera.")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            Picker("Mode", selection: $mode) {
                ForEach(QRMode.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.top, 6)

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

// MARK: - QR GENERATOR (crisp, scan-safe)
struct QRCodeView: View {
    let text: String
    var size: CGFloat = 240
    var quietZone: CGFloat = 20

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        if let img = makeQR(from: text, size: size, quietZone: quietZone) {
            Image(uiImage: img)
                .interpolation(.none)
                .resizable()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Color.gray.opacity(0.2)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func makeQR(from string: String, size: CGFloat, quietZone: CGFloat) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }

        let base = output.extent.size
        let scale = size / max(base.width, base.height)
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let finalSize = CGSize(width: size + quietZone*2, height: size + quietZone*2)
        UIGraphicsBeginImageContextWithOptions(finalSize, true, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: finalSize))
        let ciContext = context
        if let cg = ciContext.createCGImage(scaled, from: scaled.extent) {
            UIImage(cgImage: cg).draw(in: CGRect(x: quietZone, y: quietZone, width: size, height: size))
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

// MARK: - QR SCANNER (camera)
struct QRScannerView: UIViewControllerRepresentable {
    var onResult: (String) -> Void
    var onPermissionDenied: () -> Void = {}

    func makeUIViewController(context: Context) -> ScannerVC {
        let vc = ScannerVC()
        vc.onResult = onResult
        vc.onPermissionDenied = onPermissionDenied
        return vc
    }
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
}

final class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onResult: ((String) -> Void)?
    var onPermissionDenied: (() -> Void)?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkPermissionAndConfigure()
    }

    private func checkPermissionAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.configureSession() : self.onPermissionDenied?()
                }
            }
        default:
            onPermissionDenied?()
        }
    }

    private func configureSession() {
        session.beginConfiguration(); defer { session.commitConfiguration() }

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        session.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              obj.type == .qr,
              let value = obj.stringValue else { return }
        onResult?(value)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    deinit { session.stopRunning() }
}

// NOTE: SocialCard kept out (not used); FlipCard is used for all socials.

// MARK: - Floating Glassy Tab Bar (adaptive)
struct GlassTabBar: View {
    @Binding var selected: Tab
    var isDark: Bool
    @Namespace private var anim

    var body: some View {
        let barStroke = isDark ? Color.white.opacity(0.20) : Color.black.opacity(0.10)
        let barTint   = isDark ? Color.white.opacity(0.10) : Color.black.opacity(0.06)
        let labelTint = isDark ? Color.white.opacity(0.95) : Color.black.opacity(0.85)
        let labelDim  = isDark ? Color.white.opacity(0.70) : Color.black.opacity(0.60)

        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(barTint) // subtle contrast tint
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(barStroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(isDark ? 0.20 : 0.12), radius: 16, x: 0, y: 10)

                HStack(spacing: 12) {
                    TabButton(
                        title: "Profile",
                        systemImage: "person.fill",
                        isSelected: selected == .profile,
                        namespace: anim,
                        activeColor: labelTint,
                        inactiveColor: labelDim
                    ) { selected = .profile }

                    TabButton(
                        title: "Contacts",
                        systemImage: "person.2.fill",
                        isSelected: selected == .contacts,
                        namespace: anim,
                        activeColor: labelTint,
                        inactiveColor: labelDim
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
    let activeColor: Color
    let inactiveColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? activeColor : inactiveColor)
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
        self.disabled(condition).opacity(condition ? 0.5 : 1)
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

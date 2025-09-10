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

            // CONTENT per tab
            Group {
                switch selected {
                case .profile:
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
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
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .glassy(width: 250, height: 250)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("19")
                                            .foregroundColor(.white)
                                            .font(.title2.bold())

                                        Text("Islombek Shamsiev")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                    .padding(), 
                                    alignment: .bottomLeading
                                )
                            HStack {
                                Text("Socials")
                                    .foregroundColor(.white)
                                    .font(.title.bold())
                                    .hAlign(.leading)
                                    .padding(.leading, 30)
                                Spacer()
                                Text("Edit")            .foregroundColor(.white)
                                    .font(.system(size: 30))
                                    .padding(.trailing, 30)
                                    .fontWeight(.light)
                                    
                            }
                            HStack (spacing: 30){
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .glassy(width: 150, height: 75)
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .glassy(width: 150, height: 75)
                            }
                            HStack (spacing: 30){
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .glassy(width: 150, height: 75)
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .glassy(width: 150, height: 75)
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 140) // extra space so content doesn't hide behind the tab bar
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
                                    .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)

                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 140)
                }
            }

            // FLOATING GLASSY TAB BAR
            GlassTabBar(selected: $selected)
                .padding(.horizontal, 24)
                .safeAreaInset(edge: .bottom) {
                    // Spacer to keep content above home indicator; we put nothing here
                    Color.clear.frame(height: 0)
                }
        }
    }
}

extension Shape {
    func glassy(
        cornerRadius: CGFloat = 20,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> some View {
        self
            .fill(.ultraThinMaterial)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
    }
}

struct GlassTabBar: View {
    @Binding var selected: Tab
    @Namespace private var anim

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                // Glass background
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
                    ) {
                        selected = .profile
                    }

                    TabButton(
                        title: "Contacts",
                        systemImage: "person.2.fill",
                        isSelected: selected == .contacts,
                        namespace: anim
                    ) {
                        selected = .contacts
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(height: 66)
            .padding(.bottom, 24) // float above the home indicator
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

extension View{
    // MARK: Disabling with opacity
    func disableWithOpacity(_ condition: Bool)-> some View{
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
    }
    func hAlign(_ alignment: Alignment)-> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment)-> some View{
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func border(_ width: CGFloat, _ color: Color)-> some View{
        self
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background{
            RoundedRectangle(cornerRadius: 5, style: . continuous)
                .stroke(color, lineWidth: width)
        }
    }
    
    func fillView(_ color: Color)-> some View{
        self
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background{
            RoundedRectangle(cornerRadius: 5, style: . continuous)
                .fill(color)
        }
    }
}


#Preview {
    ContentView()
}

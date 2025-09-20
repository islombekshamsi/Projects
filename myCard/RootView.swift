import SwiftUI

struct RootView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @State private var isOnboarded: Bool = false
    @State private var hasUsername: Bool = false

    var body: some View {
        Group {
            if supabase.userId == nil {
                AuthFlowView()
            } else if !hasUsername {
                UsernameSetupView(onComplete: { hasUsername = true })
            } else if !isOnboarded {
                OnboardingFlowView(onComplete: { isOnboarded = true })
            } else {
                ContentView()
            }
        }
        .task(id: supabase.userId) {
            guard supabase.userId != nil else { return }
            do {
                if let profile = try await supabase.fetchMyProfile() {
                    hasUsername = !profile.username.isEmpty
                    // Consider onboarding complete if has 3 images and socials set
                    let images = [profile.image_1_url, profile.image_2_url, profile.image_3_url]
                    let hasImages = images.compactMap { $0 }.count == 3
                    let hasSocials = (profile.socials ?? [:]).isEmpty == false
                    isOnboarded = hasUsername && hasImages && hasSocials
                }
            } catch { }
        }
    }
}



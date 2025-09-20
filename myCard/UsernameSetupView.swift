import SwiftUI

struct UsernameSetupView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @State private var username: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose your username")
                .font(.title2)
            TextField("Username (immutable)", text: $username)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            Button(action: save) { Text(isSaving ? "Saving..." : "Save username") }
                .disabled(isSaving || username.isEmpty)
            if let errorMessage { Text(errorMessage).foregroundColor(.red) }
            Spacer()
        }
        .padding()
    }

    private func save() {
        Task { @MainActor in
            isSaving = true
            errorMessage = nil
            do {
                try await supabase.ensureProfileWithUsername(username)
                onComplete()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
}



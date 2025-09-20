import SwiftUI

struct AuthFlowView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @State private var mode: Mode = .register
    @State private var phone: String = ""
    @State private var code: String = ""
    @State private var username: String = ""
    @State private var isSending = false
    @State private var errorMessage: String?

    enum Mode { case register, verify, loginByUsername, verifyLogin }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Picker("Mode", selection: $mode) {
                    Text("Register").tag(Mode.register)
                    Text("Login").tag(Mode.loginByUsername)
                }
                .pickerStyle(.segmented)

                if mode == .register {
                    TextField("Phone number", text: $phone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(.roundedBorder)
                    Button(action: sendRegisterCode) {
                        Text(isSending ? "Sending..." : "Send code")
                    }
                    .disabled(isSending || phone.isEmpty)
                }

                if mode == .verify {
                    TextField("SMS code", text: $code)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Button(action: verifyRegisterCode) {
                        Text(isSending ? "Verifying..." : "Verify")
                    }
                    .disabled(isSending || code.isEmpty)
                }

                if mode == .loginByUsername {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                    Button(action: sendLoginCode) {
                        Text(isSending ? "Sending..." : "Send login code")
                    }
                    .disabled(isSending || username.isEmpty)
                }

                if mode == .verifyLogin {
                    TextField("SMS code", text: $code)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Button(action: verifyLoginCode) {
                        Text(isSending ? "Verifying..." : "Verify login")
                    }
                    .disabled(isSending || code.isEmpty)
                }

                if let errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }

    private func sendRegisterCode() {
        Task { @MainActor in
            isSending = true
            errorMessage = nil
            do {
                try await supabase.sendOTP(toPhone: phone)
                mode = .verify
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }

    private func verifyRegisterCode() {
        Task { @MainActor in
            isSending = true
            errorMessage = nil
            do {
                try await supabase.verifyOTP(code: code)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }

    private func sendLoginCode() {
        Task { @MainActor in
            isSending = true
            errorMessage = nil
            do {
                try await supabase.sendLoginCodeByUsername(username)
                mode = .verifyLogin
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }

    private func verifyLoginCode() {
        Task { @MainActor in
            isSending = true
            errorMessage = nil
            do {
                try await supabase.verifyOTP(code: code)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }
}



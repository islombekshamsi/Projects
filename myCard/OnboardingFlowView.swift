import SwiftUI
import PhotosUI
import UIKit

struct OnboardingFlowView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []
    @State private var socials: [String: String] = [:]
    @State private var isSaving = false
    let onComplete: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Upload three images")
                    .font(.title3)
                PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                    Text("Pick images")
                }
                .onChange(of: selectedItems) { newItems in
                    Task {
                        selectedImagesData = []
                        for item in newItems.prefix(3) {
                            if let data = try? await item.loadTransferable(type: Data.self) { selectedImagesData.append(data) }
                        }
                    }
                }
                HStack {
                    ForEach(0..<3, id: \.self) { idx in
                        Group {
                            if idx < selectedImagesData.count, let ui = UIImage(data: selectedImagesData[idx]) {
                                Image(uiImage: ui).resizable().scaledToFill()
                            } else {
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 90, height: 90).clipped().cornerRadius(8)
                    }
                }

                Text("Social profiles")
                    .font(.title3)
                SocialsEditorView(socials: $socials)

                Button(action: saveAll) { Text(isSaving ? "Saving..." : "Finish") }
                    .disabled(isSaving || selectedImagesData.count < 3)
            }
            .padding()
        }
    }

    private func saveAll() {
        Task { @MainActor in
            isSaving = true
            do {
                var urls: [String] = []
                for (idx, data) in selectedImagesData.prefix(3).enumerated() {
                    let url = try await supabase.uploadImage(data: data, fileName: "image_\(idx+1).jpg")
                    urls.append(url)
                }
                try await supabase.updateImages(urls: urls)
                try await supabase.updateSocials(socials: socials)
                onComplete()
            } catch { }
            isSaving = false
        }
    }
}

struct SocialsEditorView: View {
    @Binding var socials: [String: String]
    private let options = ["instagram", "tiktok", "twitter", "linkedin", "github", "website"]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(options, id: \.self) { key in
                HStack {
                    Text(key.capitalized).frame(width: 90, alignment: .leading)
                    TextField("handle or url", text: Binding(
                        get: { socials[key] ?? "" },
                        set: { socials[key] = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
}




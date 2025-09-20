//
//  SupabaseManager.swift
//  myCard
//
//  Centralized Supabase client and high-level API methods.
//

import Foundation
import SwiftUI
import Supabase

final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    // TODO: Replace with your project values
    // You can store these in Info.plist and load securely if preferred.
    private let supabaseUrl = URL(string: "https://xevkqutlfumbuycxxwzg.supabase.co")!
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhldmtxdXRsZnVtYnV5Y3h4d3pnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxNTE3OTQsImV4cCI6MjA3MzcyNzc5NH0.iDpLYWw3khNm_w7_S9tdHs9Xj54NpAFfmZoX0SrHG7k"

    let client: SupabaseClient

    @Published var userId: String? = nil
    @Published var phoneNumber: String? = nil

    private init() {
        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseAnonKey)
        Task {
            for await state in client.auth.stateChanges {
                switch state.event {
                case .initialSession, .signedIn, .tokenRefreshed:
                    self.userId = state.session?.user.id.uuidString
                case .signedOut, .userDeleted:
                    self.userId = nil
                default:
                    break
                }
            }
        }
    }

    // MARK: - Auth (Phone OTP)

    func sendOTP(toPhone phone: String) async throws {
        _ = try await client.auth.signInWithOTP(phone: phone)
        await MainActor.run {
            self.phoneNumber = phone
        }
    }

    func verifyOTP(code: String) async throws {
        guard let phone = phoneNumber else { throw NSError(domain: "auth", code: 0) }
        _ = try await client.auth.verifyOTP(phone: phone, token: code, type: .sms)
    }

    // MARK: - Username & Profiles

    struct Profile: Codable, Identifiable {
        let id: UUID
        let phone: String?
        let username: String
        let avatar_url: String?
        let image_1_url: String?
        let image_2_url: String?
        let image_3_url: String?
        let socials: [String: String]?
        let created_at: String?
    }

    func ensureProfileWithUsername(_ username: String) async throws {
        // Insert username if not exists and immutable
        guard let user = try await client.auth.session.user else { throw NSError(domain: "auth", code: 401) }
        let userId = user.id

        let insert: [String: Any] = [
            "id": userId.uuidString,
            "username": username
        ]
        _ = try await client.database.from("profiles").insert(values: insert).execute()
    }

    func fetchMyProfile() async throws -> Profile? {
        guard let user = try await client.auth.session.user else { return nil }
        let res = try await client.database.from("profiles").select().eq(column: "id", value: user.id.uuidString).single().execute()
        return try JSONDecoder().decode(Profile.self, from: res.data)
    }

    // MARK: - Login by username

    func sendLoginCodeByUsername(_ username: String) async throws {
        // Look up phone by username then send OTP
        let res = try await client.database.from("profiles").select("phone").eq(column: "username", value: username).single().execute()
        let payload = try JSONSerialization.jsonObject(with: res.data, options: []) as? [String: Any]
        guard let phone = payload?["phone"] as? String else { throw NSError(domain: "auth", code: 404) }
        try await sendOTP(toPhone: phone)
    }

    // MARK: - Storage Uploads

    func uploadImage(data: Data, fileName: String, bucket: String = "images") async throws -> String {
        guard let user = try await client.auth.session.user else { throw NSError(domain: "auth", code: 401) }
        let path = "\(user.id.uuidString)/\(fileName)"
        _ = try await client.storage.from(bucket).upload(path: path, file: data, options: .init(upsert: true, contentType: "image/jpeg"))
        return client.storage.from(bucket).getPublicURL(path: path)
    }

    func updateImages(urls: [String?]) async throws {
        guard let user = try await client.auth.session.user else { throw NSError(domain: "auth", code: 401) }
        let update: [String: Any?] = [
            "image_1_url": urls.count > 0 ? urls[0] : nil,
            "image_2_url": urls.count > 1 ? urls[1] : nil,
            "image_3_url": urls.count > 2 ? urls[2] : nil
        ]
        _ = try await client.database.from("profiles").update(values: update).eq(column: "id", value: user.id.uuidString).execute()
    }

    func updateSocials(socials: [String: String]) async throws {
        guard let user = try await client.auth.session.user else { throw NSError(domain: "auth", code: 401) }
        _ = try await client.database.from("profiles").update(values: ["socials": socials]).eq(column: "id", value: user.id.uuidString).execute()
    }

    // MARK: - Contacts

    struct Contact: Codable, Identifiable {
        let id: String
        let username: String
        let display_name: String?
        let avatar_url: String?
    }

    func searchContacts(query: String) async throws -> [Contact] {
        let res = try await client.database
            .rpc(fn: "search_contacts", params: ["query": query])
            .execute()
        return try JSONDecoder().decode([Contact].self, from: res.data)
    }

    func addContactByQR(targetUsername: String) async throws {
        guard let user = try await client.auth.session.user else { throw NSError(domain: "auth", code: 401) }
        _ = try await client.database.from("contacts").insert(values: [
            "owner_id": user.id.uuidString,
            "target_username": targetUsername
        ]).execute()
    }
}



import Foundation
import AuthenticationServices
import UIKit
import CryptoKit

struct GoogleOAuthConfiguration {
    let clientID: String
    let reversedClientID: String
    let bundleID: String

    var redirectURI: String {
        "\(reversedClientID):/oauth2redirect/google"
    }

    var redirectScheme: String {
        reversedClientID
    }

    static func load() -> GoogleOAuthConfiguration {
        guard let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            fatalError("GoogleService-Info.plist bulunamadı")
        }

        guard let clientID = plist["CLIENT_ID"] as? String,
              let reversedClientID = plist["REVERSED_CLIENT_ID"] as? String,
              let bundleID = plist["BUNDLE_ID"] as? String
        else {
            fatalError("GoogleService-Info.plist içinde eksik alanlar var")
        }

        return GoogleOAuthConfiguration(clientID: clientID, reversedClientID: reversedClientID, bundleID: bundleID)
    }
}

struct GoogleCredentials: Codable {
    var accessToken: String
    var refreshToken: String
    var expirationDate: Date

    var isExpired: Bool {
        Date() >= expirationDate.addingTimeInterval(-60)
    }
}

enum GoogleOAuthError: LocalizedError {
    case missingAuthorizationCode
    case tokenExchangeFailed
    case invalidRedirect
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .missingAuthorizationCode: return "Google yetkilendirmesinden kod alınamadı"
        case .tokenExchangeFailed: return "Google token isteği başarısız oldu"
        case .invalidRedirect: return "Geçersiz yönlendirme yanıtı"
        case .userCancelled: return "İşlem iptal edildi"
        }
    }
}

@MainActor
final class GoogleOAuthManager: NSObject {
    static let shared = GoogleOAuthManager()

    private let config = GoogleOAuthConfiguration.load()
    private var session: ASWebAuthenticationSession?

    private override init() { }

    func signIn(scopes: [String]) async throws -> GoogleCredentials {
        let request = try makeAuthorizationURL(scopes: scopes)
        let callbackURL = try await startSession(with: request.url)
        guard let code = callbackURL.queryItems?["code"],
              let verifier = request.pkce?.verifier
        else {
            throw GoogleOAuthError.missingAuthorizationCode
        }
        return try await exchange(code: code, verifier: verifier)
    }

    func refresh(using refreshToken: String) async throws -> GoogleCredentials {
        struct Body: Encodable {
            let client_id: String
            let grant_type: String
            let refresh_token: String
        }

        let encoder = JSONEncoder()
        let body = Body(client_id: config.clientID, grant_type: "refresh_token", refresh_token: refreshToken)
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else {
            throw GoogleOAuthError.tokenExchangeFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode)
        else {
            throw GoogleOAuthError.tokenExchangeFailed
        }

        return try makeCredentials(from: data, refreshFallback: refreshToken)
    }

    private func startSession(with url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: config.redirectScheme) { callbackURL, error in
                if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    continuation.resume(throwing: GoogleOAuthError.userCancelled)
                    return
                }
                guard let callbackURL else {
                    continuation.resume(throwing: GoogleOAuthError.invalidRedirect)
                    return
                }
                continuation.resume(returning: callbackURL)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
            self.session = session
        }
    }

    private func makeAuthorizationURL(scopes: [String]) throws -> (url: URL, pkce: PKCE?) {
        guard var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth") else {
            fatalError("Geçersiz Google auth URL")
        }

        let pkce = PKCE()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "code_challenge", value: pkce.challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        guard let url = components.url else {
            fatalError("Google auth URL oluşturulamadı")
        }

        return (url, pkce)
    }

    private func exchange(code: String, verifier: String) async throws -> GoogleCredentials {
        struct Body: Encodable {
            let code: String
            let client_id: String
            let grant_type: String
            let redirect_uri: String
            let code_verifier: String
        }

        let body = Body(
            code: code,
            client_id: config.clientID,
            grant_type: "authorization_code",
            redirect_uri: config.redirectURI,
            code_verifier: verifier
        )

        guard let url = URL(string: "https://oauth2.googleapis.com/token") else {
            throw GoogleOAuthError.tokenExchangeFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode)
        else {
            throw GoogleOAuthError.tokenExchangeFailed
        }

        return try makeCredentials(from: data, refreshFallback: nil)
    }

    private func makeCredentials(from data: Data, refreshFallback: String?) throws -> GoogleCredentials {
        struct TokenResponse: Decodable {
            let access_token: String
            let expires_in: Int
            let refresh_token: String?
        }

        guard let decoded = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
            throw GoogleOAuthError.tokenExchangeFailed
        }

        let refreshToken = decoded.refresh_token ?? refreshFallback ?? ""
        let expiration = Date().addingTimeInterval(TimeInterval(decoded.expires_in))
        return GoogleCredentials(accessToken: decoded.access_token, refreshToken: refreshToken, expirationDate: expiration)
    }
}

extension GoogleOAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}

private struct PKCE {
    let verifier: String
    let challenge: String

    init() {
        verifier = PKCE.randomString(length: 64)
        challenge = PKCE.sha256(verifier)
    }

    private static func randomString(length: Int) -> String {
        let characters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        var result = ""
        for _ in 0..<length {
            result.append(characters.randomElement() ?? "a")
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        guard let data = input.data(using: .utf8) else { return "" }
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64URLEncodedString()
    }
}

private extension URL {
    var queryItems: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let items = components.queryItems
        else { return nil }
        return items.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

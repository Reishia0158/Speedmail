import Foundation

struct GoogleUserProfile: Decodable {
    let email: String
    let name: String
}

enum GoogleProfileError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        "Google profil bilgisi alınamadı"
    }
}

struct GmailProfileService {
    func fetchProfile(using credentials: GoogleCredentials) async throws -> GoogleUserProfile {
        guard let url = URL(string: "https://www.googleapis.com/oauth2/v3/userinfo") else {
            throw GoogleProfileError.invalidResponse
        }
        
        var currentCredentials = credentials
        
        // Token süresi dolmuşsa yenile
        if currentCredentials.isExpired {
            print("🔄 Profile token süresi doldu, yenileniyor...")
            currentCredentials = try await GoogleOAuthManager.shared.refresh(using: currentCredentials.refreshToken)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(currentCredentials.accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            print("❌ Google Profile: Invalid response")
            throw GoogleProfileError.invalidResponse
        }
        
        if (200..<300).contains(http.statusCode) {
            let profile = try JSONDecoder().decode(GoogleUserProfile.self, from: data)
            print("✅ Google Profile alındı: \(profile.email)")
            return profile
        } else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
            print("❌ Google Profile Hatası (HTTP \(http.statusCode)): \(errorMsg)")
            
            // 401 = Token expired, tekrar dene
            if http.statusCode == 401 {
                print("🔄 Token geçersiz, tekrar yenileniyor...")
                currentCredentials = try await GoogleOAuthManager.shared.refresh(using: currentCredentials.refreshToken)
                
                var retryRequest = URLRequest(url: url)
                retryRequest.setValue("Bearer \(currentCredentials.accessToken)", forHTTPHeaderField: "Authorization")
                let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
                
                guard let retryHttp = retryResponse as? HTTPURLResponse, (200..<300).contains(retryHttp.statusCode) else {
                    throw GoogleProfileError.invalidResponse
                }
                
                let profile = try JSONDecoder().decode(GoogleUserProfile.self, from: retryData)
                print("✅ Google Profile alındı (2. deneme): \(profile.email)")
                return profile
            }
            
            throw GoogleProfileError.invalidResponse
        }
    }
}

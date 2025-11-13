import SwiftUI
import WebKit

enum MailDetailIntent {
    case toggleFlag(MailMessage)
    case toggleRead(MailMessage)
    case delete(MailMessage)
}

struct MailDetailView: View {
    @State private var message: MailMessage
    var account: Account?
    var handler: (MailDetailIntent) -> Void

    init(message: MailMessage, account: Account?, handler: @escaping (MailDetailIntent) -> Void) {
        _message = State(initialValue: message)
        self.account = account
        self.handler = handler
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                Divider()
                // HTML içeriği render et
                HTMLWebView(htmlContent: message.body)
                    .frame(minHeight: 300)
                if !message.attachments.isEmpty {
                    attachmentList
                }
            }
            .padding(20)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    handler(.delete(message))
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(message.subject)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("📧 MailDetailView açıldı: \(message.subject.prefix(30)) | isRead: \(message.isRead)")
            // Mail açıldığında okundu olarak işaretle
            if !message.isRead {
                print("📖 Mail okunmamış, okundu olarak işaretleniyor...")
                // ÖNEMLİ: handler'ı message.isRead değiştirmeden ÖNCE çağır
                // Çünkü toggleReadState içinde isRead kontrolü var
                handler(.toggleRead(message))
                print("✅ toggleRead handler çağrıldı")
                
                // UI'ı güncelle (local state)
                var updatedMessage = message
                updatedMessage.isRead = true
                message = updatedMessage
            } else {
                print("ℹ️ Mail zaten okunmuş")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.sender.name)
                        .font(.headline)
                    Text(message.sender.email)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(message.receivedAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let email = account?.emailAddress {
                    Text("Kime: " + email)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if !message.recipients.isEmpty {
                    Text("CC: " + message.recipients.map { $0.email }.joined(separator: ", "))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var attachmentList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ekler")
                .font(.headline)
            ForEach(message.attachments) { attachment in
                HStack {
                    Image(systemName: "doc.richtext")
                    Text(attachment.fileName)
                        .font(.subheadline)
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: Int64(attachment.fileSize), countStyle: .file))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

// MARK: - HTML WebView Wrapper

struct HTMLWebView: UIViewRepresentable {
    let htmlContent: String
    
    // HTML içeriğini formatla (tam HTML mi, parça mı kontrol et)
    private func formatHTML(_ content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Eğer zaten tam HTML ise (DOCTYPE veya <html> ile başlıyorsa), olduğu gibi kullan
        if trimmed.lowercased().hasPrefix("<!doctype") || trimmed.lowercased().hasPrefix("<html") {
            return trimmed
        }
        
        // Eğer sadece CSS kodu gibi görünüyorsa (sadece style tag'leri varsa), body içine al
        if trimmed.contains("<style") && !trimmed.contains("<body") {
            return wrapInFullHTML(trimmed)
        }
        
        // Normal HTML parçası ise, body tag'ine sar
        return wrapInFullHTML(trimmed)
    }
    
    // HTML içeriğini tam HTML formatına sar
    private func wrapInFullHTML(_ content: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <meta charset="UTF-8">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: #000;
                    background-color: transparent;
                    padding: 0;
                    margin: 0;
                }
                img {
                    max-width: 100%;
                    height: auto;
                }
                a, a:link, a:visited, a:active {
                    color: #007AFF;
                    text-decoration: none;
                }
                a:hover {
                    text-decoration: underline;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                }
            </style>
        </head>
        <body>
            \(content)
        </body>
        </html>
        """
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // HTML içeriğini formatla ve yükle
        let formattedHTML = formatHTML(htmlContent)
        webView.loadHTMLString(formattedHTML, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // İçerik değiştiğinde yeniden yükle
        let formattedHTML = formatHTML(htmlContent)
        webView.loadHTMLString(formattedHTML, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Sayfa yüklendiğinde yüksekliği ayarla (opsiyonel)
        }
    }
}
